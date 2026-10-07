/// lib/controllers/auth_controller.dart
/// Controller จัดการ Authentication State — เชื่อมต่อ AuthService กับ Views
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../main.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  /// ตรวจสอบ Session ที่มีอยู่เมื่อเปิดแอป
  Future<void> _checkExistingSession() async {
    final AuthServiceResponse response = await _authService.checkExistingSession();
    if (response.status && response.data != null) {
      currentUser.value = response.data as UserModel;
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  /// เริ่มกระบวนการ Sign In ด้วย Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    final AuthServiceResponse response = await _authService.signInWithGoogle();
    isLoading.value = false;

    if (response.status && response.data != null) {
      currentUser.value = response.data as UserModel;
      Get.offNamed(AppRoutes.roleSelection);
    } else {
      errorMessage.value = response.message;
    }
  }

  /// อัปเดตบทบาทผู้ใช้ (จาก RoleSelectionView)
  Future<void> updateUserRole(UserRole role) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(role: role);
  }

  /// อัปเดตสไตล์ AI (จาก AiPersonalityView) และบันทึกลง Firestore
  Future<void> updateAiPersonality(AiPersonality personality) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(personality: personality);

    // บันทึกข้อมูล User ลง Firestore
    await _authService.saveUserToFirestore(currentUser.value!);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  /// ออกจากระบบ
  Future<void> signOut() async {
    isLoading.value = true;
    final AuthServiceResponse response = await _authService.signOut();
    isLoading.value = false;

    if (response.status) {
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } else {
      errorMessage.value = response.message;
    }
  }

  /// ดึง Access Token สำหรับ Google Calendar API
  Future<String?> getAccessToken() async {
    return await _authService.getAccessToken();
  }

  /// ตรวจสอบว่า User มี Calendar Scope หรือไม่
  Future<bool> hasCalendarScope() async {
    return await _authService.hasCalendarScope();
  }
}

