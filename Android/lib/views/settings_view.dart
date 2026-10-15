/// lib/views/settings_view.dart
/// Settings — Matches assets/mockups/หน้าตั้งค่า.jpg
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../main.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFCFD8DC), // Background สีฟ้าเทาตาม Mockup
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
                  fontSize: 48, // ฟอนต์ใหญ่มากตาม Mockup
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              // Menu Items
              _buildSettingsButton('การตั้งค่าขั้นสูง', () => Get.toNamed(AppRoutes.advancedSettings)),
              const SizedBox(height: 20),
              _buildSettingsButton('ปรับระดับ ไอไอช่วยจำ', () => Get.toNamed(AppRoutes.notificationSettings)),
              const SizedBox(height: 20),
              _buildSettingsButton('เปลี่ยนเสียงแจ้งเตือน', () {}),
              const SizedBox(height: 20),
              _buildSettingsButton('เปลี่ยนภาษา', settingsCtrl.toggleLanguage),
            ],
          ),
        ),
      ),
    );
  }

  // Large rounded button (White with Black text)
  Widget _buildSettingsButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white, // สีขาวตาม Mockup
          borderRadius: BorderRadius.circular(24), // มุมโค้งมน 24px ตาม Mockup
        ),
        child: Text(
          label,
          textAlign: TextAlign.center, // จัดกลางตาม Mockup
          style: const TextStyle(
            fontSize: 24, // ฟอนต์ใหญ่มากตาม Mockup
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
