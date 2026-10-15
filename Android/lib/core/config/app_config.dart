import 'package:flutter/foundation.dart';
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
  
  /// ⚠️ PRODUCTION CONFIGURATION: These values are used when .env is unavailable
  /// (e.g., Flutter Web Release builds on Firebase Hosting)
  /// 
  /// Security Note: Web apps expose client-side code anyway, so storing
  /// API keys here is acceptable for Firebase/Google services with proper
  /// security rules. For sensitive backend APIs, use Firebase Functions instead.
  /// 
  /// Get your keys from:
  /// - Gemini: https://aistudio.google.com/app/apikey
  /// - Google OAuth: https://console.cloud.google.com/apis/credentials
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
  /// NEVER throws exceptions - returns placeholder if not configured
  static String get geminiApiKey {
    try {
      final String? envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      }
    } catch (e) {
      debugPrint('⚠️ [AppConfig] Error reading GEMINI_API_KEY from dotenv: $e');
    }
    
    if (_FALLBACK_GEMINI_API_KEY.startsWith('YOUR_')) {
      debugPrint('❌ [AppConfig] GEMINI_API_KEY not configured! AI features will be disabled.');
      return 'UNCONFIGURED_GEMINI_KEY';
    }
    debugPrint('⚠️ [AppConfig] GEMINI_API_KEY not found in .env, using built-in fallback');
    return _FALLBACK_GEMINI_API_KEY;
  }

  /// Google OAuth Client ID
  /// Priority: .env -> Fallback constant
  /// NEVER throws exceptions - returns placeholder if not configured
  static String get googleClientId {
    try {
      final String? envId = dotenv.env['GOOGLE_CLIENT_ID'];
      if (envId != null && envId.isNotEmpty) {
        return envId;
      }
    } catch (e) {
      debugPrint('⚠️ [AppConfig] Error reading GOOGLE_CLIENT_ID from dotenv: $e');
    }
    
    if (_FALLBACK_GOOGLE_CLIENT_ID.startsWith('YOUR_')) {
      debugPrint('❌ [AppConfig] GOOGLE_CLIENT_ID not configured! Google Sign-In will be disabled.');
      return 'UNCONFIGURED_CLIENT_ID';
    }
    debugPrint('⚠️ [AppConfig] GOOGLE_CLIENT_ID not found in .env, using built-in fallback');
    return _FALLBACK_GOOGLE_CLIENT_ID;
  }

  /// Google OAuth Client Secret
  /// Priority: .env -> Fallback constant
  /// NEVER throws exceptions - returns placeholder if not configured
  static String get googleClientSecret {
    try {
      final String? envSecret = dotenv.env['GOOGLE_CLIENT_SECRET'];
      if (envSecret != null && envSecret.isNotEmpty) {
        return envSecret;
      }
    } catch (e) {
      debugPrint('⚠️ [AppConfig] Error reading GOOGLE_CLIENT_SECRET from dotenv: $e');
    }
    
    if (_FALLBACK_GOOGLE_CLIENT_SECRET.startsWith('YOUR_')) {
      debugPrint('❌ [AppConfig] GOOGLE_CLIENT_SECRET not configured! Calendar sync will be disabled.');
      return 'UNCONFIGURED_CLIENT_SECRET';
    }
    debugPrint('⚠️ [AppConfig] GOOGLE_CLIENT_SECRET not found in .env, using built-in fallback');
    return _FALLBACK_GOOGLE_CLIENT_SECRET;
  }

  // ============================================
  // INITIALIZATION CHECK
  // ============================================

  /// Validate configuration on app startup
  /// NEVER throws exceptions - only logs warnings
  static void validate() {
    debugPrint('🔧 [AppConfig] Validating configuration...');
    
    bool hasEnvGemini = false;
    bool hasEnvClientId = false;
    bool hasEnvClientSecret = false;
    
    try {
      hasEnvGemini = dotenv.env['GEMINI_API_KEY'] != null && dotenv.env['GEMINI_API_KEY']!.isNotEmpty;
      hasEnvClientId = dotenv.env['GOOGLE_CLIENT_ID'] != null && dotenv.env['GOOGLE_CLIENT_ID']!.isNotEmpty;
      hasEnvClientSecret = dotenv.env['GOOGLE_CLIENT_SECRET'] != null && dotenv.env['GOOGLE_CLIENT_SECRET']!.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ [AppConfig] Error reading .env: $e');
    }
    
    if (!hasEnvGemini || !hasEnvClientId || !hasEnvClientSecret) {
      debugPrint('⚠️ [AppConfig] Some keys missing from .env, checking fallbacks:');
      if (!hasEnvGemini) {
        if (_FALLBACK_GEMINI_API_KEY.startsWith('YOUR_')) {
          debugPrint('  ❌ GEMINI_API_KEY: NOT CONFIGURED');
        } else {
          debugPrint('  ✅ GEMINI_API_KEY: FALLBACK OK');
        }
      }
      if (!hasEnvClientId) {
        if (_FALLBACK_GOOGLE_CLIENT_ID.startsWith('YOUR_')) {
          debugPrint('  ❌ GOOGLE_CLIENT_ID: NOT CONFIGURED');
        } else {
          debugPrint('  ✅ GOOGLE_CLIENT_ID: FALLBACK OK');
        }
      }
      if (!hasEnvClientSecret) {
        if (_FALLBACK_GOOGLE_CLIENT_SECRET.startsWith('YOUR_')) {
          debugPrint('  ❌ GOOGLE_CLIENT_SECRET: NOT CONFIGURED');
        } else {
          debugPrint('  ✅ GOOGLE_CLIENT_SECRET: FALLBACK OK');
        }
      }
    } else {
      debugPrint('✅ [AppConfig] All keys loaded from .env successfully');
    }
    
    debugPrint('✅ [AppConfig] Configuration validated successfully');
  }

  // ============================================
  // DEBUG INFO
  // ============================================

  /// Print configuration status (for debugging)
  /// NEVER throws exceptions - safe for production
  static void printStatus() {
    debugPrint('📊 [AppConfig] Current Configuration Status:');
    try {
      final String gemini = geminiApiKey;
      if (gemini == 'UNCONFIGURED_GEMINI_KEY') {
        debugPrint('  Gemini API Key: NOT CONFIGURED');
      } else {
        debugPrint('  Gemini API Key: ${gemini.substring(0, gemini.length > 20 ? 20 : gemini.length)}...');
      }
    } catch (e) {
      debugPrint('  Gemini API Key: ERROR - $e');
    }
    try {
      final String clientId = googleClientId;
      if (clientId == 'UNCONFIGURED_CLIENT_ID') {
        debugPrint('  Google Client ID: NOT CONFIGURED');
      } else {
        debugPrint('  Google Client ID: ${clientId.substring(0, clientId.length > 30 ? 30 : clientId.length)}...');
      }
    } catch (e) {
      debugPrint('  Google Client ID: ERROR - $e');
    }
    try {
      final String clientSecret = googleClientSecret;
      if (clientSecret == 'UNCONFIGURED_CLIENT_SECRET') {
        debugPrint('  Google Client Secret: NOT CONFIGURED');
      } else {
        debugPrint('  Google Client Secret: ${clientSecret.substring(0, clientSecret.length > 15 ? 15 : clientSecret.length)}...');
      }
    } catch (e) {
      debugPrint('  Google Client Secret: ERROR - $e');
    }
  }
}

