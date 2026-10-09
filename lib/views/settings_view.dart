/// lib/views/settings_view.dart
/// Settings — Matches assets/mockups2/หน้าตั้งค่า.jpg
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_dialog.dart';
import '../main.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Setting',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              // Menu Items
              _buildSettingsButton('การตั้งค่าขั้นสูง', () => Get.toNamed(AppRoutes.advancedSettings)),
              const SizedBox(height: 16),
              _buildSettingsButton('ปรับระดับ ไอไอช่วยจำ', () => Get.toNamed(AppRoutes.notificationSettings)),
              const SizedBox(height: 16),
              _buildSettingsButton('เปลี่ยนเสียงแจ้งเตือน', () {}),
              const SizedBox(height: 16),
              _buildSettingsButton('เปลี่ยนภาษา', settingsCtrl.toggleLanguage),
            ],
          ),
        ),
      ),
    );
  }

  // Large rounded button (White with Dark Gray text)
  Widget _buildSettingsButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
