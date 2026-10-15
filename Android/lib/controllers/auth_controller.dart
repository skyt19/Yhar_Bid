/// lib/controllers/auth_controller.dart
/// Controller จัดการ Authentication State พร้อม Session Persistence
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../main.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Connection Diagnostics State
  final RxBool isFirebaseConnected = false.obs;
  final RxString connectionStatus = 'ยังไม่ได้ตรวจสอบ'.obs;
  
  // Session Persistence Keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhoto = 'user_photo';
  static const String _keyUserUid = 'user_uid';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPersonality = 'user_personality';

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
    _checkFirebaseConnection();
  }
  
  /// ฟื้นฟู Session จาก GetStorage เมื่อเปิดแอป
  void _restoreSession() {
    final bool isLoggedIn = _storage.read<bool>(_keyIsLoggedIn) ?? false;
    
    if (isLoggedIn) {
      final String? uid = _storage.read<String>(_keyUserUid);
      final String? email = _storage.read<String>(_keyUserEmail);
      final String? name = _storage.read<String>(_keyUserName);
      final String? photo = _storage.read<String>(_keyUserPhoto);
      final String? roleStr = _storage.read<String>(_keyUserRole);
      final String? personalityStr = _storage.read<String>(_keyUserPersonality);
      
      if (uid != null && email != null) {
        currentUser.value = UserModel(
          uid: uid,
          displayName: name ?? '',
          email: email,
          photoUrl: photo ?? '',
          role: _parseRole(roleStr),
          personality: _parsePersonality(personalityStr),
          createdAt: DateTime.now(), // เก็บแค่ timestamp ล่าสุด
        );
        
        connectionStatus.value = 'Session restored: $email';
      }
    }
  }
  
  /// บันทึก Session ลง GetStorage
  void _saveSession(UserModel user) {
    _storage.write(_keyIsLoggedIn, true);
    _storage.write(_keyUserUid, user.uid);
    _storage.write(_keyUserEmail, user.email);
    _storage.write(_keyUserName, user.displayName);
    _storage.write(_keyUserPhoto, user.photoUrl);
    _storage.write(_keyUserRole, user.role.toString());
    _storage.write(_keyUserPersonality, user.personality.toString());
  }
  
  /// ลบ Session ออกจาก GetStorage
  void _clearSession() {
    _storage.remove(_keyIsLoggedIn);
    _storage.remove(_keyUserUid);
    _storage.remove(_keyUserEmail);
    _storage.remove(_keyUserName);
    _storage.remove(_keyUserPhoto);
    _storage.remove(_keyUserRole);
    _storage.remove(_keyUserPersonality);
  }
  
  /// แปลง String เป็น UserRole
  UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.student;
    if (roleStr.contains('corporateEmployee') || roleStr.contains('employee')) return UserRole.corporateEmployee;
    if (roleStr.contains('educator')) return UserRole.educator;
    return UserRole.student;
  }
  
  /// แปลง String เป็น AiPersonality
  AiPersonality _parsePersonality(String? personalityStr) {
    if (personalityStr == null) return AiPersonality.politeJarvis;
    if (personalityStr.contains('friendly')) return AiPersonality.friendly;
    if (personalityStr.contains('aggressive')) return AiPersonality.aggressiveMotivator;
    return AiPersonality.politeJarvis;
  }
  
  /// ตรวจสอบการเชื่อมต่อ Firebase
  Future<void> _checkFirebaseConnection() async {
    try {
      final user = _authService.getCurrentFirebaseUser();
      isFirebaseConnected.value = true;
      connectionStatus.value = user != null ? 'เชื่อมต่อ Firebase แล้ว' : 'Firebase พร้อมใช้งาน';
    } catch (e) {
      isFirebaseConnected.value = false;
      connectionStatus.value = 'Firebase Error: ${e.toString()}';
    }
  }

  /// ตรวจสอบ Session ที่มีอยู่เมื่อ User กดปุ่ม (ไม่อัตโนมัติ)
  Future<void> checkExistingSession() async {
    isLoading.value = true;
    connectionStatus.value = 'กำลังตรวจสอบ Session...';
    final AuthServiceResponse response = await _authService.checkExistingSession();
    isLoading.value = false;
    
    if (response.status && response.data != null) {
      currentUser.value = response.data as UserModel;
      connectionStatus.value = 'พบ Session: ${currentUser.value!.email}';
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      connectionStatus.value = response.message;
    }
  }

  /// เริ่มกระบวนการ Sign In ด้วย Google (รองรับ Calendar Scope)
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    final AuthServiceResponse response = await _authService.signInWithGoogle();
    isLoading.value = false;

    if (response.status && response.data != null) {
      currentUser.value = response.data as UserModel;
      _saveSession(currentUser.value!);
      
      // ตรวจสอบว่ามี Role แล้วหรือยัง
      if (currentUser.value!.role == UserRole.student) {
        Get.offNamed(AppRoutes.roleSelection);
      } else {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } else {
      errorMessage.value = response.message;
    }
  }

  /// อัปเดตบทบาทผู้ใช้ (จาก RoleSelectionView)
  Future<void> updateUserRole(UserRole role) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(role: role);
    _saveSession(currentUser.value!);
  }

  /// อัปเดตสไตล์ AI (จาก AiPersonalityView) และบันทึกลง Firestore
  Future<void> updateAiPersonality(AiPersonality personality) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(personality: personality);
    _saveSession(currentUser.value!);

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
      _clearSession();
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

