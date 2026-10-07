/// lib/controllers/auth_controller.dart
/// Controller จัดการ Authentication — Google Sign-In, Session, Role Setup
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../main.dart';

class AuthController extends GetxController {
  // State ที่ View สามารถ Observe ได้
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Google Sign-In scopes ที่ต้องการ
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  /// ตรวจสอบ Session ที่มีอยู่เมื่อเปิดแอป
  Future<void> _checkExistingSession() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        await _handleGoogleSignInAccount(account);
      }
    } catch (e) {
      // ไม่มี Session เก่า — ปล่อยให้อยู่หน้า Login
      errorMessage.value = '';
    }
  }

  /// เริ่มกระบวนการ Sign In ด้วย Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // ผู้ใช้ยกเลิกการ Sign In
        isLoading.value = false;
        return;
      }
      await _handleGoogleSignInAccount(account);
    } catch (e) {
      errorMessage.value = 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    } finally {
      isLoading.value = false;
    }
  }

  /// จัดการ Account ที่ได้รับจาก Google — ตรวจสอบว่าเป็นผู้ใช้ใหม่หรือเก่า
  Future<void> _handleGoogleSignInAccount(GoogleSignInAccount account) async {
    // สร้าง UserModel เบื้องต้นจาก Google Account
    final UserModel newUser = UserModel(
      uid: account.id,
      displayName: account.displayName ?? '',
      email: account.email,
      photoUrl: account.photoUrl ?? '',
      role: UserRole.student, // ค่าเริ่มต้น ต้องผ่าน Role Selection
      personality: AiPersonality.politeJarvis,
      createdAt: DateTime.now(),
    );
    currentUser.value = newUser;

    // นำทางไปหน้าเลือกบทบาทสำหรับผู้ใช้ใหม่
    Get.offNamed(AppRoutes.roleSelection);
  }

  /// อัปเดตบทบาทผู้ใช้ (จาก RoleSelectionView)
  Future<void> updateUserRole(UserRole role) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(role: role);
  }

  /// อัปเดตสไตล์ AI (จาก AiPersonalityView)
  Future<void> updateAiPersonality(AiPersonality personality) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(personality: personality);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  /// ออกจากระบบ
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _googleSignIn.signOut();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      errorMessage.value = 'ออกจากระบบไม่สำเร็จ';
    } finally {
      isLoading.value = false;
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
}
