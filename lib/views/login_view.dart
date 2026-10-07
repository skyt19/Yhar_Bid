/// lib/views/login_view.dart
/// [Mockup 1_onboarding.jpg] — Pixel-Perfect Implementation
/// หน้า Login: พื้นหลังเทาอ่อน, ปุ่ม TH/EN มุมบนขวา, ข้อความ "โปรดล็อกอินหรือสมัคร",
/// ปุ่ม Google Sign-In แบบ Pill กลางจอ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import 'theme/app_theme.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      // พื้นหลัง Blue-Gray ตาม Mockup (#B0BEC5 ≈ Blue Grey 200)
      backgroundColor: const Color(0xFFB0BEC5),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Content area — กล่องขาวตรงกลาง
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 100),

                      // หัวข้อหน้า — ตาม Mockup
                      const Text(
                        'โปรดล็อกอินหรือสมัคร',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // ปุ่ม Google Sign-In — Pill shape ตาม Mockup
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authCtrl.isLoading.value
                                  ? null
                                  : () async {
                                      await authCtrl.signInWithGoogle();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCFD8DC), // Blue Grey 100
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                elevation: 2,
                                disabledBackgroundColor: const Color(0xFFE0E0E0),
                              ),
                              child: authCtrl.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : const Text(
                                      'Google',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),

                      const SizedBox(height: 20),

                      // แสดง Error Message
                      Obx(() => authCtrl.errorMessage.value.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                authCtrl.errorMessage.value,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink()),

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),

            // ปุ่ม TH/EN มุมบนขวา — ตาม Mockup
            Positioned(
              top: 24,
              right: 24,
              child: Obx(() => GestureDetector(
                    onTap: settingsCtrl.toggleLanguage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFD8DC),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        settingsCtrl.languageCode.value == 'th' ? 'TH/EN' : 'EN/TH',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
