// supabase/functions/chat-db/index.ts
// Supabase Edge Function for AI chat database operations
// Verifies Firebase ID tokens using RS256 signature validation (same as groq-proxy)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') ?? 'yhar-bid';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? 'https://aanochhlejpbhdhkgjpx.supabase.co';
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': 'https://yhar-bid.web.app',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, content-type',
};

// ----- Firebase Token Verification (RS256) ---------------------

interface JwkCache {
  keys: Record<string, CryptoKey>;
  fetchedAt: number;
  maxAgeMs: number;
}

let keyCache: JwkCache | null = null;
const GOOGLE_JWKS_URL =
  'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

function b64urlDecode(input: string): Uint8Array {
  const pad = input.length % 4 === 0 ? '' : '='.repeat(4 - (input.length % 4));
  const b64 = (input + pad).replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

async function getGoogleCerts(forceRefresh = false): Promise<Record<string, CryptoKey>> {
  if (!forceRefresh && keyCache && Date.now() - keyCache.fetchedAt < keyCache.maxAgeMs) {
    return keyCache.keys;
  }

  const resp = await fetch(GOOGLE_JWKS_URL, { method: 'GET', signal: AbortSignal.timeout(5000) });
  if (!resp.ok) {
    throw new Error(`Failed to fetch Google certs: ${resp.status}`);
  }

  const cacheControl = resp.headers.get('cache-control') ?? '';
  const maxAgeMatch = /max-age=(\d+)/.exec(cacheControl);
  const maxAgeMs = maxAgeMatch ? parseInt(maxAgeMatch[1], 10) * 1000 : 3600_000;

  const certsJson = await resp.json();
  const keys: Record<string, CryptoKey> = {};

  for (const [kid, certPem] of Object.entries(certsJson)) {
    if (typeof certPem !== 'string') continue;
    const b64 = certPem
      .replace(/-----BEGIN CERTIFICATE-----/, '')
      .replace(/-----END CERTIFICATE-----/, '')
      .replace(/\s/g, '');

    const binaryDer = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
    const cryptoKey = await crypto.subtle.importKey(
      'spki',
      binaryDer,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['verify']
    );
    keys[kid] = cryptoKey;
  }

  keyCache = { keys, fetchedAt: Date.now(), maxAgeMs };
  return keys;
}

async function verifyFirebaseToken(token: string): Promise<{ sub: string }> {
  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('Invalid JWT format');
  }

  const headerJson = new TextDecoder().decode(b64urlDecode(parts[0]));
  const payloadJson = new TextDecoder().decode(b64urlDecode(parts[1]));
  const signature = b64urlDecode(parts[2]);

  const header = JSON.parse(headerJson);
  const payload = JSON.parse(payloadJson);

  // Validate claims
  const expectedIssuer = `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;
  if (payload.iss !== expectedIssuer) {
    throw new Error('Invalid issuer');
  }
  if (payload.aud !== FIREBASE_PROJECT_ID) {
    throw new Error('Invalid audience');
  }
  if (!payload.sub || typeof payload.sub !== 'string') {
    throw new Error('Missing or invalid sub');
  }

  const now = Math.floor(Date.now() / 1000);
  if (!payload.exp || now >= payload.exp) {
    throw new Error('Token expired');
  }
  if (!payload.iat || payload.iat > now) {
    throw new Error('Invalid iat');
  }

  // Verify RS256 signature
  if (header.alg !== 'RS256') {
    throw new Error('Unsupported algorithm');
  }

  const kid = header.kid;
  if (!kid) {
    throw new Error('Missing kid');
  }

  let certs = await getGoogleCerts(false);
  let key = certs[kid];

  if (!key) {
    certs = await getGoogleCerts(true);
    key = certs[kid];
    if (!key) {
      throw new Error('Unknown kid');
    }
  }

  const signatureInput = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
  const valid = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, signature, signatureInput);

  if (!valid) {
    throw new Error('Invalid signature');
  }

  return { sub: payload.sub };
}

// ----- Database Operations ---------------------

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  try {
    // Verify Firebase token with RS256 signature validation
    const authHeader = req.headers.get('authorization') ?? '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : '';

    if (!token) {
      return new Response(JSON.stringify({ error: 'Missing token' }), {
        status: 401,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      });
    }

    const payload = await verifyFirebaseToken(token);
    const userId = payload.sub;

    // Create Supabase client with service role key
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
      auth: {
        persistSession: false,
      },
    });

    const { operation, ...params } = await req.json();

    switch (operation) {
      case 'list_conversations': {
        const { data, error } = await supabase
          .from('conversations')
          .select('*')
          .eq('user_id', userId)
          .order('updated_at', { ascending: false })
          .limit(params.limit ?? 50);

        if (error) throw error;
        return new Response(JSON.stringify({ ok: true, data }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      case 'get_messages': {
        const { conversationId } = params;

        // Verify user owns this conversation
        const { data: conv, error: convError } = await supabase
          .from('conversations')
          .select('user_id')
          .eq('id', conversationId)
          .single();

        if (convError || !conv || conv.user_id !== userId) {
          throw new Error('Conversation not found or access denied');
        }

        const { data, error } = await supabase
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', { ascending: true });

        if (error) throw error;
        return new Response(JSON.stringify({ ok: true, data }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      case 'create_conversation': {
        const { title, personalityLevel } = params;
        const { data, error } = await supabase
          .from('conversations')
          .insert({
            user_id: userId,
            title: title ?? null,
            personality_level: personalityLevel ?? 'standard',
          })
          .select()
          .single();

        if (error) throw error;
        return new Response(JSON.stringify({ ok: true, data }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      case 'add_message': {
        const { conversationId, role, content, metadata } = params;

        // Verify user owns this conversation
        const { data: conv, error: convError } = await supabase
          .from('conversations')
          .select('user_id')
          .eq('id', conversationId)
          .single();

        if (convError || !conv || conv.user_id !== userId) {
          throw new Error('Conversation not found or access denied');
        }

        const { data, error } = await supabase
          .from('messages')
          .insert({
            conversation_id: conversationId,
            role,
            content,
            metadata: metadata ?? null,
          })
          .select()
          .single();

        if (error) throw error;

        // Update conversation timestamp
        await supabase
          .from('conversations')
          .update({ updated_at: new Date().toISOString() })
          .eq('id', conversationId);

        return new Response(JSON.stringify({ ok: true, data }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      case 'delete_conversation': {
        const { conversationId } = params;

        // Verify ownership before deletion
        const { error } = await supabase
          .from('conversations')
          .delete()
          .eq('id', conversationId)
          .eq('user_id', userId);

        if (error) throw error;
        return new Response(JSON.stringify({ ok: true }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      case 'update_conversation': {
        const { conversationId, title } = params;

        // Verify ownership before update
        const { error } = await supabase
          .from('conversations')
          .update({ title })
          .eq('id', conversationId)
          .eq('user_id', userId);

        if (error) throw error;
        return new Response(JSON.stringify({ ok: true }), {
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      default:
        return new Response(JSON.stringify({ error: 'Unknown operation' }), {
          status: 400,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
    }
  } catch (error) {
    console.error('[chat-db] Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: error.message.includes('Token') || error.message.includes('signature') ? 401 : 500,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      },
    );
  }
});
