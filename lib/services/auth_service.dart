/// lib/services/auth_service.dart
/// Service จัดการ Authentication — Google Sign-In + Firebase Auth
/// ห้าม hardcode API keys — อ่านจาก .env ผ่าน flutter_dotenv
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../core/config/app_config.dart';

// Conditional imports สำหรับ Web
import 'dart:js_interop' as js;
import 'dart:js_util' as js_util;

/// Standard Error Response Format ตาม .clinerules
class AuthServiceResponse {
  final bool status;
  final String message;
  final dynamic data;
  const AuthServiceResponse({required this.status, required this.message, this.data});
}

/// Service Layer สำหรับ Authentication — ห้าม depend on Controllers
class AuthService {
  /// Lazy Getters เพื่อป้องกัน Web Crash — ไม่ eager initialize
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Web-specific Access Token Cache (เพราะ Web ไม่ได้ accessToken จาก GoogleSignInAuthentication)
  String? _webAccessToken;
  DateTime? _tokenExpiry;

  /// GoogleSignIn Instance พร้อม Calendar Scope (FULL WRITE ACCESS)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? AppConfig.googleClientId // Use AppConfig with fallback
        : null, // Mobile/Desktop uses google-services.json / GoogleService-Info.plist
    scopes: <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar.events',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  /// ตรวจสอบ Session ปัจจุบัน (Silent Sign-In)
  Future<AuthServiceResponse> checkExistingSession() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) {
        return const AuthServiceResponse(status: false, message: 'ไม่มี Session ที่บันทึกไว้');
      }
      // Sign in Firebase ด้วย Google Credential
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Cache Access Token for Web Platform (restore session)
      if (kIsWeb) {
        _webAccessToken = auth.accessToken ?? auth.idToken;
        print('🌐 [AuthService] Restored Web token from session: ${_webAccessToken?.substring(0, 20)}...');
      }
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final UserModel? userData = await _fetchUserFromFirestore(userCredential.user!.uid);
      return AuthServiceResponse(status: true, message: 'กู้ Session สำเร็จ', data: userData);
    } catch (e) {
      return AuthServiceResponse(status: false, message: 'ไม่สามารถกู้ Session ได้: ${e.toString()}');
    }
  }

  /// เริ่มกระบวนการ Sign In ด้วย Google
  Future<AuthServiceResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthServiceResponse(status: false, message: 'ผู้ใช้ยกเลิกการเข้าสู่ระบบ');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Cache Access Token for Web Platform
      if (kIsWeb) {
        _webAccessToken = googleAuth.accessToken ?? googleAuth.idToken;
        print('🌐 [AuthService] Web Platform - Cached token: ${_webAccessToken?.substring(0, 20)}...');
      }
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const AuthServiceResponse(status: false, message: 'ไม่สามารถสร้าง Firebase User ได้');
      }
      final UserModel? existingUser = await _fetchUserFromFirestore(firebaseUser.uid);
      if (existingUser != null) {
        return AuthServiceResponse(status: true, message: 'เข้าสู่ระบบสำเร็จ', data: existingUser);
      } else {
        final UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? googleUser.displayName ?? '',
          email: firebaseUser.email ?? googleUser.email,
          photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl ?? '',
          role: UserRole.student,
          personality: AiPersonality.politeJarvis,
          createdAt: DateTime.now(),
        );
        return AuthServiceResponse(status: true, message: 'เข้าสู่ระบบสำเร็จ (ผู้ใช้ใหม่)', data: newUser);
      }
    } on FirebaseAuthException catch (e) {
      return AuthServiceResponse(status: false, message: 'Firebase Auth Error: ${e.code} - ${e.message ?? "ไม่ทราบสาเหตุ"}');
    } catch (e) {
      // จัดการ error อื่นๆ รวมถึง PlatformException
      return AuthServiceResponse(status: false, message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.toString()}');
    }
  }

  /// บันทึกข้อมูล User ลง Firestore
  Future<AuthServiceResponse> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
      return const AuthServiceResponse(status: true, message: 'บันทึกข้อมูลผู้ใช้สำเร็จ');
    } catch (e) {
      return AuthServiceResponse(status: false, message: 'บันทึกข้อมูลไม่สำเร็จ: ${e.toString()}');
    }
  }

  /// ออกจากระบบ
  Future<AuthServiceResponse> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      
      // Clear cached token
      _webAccessToken = null;
      
      return const AuthServiceResponse(status: true, message: 'ออกจากระบบสำเร็จ');
    } catch (e) {
      return AuthServiceResponse(status: false, message: 'ออกจากระบบไม่สำเร็จ: ${e.toString()}');
    }
  }

  /// ดึง Access Token สำหรับ Google Calendar API
  /// Web Platform: ใช้ Token Client โดยตรงเพื่อขอ OAuth Access Token
  Future<String?> getAccessToken() async {
    try {
      // Web Platform: Use Token Client for real OAuth access token
      if (kIsWeb) {
        // Check if cached token is still valid
        if (_webAccessToken != null && _tokenExpiry != null) {
          if (DateTime.now().isBefore(_tokenExpiry!)) {
            print('✅ [AuthService] Using cached Web token (valid until $_tokenExpiry)');
            return _webAccessToken;
          } else {
            print('⚠️ [AuthService] Cached token expired, requesting new one...');
          }
        }
        
        // Request new access token via Token Client
        final token = await _requestWebAccessTokenViaGIS();
        if (token != null) {
          return token;
        }
        
        print('❌ [AuthService] Web: No valid access token available');
        return null;
      }
      
      // Mobile/Desktop: Use GoogleSignIn.currentUser
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        print('⚠️ [AuthService] GoogleSignIn.currentUser is NULL (Mobile/Desktop)');
        return null;
      }
      
      final GoogleSignInAuthentication auth = await account.authentication;
      
      if (auth.accessToken != null) {
        print('✅ [AuthService] Got accessToken (Mobile/Desktop)');
        return auth.accessToken;
      }
      
      print('❌ [AuthService] No valid token found (Mobile/Desktop)');
      return null;
    } catch (e) {
      print('❌ [AuthService.getAccessToken] Error: $e');
      
      // Last resort: return cached token on Web
      if (kIsWeb && _webAccessToken != null) {
        print('⚠️ [AuthService] Exception occurred, using cached token');
        return _webAccessToken;
      }
      
      return null;
    }
  }

  /// ดึงข้อมูล User จาก Firestore
  Future<UserModel?> _fetchUserFromFirestore(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  User? getCurrentFirebaseUser() => _firebaseAuth.currentUser;

  /// Request OAuth Access Token บน Web Platform โดยใช้ GIS Token Client
  Future<String?> _requestWebAccessTokenViaGIS() async {
    if (!kIsWeb) return null;
    
    try {
      print('🌐 [AuthService] Requesting Access Token via GIS Token Client...');
      
      final completer = Completer<String?>();
      
      // สร้าง Token Client config
      final config = js_util.newObject();
      js_util.setProperty(config, 'client_id', '197558461101-fpvs52hlfg76po4c5bmufqotpr962hf6.apps.googleusercontent.com');
      js_util.setProperty(config, 'scope', 'https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events');
      
      // Callback สำหรับรับ token
      js_util.setProperty(config, 'callback', js_util.allowInterop((response) {
        try {
          final accessToken = js_util.getProperty(response, 'access_token');
          if (accessToken != null) {
            final expiresIn = js_util.getProperty(response, 'expires_in') as int? ?? 3600;
            
            _webAccessToken = accessToken.toString();
            _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
            
            print('✅ [AuthService] Got Access Token: ${_webAccessToken?.substring(0, 20)}...');
            print('🕐 [AuthService] Token expires at: $_tokenExpiry');
            
            completer.complete(_webAccessToken);
          } else {
            print('❌ [AuthService] Access token is null in response');
            completer.complete(null);
          }
        } catch (e) {
          print('❌ [AuthService] Error in callback: $e');
          completer.complete(null);
        }
      }));
      
      // Error callback
      js_util.setProperty(config, 'error_callback', js_util.allowInterop((error) {
        print('❌ [AuthService] GIS Error: $error');
        completer.complete(null);
      }));
      
      // เรียก Token Client
      final google = js_util.getProperty(js_util.globalThis, 'google');
      final accounts = js_util.getProperty(google, 'accounts');
      final oauth2 = js_util.getProperty(accounts, 'oauth2');
      final tokenClient = js_util.callMethod(oauth2, 'initTokenClient', [config]);
      
      // Request access token
      js_util.callMethod(tokenClient, 'requestAccessToken', []);
      
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ [AuthService] Token request timeout');
          return null;
        },
      );
    } catch (e) {
      print('❌ [AuthService] Error in _requestWebAccessTokenViaGIS: $e');
      return null;
    }
  }

  /// ตรวจสอบว่า User มี Calendar Scope หรือไม่
  Future<bool> hasCalendarScope() async {
    try {
      // Web Platform: ตรวจสอบว่ามี cached token หรือไม่
      if (kIsWeb) {
        if (_webAccessToken != null && _tokenExpiry != null) {
          if (DateTime.now().isBefore(_tokenExpiry!)) {
            print('✅ [AuthService] Web has valid calendar token');
            return true;
          }
        }
        print('⚠️ [AuthService] Web: No valid token, will request when needed');
        return false;
      }
      
      // Mobile/Desktop: ใช้ GoogleSignIn
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return false;
      final bool hasScope = await _googleSignIn.requestScopes(<String>[
        'https://www.googleapis.com/auth/calendar.events',
        'https://www.googleapis.com/auth/calendar',
      ]);
      return hasScope;
    } catch (e) {
      return false;
    }
  }

  /// ขอ Calendar Scope เพิ่มเติม (ใช้เมื่อ User ยังไม่ได้อนุญาต)
  Future<bool> requestCalendarScope() async {
    try {
      // Web Platform: ขอ Access Token ผ่าน GIS Token Client
      if (kIsWeb) {
        print('🌐 [AuthService] Web: Requesting Calendar access via GIS...');
        final token = await _requestWebAccessTokenViaGIS();
        return token != null && token.isNotEmpty;
      }
      
      // Mobile/Desktop: ใช้ GoogleSignIn
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return false;
      
      final bool granted = await _googleSignIn.requestScopes(<String>[
        'https://www.googleapis.com/auth/calendar.events',
        'https://www.googleapis.com/auth/calendar',
      ]);
      
      return granted;
    } catch (e) {
      print('❌ [AuthService.requestCalendarScope] Error: $e');
      return false;
    }
  }
}
