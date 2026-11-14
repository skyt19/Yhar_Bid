import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig - Central Configuration Management
///
/// The Groq API key is NO LONGER loaded by the client.
/// Groq requests are proxied through a Supabase Edge Function
/// (lib/services/ai_service.dart) that holds the key server-side.
///
/// Remaining client-side configuration:
///   - Supabase publishable key (safe to expose; identifies the project)
///   - Firebase project ID (already public via firebase_options.dart)
///   - Google OAuth client ID (already public; embedded for web OAuth)
class AppConfig {
  // ============================================
  // CLIENT-SAFE CONFIGURATION
  // ============================================

  /// Supabase publishable (anon) key.
  /// Safe to ship in the client: it only identifies the project to the
  /// Supabase gateway; Row Level Security / function-side Firebase token
  /// verification enforce access control.
  /// Hardcoded as fallback because .env may not load in release web builds.
  static const String _FALLBACK_SUPABASE_PUBLISHABLE_KEY =
      'sb_publishable_1DdTR3XEL4RlTjAeMSOsag_ZBmIZpsv';

  /// Supabase project URL (public — identifies the project endpoint).
  static const String _FALLBACK_SUPABASE_URL =
      'https://aanochhlejpbhdhkgjpx.supabase.co';

  /// Firebase project ID (public — also in lib/firebase_options.dart).
  static const String _FALLBACK_FIREBASE_PROJECT_ID = 'yhar-bid';

  /// Google OAuth Client ID (public for web OAuth).
  static const String _FALLBACK_GOOGLE_CLIENT_ID =
      '197558461101-fpvs52hlfg76po4c5bmufqotpr962hf6.apps.googleusercontent.com';

  // ============================================
  // PUBLIC GETTERS
  // ============================================

  /// Supabase publishable key.
  /// Priority: .env -> fallback constant.
  static String get supabasePublishableKey {
    try {
      final String? envKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];
      if (envKey != null && envKey.isNotEmpty) return envKey;
    } catch (e) {
      debugPrint('⚠️ [AppConfig] Error reading SUPABASE_PUBLISHABLE_KEY: $e');
    }
    debugPrint('⚠️ [AppConfig] SUPABASE_PUBLISHABLE_KEY using fallback');
    return _FALLBACK_SUPABASE_PUBLISHABLE_KEY;
  }

  /// Supabase project URL (public).
  /// Priority: .env -> fallback constant.
  static String get supabaseUrl {
    try {
      final String? envUrl = dotenv.env['SUPABASE_URL'];
      if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    } catch (_) {
      // ignore
    }
    return _FALLBACK_SUPABASE_URL;
  }

  /// Firebase project ID (public).
  static String get firebaseProjectId {
    try {
      final String? envId = dotenv.env['FIREBASE_PROJECT_ID'];
      if (envId != null && envId.isNotEmpty) return envId;
    } catch (_) {
      // ignore
    }
    return _FALLBACK_FIREBASE_PROJECT_ID;
  }

  /// AI Model Name (Groq Model ID) — LOCKED, client-side reference only.
  /// The proxy ignores any client-supplied model and uses this constant.
  static const String _FALLBACK_AI_MODEL = 'openai/gpt-oss-20b';

  static String get aiModel {
    try {
      final String? envModel = dotenv.env['AI_MODEL'];
      if (envModel != null && envModel.isNotEmpty) return envModel;
    } catch (_) {
      // ignore
    }
    return _FALLBACK_AI_MODEL;
  }

  /// Google OAuth Client ID (public for web OAuth).
  static String get googleClientId {
    try {
      final String? envId = dotenv.env['GOOGLE_CLIENT_ID'];
      if (envId != null && envId.isNotEmpty) return envId;
    } catch (_) {
      // ignore
    }
    return _FALLBACK_GOOGLE_CLIENT_ID;
  }

  // ============================================
  // INITIALIZATION CHECK
  // ============================================

  /// Validate configuration on app startup.
  /// NEVER throws exceptions - only logs warnings.
  static void validate() {
    debugPrint('🔧 [AppConfig] Validating configuration...');
    final supa = supabasePublishableKey;
    if (supa.isEmpty) {
      debugPrint('  ❌ SUPABASE_PUBLISHABLE_KEY empty — AI proxy will fail');
    } else {
      debugPrint('  ✅ SUPABASE_PUBLISHABLE_KEY configured');
    }
    debugPrint('  ✅ Firebase project: $firebaseProjectId');
    debugPrint('  ✅ AI model (locked): $aiModel');
    debugPrint('✅ [AppConfig] Configuration validated');
  }

  /// Print configuration status (safe for production — no secrets).
  static void printStatus() {
    debugPrint('📊 [AppConfig] Configuration Status:');
    debugPrint('  Supabase publishable key: configured');
    debugPrint('  Firebase project: $firebaseProjectId');
    debugPrint('  AI model: $aiModel (locked, enforced server-side)');
    debugPrint('  Groq API key: server-side only (not in client)');
  }
}

