// supabase/functions/_shared/firebase-auth.ts
// Shared Firebase ID Token verification for Supabase Edge Functions
// Uses jose library with official Firebase JWKS endpoint

import { createRemoteJWKSet, jwtVerify, JWTPayload } from 'https://deno.land/x/jose@v5.9.6/index.ts';

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') ?? 'yhar-bid';
const FIREBASE_JWKS_URL = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

// Create remote JWKS fetcher with automatic key rotation
const JWKS = createRemoteJWKSet(new URL(FIREBASE_JWKS_URL));

export interface FirebaseTokenPayload extends JWTPayload {
  sub: string;
  uid?: string;
  email?: string;
  email_verified?: boolean;
  firebase?: {
    identities?: Record<string, unknown>;
    sign_in_provider?: string;
  };
}

/**
 * Verify Firebase ID Token using official JWKS endpoint
 *
 * Security guarantees:
 * - RS256 signature verification against Google's public keys
 * - Automatic key rotation via remote JWKS
 * - Issuer validation
 * - Audience validation
 * - Expiration validation
 * - Token structure validation
 *
 * @param token - Firebase ID Token from Authorization: Bearer header
 * @returns Verified token payload with authenticated user ID
 * @throws Error if token is invalid, expired, or malformed
 */
export async function verifyFirebaseToken(token: string): Promise<FirebaseTokenPayload> {
  if (!token || typeof token !== 'string') {
    throw new Error('Token must be a non-empty string');
  }

  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
      algorithms: ['RS256'],
    });

    if (!payload.sub || typeof payload.sub !== 'string') {
      throw new Error('Token missing valid subject (sub)');
    }

    return payload as FirebaseTokenPayload;
  } catch (error) {
    // Enhance error messages for common cases
    if (error instanceof Error) {
      if (error.message.includes('expired')) {
        throw new Error('Token expired');
      }
      if (error.message.includes('signature')) {
        throw new Error('Invalid token signature');
      }
      if (error.message.includes('issuer')) {
        throw new Error('Invalid token issuer');
      }
      if (error.message.includes('audience')) {
        throw new Error('Invalid token audience');
      }
    }
    throw error;
  }
}

/**
 * Extract Bearer token from Authorization header
 *
 * @param authHeader - Authorization header value
 * @returns Token string or null if header is missing or malformed
 */
export function extractBearerToken(authHeader: string | null): string | null {
  if (!authHeader) {
    return null;
  }

  const parts = authHeader.trim().split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return null;
  }

  return parts[1];
}
