// supabase/functions/groq-proxy/index.ts
// Yharbid — Secure Groq proxy for Flutter Web.
// Architecture: Flutter Web (Firebase Hosting) -> Firebase Auth -> this function -> Groq API
//
// Authentication model:
//   - Supabase gateway JWT verification is DISABLED (verify_jwt = false).
//   - The client sends the Supabase publishable key in the `apikey` header.
//   - The client sends the Firebase ID Token in `Authorization: Bearer <token>`.
//   - The function performs full Firebase ID Token verification:
//       * RS256 signature against Google's public x509 certificates
//       * Issuer = https://securetoken.google.com/<FIREBASE_PROJECT_ID>
//       * Audience = <FIREBASE_PROJECT_ID>
//       * exp / iat / sub validation
//   - GROQ_API_KEY is read from Deno.env only; it never leaves the function.
//
// Limitations:
//   - Token revocation is not checked against Firebase's revoked-token list
//     (requires a server-side admin SDK call). Expired and malformed tokens
//     are still rejected. A short-lived valid token that has been revoked
//     server-side can still pass for up to its exp. This is an accepted
//     tradeoff for the free-tier architecture; reduce impact by keeping
//     session lifetimes short on the Firebase project.

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "yhar-bid";
const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY") ?? "";
const GROQ_MODEL = "openai/gpt-oss-20b"; // LOCKED — client cannot override
const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
const GROQ_TIMEOUT_MS = 30_000;
const MAX_BODY_BYTES = 32_000; // ~32 KB request cap
const MAX_MESSAGES = 20;
const MAX_TOKENS_CEILING = 1500;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": Deno.env.get("CORS_ALLOW_ORIGIN") ??
    "https://yhar-bid.web.app",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Max-Age": "86400",
  "Vary": "Origin",
};

// ----- Public key cache for Firebase token verification ---------------------

interface JwkCache {
  keys: Record<string, CryptoKey>;
  fetchedAt: number;
  maxAgeMs: number;
}

let keyCache: JwkCache | null = null;
const GOOGLE_JWKS_URL =
  "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com";

interface Header {
  alg?: string;
  kid?: string;
  typ?: string;
}
interface Payload {
  iss?: string;
  aud?: string;
  sub?: string;
  exp?: number;
  iat?: number;
}

function b64urlDecode(input: string): Uint8Array {
  const pad = input.length % 4 === 0 ? "" : "=".repeat(4 - (input.length % 4));
  const b64 = (input + pad).replace(/-/g, "+").replace(/_/g, "/");
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

async function getGoogleCerts(forceRefresh = false): Promise<Record<string, CryptoKey>> {
  if (!forceRefresh && keyCache && Date.now() - keyCache.fetchedAt < keyCache.maxAgeMs) {
    return keyCache.keys;
  }
  console.log(`[groq-proxy] Fetching Google certificates (forceRefresh=${forceRefresh})`);
  const resp = await fetch(GOOGLE_JWKS_URL, { cache: "no-store" });
  if (!resp.ok) throw new Error(`Failed to fetch Google certificates: HTTP ${resp.status}`);
  const cacheControl = resp.headers.get("cache-control") ?? "";
  const maxAgeMatch = cacheControl.match(/max-age=(\d+)/);
  const maxAgeSec = maxAgeMatch ? parseInt(maxAgeMatch[1], 10) : 3600;
  const body = await resp.text();
  // Google returns a JSON map of keyId -> PEM x509 cert.
  const certMap = JSON.parse(body) as Record<string, string>;
  const kids = Object.keys(certMap);
  console.log(`[groq-proxy] Google cert map contains ${kids.length} kid(s)`);

  const keys: Record<string, CryptoKey> = {};
  for (const [kid, pem] of Object.entries(certMap)) {
    try {
      const key = await pemToCryptoKey(pem);
      keys[kid] = key;
    } catch (err) {
      // Log the kid so we can diagnose cert parse failures without leaking content.
      const msg = err instanceof Error ? err.message : String(err);
      console.warn(`[groq-proxy] Failed to parse cert for kid=${kid}: ${msg}`);
    }
  }
  const loaded = Object.keys(keys).length;
  console.log(`[groq-proxy] Successfully loaded ${loaded}/${kids.length} cert(s)`);

  keyCache = {
    keys,
    fetchedAt: Date.now(),
    maxAgeMs: Math.max(60_000, (maxAgeSec - 120) * 1000),
  };
  return keys;
}

/**
 * Extract SubjectPublicKeyInfo (SPKI) bytes from a DER-encoded X.509 certificate.
 *
 * Google's Firebase cert endpoint returns full X.509 certs (BEGIN CERTIFICATE),
 * not raw SPKI keys. crypto.subtle.importKey("spki", ...) requires SPKI bytes,
 * so we must walk the DER structure to find and extract the subjectPublicKeyInfo
 * field from within TBSCertificate.
 *
 * DER X.509 Certificate structure:
 *   SEQUENCE (Certificate)
 *     SEQUENCE (TBSCertificate)
 *       [0] EXPLICIT version (optional, v1 certs omit this)
 *       INTEGER            serialNumber
 *       SEQUENCE           signature AlgorithmIdentifier
 *       SEQUENCE           issuer Name
 *       SEQUENCE           validity
 *       SEQUENCE           subject Name
 *       SEQUENCE           subjectPublicKeyInfo  ← extract this full TLV
 *       ...                (extensions, optional)
 *     SEQUENCE           signatureAlgorithm
 *     BIT STRING         signatureValue
 */
function extractSpkiFromCertDer(der: Uint8Array): Uint8Array {
  let pos = 0;

  function readByte(): number {
    if (pos >= der.length) throw new Error(`DER truncated at offset ${pos}`);
    return der[pos++];
  }

  function readTag(): number {
    return readByte();
  }

  function readLength(): number {
    const first = readByte();
    if (first < 0x80) return first;                     // short form
    const octets = first & 0x7f;
    if (octets === 0 || octets > 4) {
      throw new Error(`unsupported DER length encoding: ${octets} octets at ${pos - 1}`);
    }
    let len = 0;
    for (let i = 0; i < octets; i++) len = (len << 8) | readByte();
    return len;
  }

  /** Skip the length and value of the current element. */
  function skipValue(): void {
    const len = readLength();
    pos += len;
  }

  /** Read tag, then skip the value. Returns the tag byte. */
  function skipElement(): number {
    const tag = readTag();
    skipValue();
    return tag;
  }

  // ── Outer Certificate SEQUENCE ────────────────────────────────────────────
  const certTag = readTag();
  if (certTag !== 0x30) throw new Error(`expected Certificate SEQUENCE (0x30), got 0x${certTag.toString(16)}`);
  readLength(); // consume outer length

  // ── TBSCertificate SEQUENCE ───────────────────────────────────────────────
  const tbsTag = readTag();
  if (tbsTag !== 0x30) throw new Error(`expected TBSCertificate SEQUENCE (0x30), got 0x${tbsTag.toString(16)}`);
  readLength(); // consume TBS length

  // ── Walk TBSCertificate fields ────────────────────────────────────────────

  // 1. version [0] EXPLICIT — optional; present in v2/v3 certs (most modern certs)
  if (pos < der.length && der[pos] === 0xa0) {
    skipElement(); // version
  }

  // 2. serialNumber INTEGER
  const snTag = skipElement();
  if (snTag !== 0x02) throw new Error(`expected serialNumber INTEGER (0x02), got 0x${snTag.toString(16)}`);

  // 3. signature AlgorithmIdentifier SEQUENCE
  const sigTag = skipElement();
  if (sigTag !== 0x30) throw new Error(`expected signature AlgorithmIdentifier (0x30), got 0x${sigTag.toString(16)}`);

  // 4. issuer Name SEQUENCE
  const issTag = skipElement();
  if (issTag !== 0x30) throw new Error(`expected issuer Name (0x30), got 0x${issTag.toString(16)}`);

  // 5. validity SEQUENCE
  const valTag = skipElement();
  if (valTag !== 0x30) throw new Error(`expected validity (0x30), got 0x${valTag.toString(16)}`);

  // 6. subject Name SEQUENCE
  const subTag = skipElement();
  if (subTag !== 0x30) throw new Error(`expected subject Name (0x30), got 0x${subTag.toString(16)}`);

  // 7. subjectPublicKeyInfo SEQUENCE — extract full TLV
  if (pos >= der.length || der[pos] !== 0x30) {
    throw new Error(`expected subjectPublicKeyInfo SEQUENCE (0x30), got 0x${der[pos]?.toString(16)} at ${pos}`);
  }
  const spkiStart = pos;
  pos++; // consume tag byte
  const spkiContentLen = readLength();
  const spkiHeaderLen = pos - spkiStart; // tag + length field bytes
  const spkiTotalLen = spkiHeaderLen + spkiContentLen;

  // Copy into a fresh ArrayBuffer-backed Uint8Array (required by crypto.subtle)
  const spki = new Uint8Array(spkiTotalLen);
  spki.set(der.subarray(spkiStart, spkiStart + spkiTotalLen));
  return spki;
}

/** Build minimal X.509 Certificate DER wrapping an SPKI TLV.
 *  Used in tests to verify extractSpkiFromCertDer without network access. */
function _buildMinimalCertDer(spkiTlv: Uint8Array): Uint8Array {
  function tlv(tag: number, content: Uint8Array): Uint8Array {
    const len = content.length;
    if (len < 0x80) {
      const out = new Uint8Array(2 + len);
      out[0] = tag; out[1] = len;
      out.set(content, 2);
      return out;
    }
    // Long-form length (2-byte), handles up to 65535 bytes
    const out = new Uint8Array(4 + len);
    out[0] = tag; out[1] = 0x82; out[2] = (len >> 8) & 0xff; out[3] = len & 0xff;
    out.set(content, 4);
    return out;
  }

  function concat(...arrays: Uint8Array[]): Uint8Array {
    const total = arrays.reduce((s, a) => s + a.length, 0);
    const out = new Uint8Array(total);
    let offset = 0;
    for (const a of arrays) { out.set(a, offset); offset += a.length; }
    return out;
  }

  // version [0] EXPLICIT INTEGER 2 (v3)
  const version = new Uint8Array([0xa0, 0x03, 0x02, 0x01, 0x02]);
  // serialNumber INTEGER 1
  const serial = new Uint8Array([0x02, 0x01, 0x01]);
  // minimal AlgorithmIdentifier SEQUENCE (empty body, structurally valid for test)
  const emptySeq = new Uint8Array([0x30, 0x00]);

  const tbsContent = concat(version, serial, emptySeq, emptySeq, emptySeq, emptySeq, spkiTlv);
  const tbs = tlv(0x30, tbsContent);

  // signatureAlgorithm and signatureValue (dummies)
  const sigAlg = emptySeq;
  const sigVal = new Uint8Array([0x03, 0x01, 0x00]); // empty BIT STRING

  const certContent = concat(tbs, sigAlg, sigVal);
  return tlv(0x30, certContent);
}

/**
 * Copy a Uint8Array into a fresh, definite ArrayBuffer.
 * TypeScript types Uint8Array.buffer as ArrayBufferLike (can be SharedArrayBuffer),
 * which WebCrypto's BufferSource does not accept. This helper guarantees the
 * return type is ArrayBuffer, eliminating TS2769 on crypto.subtle calls.
 */
function toArrayBuffer(source: Uint8Array): ArrayBuffer {
  const buffer = new ArrayBuffer(source.byteLength);
  new Uint8Array(buffer).set(source);
  return buffer;
}

async function pemToCryptoKey(pem: string): Promise<CryptoKey> {
  const b64 = pem
    .replace(/-----BEGIN CERTIFICATE-----/g, "")
    .replace(/-----END CERTIFICATE-----/g, "")
    .replace(/\s+/g, "");
  const derSrc = b64urlDecode(b64);
  const der = new Uint8Array(derSrc.byteLength);
  der.set(derSrc);

  // Google returns full X.509 certificates. crypto.subtle.importKey("spki", ...)
  // requires SubjectPublicKeyInfo bytes, not the whole cert.
  // Walk the DER to extract the subjectPublicKeyInfo field.
  const spki = extractSpkiFromCertDer(der);

  // spki.buffer is ArrayBufferLike (may include SharedArrayBuffer in TS types).
  // Use toArrayBuffer() to get a definitively-typed ArrayBuffer for WebCrypto.
  return crypto.subtle.importKey(
    "spki",
    toArrayBuffer(spki),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"],
  );
}

async function verifyFirebaseToken(token: string): Promise<Payload> {
  const parts = token.split(".");
  if (parts.length !== 3) throw new Error("malformed token");
  const header = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[0]))) as Header;
  if (header.alg !== "RS256") throw new Error("unsupported alg");
  if (!header.kid) throw new Error("missing kid");

  // First attempt: use cached certs.
  let certs = await getGoogleCerts();
  let key = certs[header.kid];

  if (!key) {
    // The token's kid is not in the current cache. This happens when Google
    // rotates signing keys and the cache was built before the rotation.
    // Force-refresh the cert map once and retry.
    console.log(
      `[groq-proxy] kid not found in cache (cached kids: ${Object.keys(certs).length}), forcing refresh`,
    );
    certs = await getGoogleCerts(true);
    key = certs[header.kid];
  }

  if (!key) {
    // Still missing after a fresh fetch — genuinely unknown kid.
    console.warn(
      `[groq-proxy] kid still missing after refresh. Available kids: ${Object.keys(certs).length}`,
    );
    throw new Error("unknown kid");
  }

  const dataSrc = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
  const sigSrc = b64urlDecode(parts[2]);
  // Copy into fresh ArrayBuffer-backed Uint8Arrays so crypto.subtle.verify
  // accepts them as BufferSource (TS2345).
  const data = new Uint8Array(dataSrc.byteLength);
  data.set(dataSrc);
  const sig = new Uint8Array(sigSrc.byteLength);
  sig.set(sigSrc);
  const ok = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, sig, data);
  if (!ok) throw new Error("bad signature");

  const payload = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[1]))) as Payload;

  const expectedIssuer = `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;
  if (payload.iss !== expectedIssuer) throw new Error("bad issuer");
  if (payload.aud !== FIREBASE_PROJECT_ID) throw new Error("bad audience");
  if (!payload.sub || payload.sub.length === 0) throw new Error("bad subject");

  const now = Math.floor(Date.now() / 1000);
  if (payload.exp === undefined || now >= payload.exp) throw new Error("expired");
  if (payload.iat === undefined || now < payload.iat - 60) throw new Error("bad iat");

  return payload;
}

// ----- Request validation ----------------------------------------------------

interface ChatMessage {
  role: string;
  content: string;
}

interface ProxyRequestBody {
  operation: "chat" | "preparation";
  messages?: ChatMessage[];
  max_tokens?: number;
  temperature?: number;
  role?: string;
  event?: { title?: string; description?: string };
}

function validateBody(body: ProxyRequestBody): string | null {
  if (!body || typeof body !== "object") return "missing body";
  if (body.operation !== "chat" && body.operation !== "preparation") {
    return "unsupported operation";
  }
  if (!Array.isArray(body.messages) || body.messages.length === 0) {
    return "messages required";
  }
  if (body.messages.length > MAX_MESSAGES) return "too many messages";
  for (const m of body.messages) {
    if (typeof m.role !== "string" || typeof m.content !== "string") {
      return "bad message shape";
    }
    if (m.role !== "system" && m.role !== "user" && m.role !== "assistant") {
      return "bad role";
    }
    if (m.content.length > 8000) return "message too long";
  }
  if (body.max_tokens !== undefined) {
    if (typeof body.max_tokens !== "number" || body.max_tokens < 1) {
      return "bad max_tokens";
    }
  }
  if (body.temperature !== undefined) {
    if (typeof body.temperature !== "number" ||
        body.temperature < 0 || body.temperature > 2) {
      return "bad temperature";
    }
  }
  return null;
}

async function callGroq(
  body: ProxyRequestBody,
): Promise<{ status: number; json: Record<string, unknown> | null; text: string }> {
  if (!GROQ_API_KEY) {
    console.error("[groq-proxy] groq_request_failed: GROQ_API_KEY not set in Deno.env");
    return { status: 503, json: null, text: "GROQ_API_KEY not configured server-side" };
  }

  const maxTokens = Math.min(body.max_tokens ?? 500, MAX_TOKENS_CEILING);
  const temperature = body.temperature ?? 0.7;

  const groqBody = {
    model: GROQ_MODEL,
    messages: body.messages,
    max_tokens: maxTokens,
    temperature,
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), GROQ_TIMEOUT_MS);

  console.log(`[groq-proxy] groq_request_started model=${GROQ_MODEL} messages=${body.messages?.length ?? 0} max_tokens=${maxTokens}`);

  try {
    const resp = await fetch(GROQ_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${GROQ_API_KEY}`,
      },
      body: JSON.stringify(groqBody),
      signal: controller.signal,
    });

    const text = await resp.text();
    let json: Record<string, unknown> | null = null;
    try {
      json = JSON.parse(text) as Record<string, unknown>;
    } catch (_) {
      // non-JSON response from Groq
      console.warn(`[groq-proxy] groq_response_non_json status=${resp.status} body_preview=${text.slice(0, 120)}`);
    }

    if (resp.status === 200 && json === null) {
      // Groq returned 200 but the body was not valid JSON — log enough to diagnose.
      console.error(`[groq-proxy] groq_response_failed status=200 json=null body_preview=${text.slice(0, 120)}`);
    } else if (resp.status !== 200) {
      // Extract safe diagnostic fields from Groq error body (never logs the API key).
      const groqErr = json ? (json["error"] as Record<string, unknown> | null | undefined) : null;
      const errType = groqErr?.["type"] ?? null;
      const errCode = groqErr?.["code"] ?? null;
      const errMsg  = groqErr?.["message"] ?? null;
      console.error(
        `[groq-proxy] groq_response_failed status=${resp.status}` +
        ` type=${errType} code=${errCode}` +
        ` message=${typeof errMsg === "string" ? errMsg.slice(0, 200) : errMsg}`,
      );
    } else {
      console.log(`[groq-proxy] groq_response_received status=${resp.status}`);
    }

    return { status: resp.status, json, text };
  } catch (e) {
    if (e instanceof DOMException && e.name === "AbortError") {
      console.error(`[groq-proxy] groq_request_failed stage=fetch error=timeout timeout_ms=${GROQ_TIMEOUT_MS}`);
      return { status: 504, json: null, text: "Groq timeout" };
    }
    const errName = e instanceof Error ? e.name : "UnknownError";
    const errMsg  = e instanceof Error ? e.message : String(e);
    console.error(`[groq-proxy] groq_request_failed stage=fetch error_name=${errName} message=${errMsg.slice(0, 200)}`);
    return { status: 502, json: null, text: "network error" };
  } finally {
    clearTimeout(timer);
  }
}

function jsonResp(
  status: number,
  body: Record<string, unknown>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}

// ----- Main ------------------------------------------------------------------

async function handler(req: Request): Promise<Response> {
  const requestId = crypto.randomUUID().slice(0, 8); // short correlator, not a secret

  try {
    if (req.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }
    if (req.method !== "POST") {
      return jsonResp(405, { error: "method not allowed" });
    }

    console.log(`[groq-proxy] request_received id=${requestId} method=${req.method}`);

    // Require Supabase publishable key (api gateway identity)
    const apiKey = req.headers.get("apikey");
    if (!apiKey) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=missing_apikey`);
      return jsonResp(401, { error: "missing apikey" });
    }

    // Require Firebase ID Token
    const auth = req.headers.get("authorization") ?? "";
    const bearer = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!bearer) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=missing_authorization`);
      return jsonResp(401, { error: "missing authorization" });
    }

    let payload: Payload;
    try {
      payload = await verifyFirebaseToken(bearer);
      // Log only that verification succeeded and the sub length, never the token or uid.
      console.log(`[groq-proxy] firebase_token_verified id=${requestId} sub_len=${(payload.sub ?? "").length}`);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "verification failed";
      console.warn(`[groq-proxy] firebase_token_rejected id=${requestId} reason=${msg}`);
      return jsonResp(401, { error: `invalid token: ${msg}` });
    }

    // Body size cap
    const contentLength = Number(req.headers.get("content-length") ?? "0");
    if (contentLength > MAX_BODY_BYTES) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=body_too_large content-length=${contentLength}`);
      return jsonResp(413, { error: "request too large" });
    }
    const raw = await req.text();
    if (raw.length > MAX_BODY_BYTES) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=body_too_large actual=${raw.length}`);
      return jsonResp(413, { error: "request too large" });
    }
    let body: ProxyRequestBody;
    try {
      body = JSON.parse(raw);
    } catch (_) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=invalid_json`);
      return jsonResp(400, { error: "invalid json" });
    }
    const bad = validateBody(body);
    if (bad) {
      console.warn(`[groq-proxy] request_rejected id=${requestId} reason=validation operation=${body?.operation} validation_error=${bad}`);
      return jsonResp(400, { error: bad });
    }

    // Call Groq
    const result = await callGroq(body);

    if (result.status === 200 && result.json) {
      console.log(`[groq-proxy] response_returned id=${requestId} status=200`);
      return jsonResp(200, { ok: true, data: result.json, uid: payload.sub });
    }

    // ── Map Groq non-success statuses ─────────────────────────────────────────
    // Log the upstream status so we can see which branch fires in production.

    if (result.status === 503) {
      // GROQ_API_KEY not set — configuration error.
      console.error(`[groq-proxy] response_returned id=${requestId} upstream=503 reason=GROQ_API_KEY_missing`);
      return jsonResp(503, { error: "AI service not configured" });
    }

    if (result.status === 401 || result.status === 403) {
      console.error(`[groq-proxy] response_returned id=${requestId} upstream=${result.status} reason=groq_auth_failed`);
      return jsonResp(502, { error: "upstream auth error" });
    }

    if (result.status === 429) {
      console.warn(`[groq-proxy] response_returned id=${requestId} upstream=429 reason=rate_limited`);
      return jsonResp(429, { error: "rate limited" });
    }

    if (result.status === 504) {
      console.warn(`[groq-proxy] response_returned id=${requestId} upstream=504 reason=timeout`);
      return jsonResp(504, { error: "upstream timeout" });
    }

    // 200 with null JSON, 4xx, 5xx, or network error (status 502 from callGroq catch).
    console.error(
      `[groq-proxy] response_returned id=${requestId} upstream=${result.status}` +
      ` json_null=${result.json === null} text_preview=${result.text.slice(0, 120)}`,
    );
    return jsonResp(502, { error: "upstream error", status: result.status });

  } catch (e) {
    // Catch-all: any unexpected exception escaping the handler.
    const errName  = e instanceof Error ? e.name    : "UnknownError";
    const errMsg   = e instanceof Error ? e.message : String(e);
    const errStack = e instanceof Error && e.stack
      ? e.stack.split("\n").slice(0, 6).join(" | ")
      : "";
    console.error(
      `[groq-proxy] unexpected_exception id=${requestId}` +
      ` error_name=${errName} message=${errMsg.slice(0, 200)} stack=${errStack}`,
    );
    return jsonResp(500, { error: "internal error" });
  }
}

// Export for unit tests
export { handler, validateBody, verifyFirebaseToken, getGoogleCerts, extractSpkiFromCertDer, _buildMinimalCertDer };

// Only start the HTTP server when this module is the entry point.
// When imported by tests (import("./index.ts")), import.meta.main is false,
// so Deno.serve() does not run — preventing AddrInUse on repeated imports.
// Supabase Edge Functions run index.ts as the entry point, so the server
// starts normally in production.
if (import.meta.main) {
  Deno.serve(handler);
}
