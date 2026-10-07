/// lib/services/auth_service.dart
/// Service จัดการ Authentication — Google Sign-In + Firebase Auth
/// ห้าม hardcode API keys — อ่านจาก .env ผ่าน flutter_dotenv
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

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

  /// GoogleSignIn Instance พร้อม Calendar Scope
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'profile',
    'https://www.googleapis.com/auth/calendar.events',
  ]);

  /// ตรวจสอบ Session ปัจจุบัน (Silent Sign-In)
  Future<AuthServiceResponse> checkExistingSession() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) {
        return const AuthServiceResponse(status: false, message: 'ไม่มี Session ที่บันทึกไว้');
      }
      // Sign in Firebase ด้วย Google Credential
      final GoogleSignInAuthentication auth = await account.authentication;
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
      return const AuthServiceResponse(status: true, message: 'ออกจากระบบสำเร็จ');
    } catch (e) {
      return AuthServiceResponse(status: false, message: 'ออกจากระบบไม่สำเร็จ: ${e.toString()}');
    }
  }

  /// ดึง Access Token สำหรับ Google Calendar API
  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return null;
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
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

  /// ตรวจสอบว่า User มี Calendar Scope หรือไม่
  Future<bool> hasCalendarScope() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return false;
      final bool hasScope = await _googleSignIn.requestScopes(<String>['https://www.googleapis.com/auth/calendar.events']);
      return hasScope;
    } catch (e) {
      return false;
    }
  }
}
