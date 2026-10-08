import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig - Central Configuration Management with Built-in Fallback
/// 
/// Priority Order:
/// 1. Environment variables from .env file (dotenv)
/// 2. Built-in fallback constants (if .env missing or null)
/// 
/// This ensures 100% runtime stability even without .env file.
class AppConfig {
  // ============================================
  // BUILT-IN FALLBACK SECRETS (Production Keys)
  // ============================================
  
  static const String _FALLBACK_GEMINI_API_KEY = 
      'AQ.Ab8RN6JFhMBDx5yyURduPJDLWV_fY6YCum3ynObdlNHS6KOdiQ';
  
  static const String _FALLBACK_GOOGLE_CLIENT_ID = 
      '197558461101-fpvs52hlfg76po4c5bmufqotpr962hf6.apps.googleusercontent.com';
  
  static const String _FALLBACK_GOOGLE_CLIENT_SECRET = 
      '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';

  // ============================================
  // PUBLIC GETTERS (with Fallback Logic)
  // ============================================

  /// Gemini API Key (AI Service)
  /// Priority: .env -> Fallback constant
  static String get geminiApiKey {
    final String? envKey = dotenv.env['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    print('⚠️ [AppConfig] GEMINI_API_KEY not found in .env, using built-in fallback');
    return _FALLBACK_GEMINI_API_KEY;
  }

  /// Google OAuth Client ID
  /// Priority: .env -> Fallback constant
  static String get googleClientId {
    final String? envId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (envId != null && envId.isNotEmpty) {
      return envId;
    }
    print('⚠️ [AppConfig] GOOGLE_CLIENT_ID not found in .env, using built-in fallback');
    return _FALLBACK_GOOGLE_CLIENT_ID;
  }

  /// Google OAuth Client Secret
  /// Priority: .env -> Fallback constant
  static String get googleClientSecret {
    final String? envSecret = dotenv.env['GOOGLE_CLIENT_SECRET'];
    if (envSecret != null && envSecret.isNotEmpty) {
      return envSecret;
    }
    print('⚠️ [AppConfig] GOOGLE_CLIENT_SECRET not found in .env, using built-in fallback');
    return _FALLBACK_GOOGLE_CLIENT_SECRET;
  }

  // ============================================
  // INITIALIZATION CHECK
  // ============================================

  /// Validate configuration on app startup
  static void validate() {
    print('🔧 [AppConfig] Validating configuration...');
    
    final bool hasEnvGemini = dotenv.env['GEMINI_API_KEY'] != null;
    final bool hasEnvClientId = dotenv.env['GOOGLE_CLIENT_ID'] != null;
    final bool hasEnvClientSecret = dotenv.env['GOOGLE_CLIENT_SECRET'] != null;
    
    if (!hasEnvGemini || !hasEnvClientId || !hasEnvClientSecret) {
      print('⚠️ [AppConfig] Some keys missing from .env, using built-in fallbacks:');
      if (!hasEnvGemini) print('  - GEMINI_API_KEY: FALLBACK');
      if (!hasEnvClientId) print('  - GOOGLE_CLIENT_ID: FALLBACK');
      if (!hasEnvClientSecret) print('  - GOOGLE_CLIENT_SECRET: FALLBACK');
    } else {
      print('✅ [AppConfig] All keys loaded from .env successfully');
    }
    
    // Validate that we have usable values (either from .env or fallback)
    assert(geminiApiKey.isNotEmpty, 'GEMINI_API_KEY must not be empty');
    assert(googleClientId.isNotEmpty, 'GOOGLE_CLIENT_ID must not be empty');
    assert(googleClientSecret.isNotEmpty, 'GOOGLE_CLIENT_SECRET must not be empty');
    
    print('✅ [AppConfig] Configuration validated successfully');
  }

  // ============================================
  // DEBUG INFO
  // ============================================

  /// Print configuration status (for debugging)
  static void printStatus() {
    print('📊 [AppConfig] Current Configuration Status:');
    print('  Gemini API Key: ${geminiApiKey.substring(0, 20)}...');
    print('  Google Client ID: ${googleClientId.substring(0, 30)}...');
    print('  Google Client Secret: ${googleClientSecret.substring(0, 15)}...');
  }
}
