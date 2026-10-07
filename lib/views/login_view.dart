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
      // พื้นหลัง Blue-Gray ตาม Mockup
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Content area — กล่องขาวตรงกลาง
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 80),

                      // หัวข้อหน้า — ตาม Mockup
                      const Text(
                        'โปรดล็อกอินหรือสมัคร',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
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
                                  : authCtrl.signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.cardLight,
                                foregroundColor: AppTheme.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                elevation: 2,
                              ),
                              child: authCtrl.isLoading.value
                                  ? const CircularProgressIndicator(strokeWidth: 2)
                                  : const Text(
                                      'Google',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),

                      // แสดง Error Message
                      Obx(() => authCtrl.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                authCtrl.errorMessage.value,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Text(
                        settingsCtrl.languageCode.value == 'th' ? 'TH/EN' : 'EN/TH',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
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
