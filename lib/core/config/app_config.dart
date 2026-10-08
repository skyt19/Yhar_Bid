import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig - Central Configuration Management with Built-in Fallback
/// 
/// Priority Order:
/// 1. Environment variables from .env file (dotenv)
/// 2. Built-in fallback constants (MUST BE CONFIGURED)
/// 
/// ⚠️ IMPORTANT: Replace fallback values with your actual keys
/// This ensures 100% runtime stability even without .env file.
class AppConfig {
  // ============================================
  // BUILT-IN FALLBACK SECRETS (CONFIGURE THESE!)
  // ============================================
  
  /// ⚠️ SECURITY WARNING: Replace these with your actual production keys
  /// Never commit real secrets to version control!
  /// 
  /// Get your keys from:
  /// - Gemini: https://aistudio.google.com/app/apikey
  /// - Google OAuth: https://console.cloud.google.com/apis/credentials
  static const String _FALLBACK_GEMINI_API_KEY = 
      'YOUR_GEMINI_API_KEY_HERE';
  
  static const String _FALLBACK_GOOGLE_CLIENT_ID = 
      'YOUR_GOOGLE_CLIENT_ID_HERE.apps.googleusercontent.com';
  
  static const String _FALLBACK_GOOGLE_CLIENT_SECRET = 
      'YOUR_GOOGLE_CLIENT_SECRET_HERE';

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
    if (_FALLBACK_GEMINI_API_KEY.startsWith('YOUR_')) {
      throw Exception('❌ [AppConfig] GEMINI_API_KEY not configured! Please set it in .env or app_config.dart');
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
    if (_FALLBACK_GOOGLE_CLIENT_ID.startsWith('YOUR_')) {
      throw Exception('❌ [AppConfig] GOOGLE_CLIENT_ID not configured! Please set it in .env or app_config.dart');
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
    if (_FALLBACK_GOOGLE_CLIENT_SECRET.startsWith('YOUR_')) {
      throw Exception('❌ [AppConfig] GOOGLE_CLIENT_SECRET not configured! Please set it in .env or app_config.dart');
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
      print('⚠️ [AppConfig] Some keys missing from .env, checking fallbacks:');
      if (!hasEnvGemini) {
        if (_FALLBACK_GEMINI_API_KEY.startsWith('YOUR_')) {
          print('  ❌ GEMINI_API_KEY: NOT CONFIGURED');
        } else {
          print('  ✅ GEMINI_API_KEY: FALLBACK OK');
        }
      }
      if (!hasEnvClientId) {
        if (_FALLBACK_GOOGLE_CLIENT_ID.startsWith('YOUR_')) {
          print('  ❌ GOOGLE_CLIENT_ID: NOT CONFIGURED');
        } else {
          print('  ✅ GOOGLE_CLIENT_ID: FALLBACK OK');
        }
      }
      if (!hasEnvClientSecret) {
        if (_FALLBACK_GOOGLE_CLIENT_SECRET.startsWith('YOUR_')) {
          print('  ❌ GOOGLE_CLIENT_SECRET: NOT CONFIGURED');
        } else {
          print('  ✅ GOOGLE_CLIENT_SECRET: FALLBACK OK');
        }
      }
    } else {
      print('✅ [AppConfig] All keys loaded from .env successfully');
    }
    
    print('✅ [AppConfig] Configuration validated successfully');
  }

  // ============================================
  // DEBUG INFO
  // ============================================

  /// Print configuration status (for debugging)
  static void printStatus() {
    print('📊 [AppConfig] Current Configuration Status:');
    try {
      final String gemini = geminiApiKey;
      print('  Gemini API Key: ${gemini.substring(0, gemini.length > 20 ? 20 : gemini.length)}...');
    } catch (e) {
      print('  Gemini API Key: NOT CONFIGURED');
    }
    try {
      final String clientId = googleClientId;
      print('  Google Client ID: ${clientId.substring(0, clientId.length > 30 ? 30 : clientId.length)}...');
    } catch (e) {
      print('  Google Client ID: NOT CONFIGURED');
    }
    try {
      final String clientSecret = googleClientSecret;
      print('  Google Client Secret: ${clientSecret.substring(0, clientSecret.length > 15 ? 15 : clientSecret.length)}...');
    } catch (e) {
      print('  Google Client Secret: NOT CONFIGURED');
    }
  }
}

