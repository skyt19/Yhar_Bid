/// lib/views/notification_settings_view.dart
/// Enhanced: Test Notification Button (FR-5)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/notification_service.dart';
import 'theme/app_theme.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('ตั้งค่าการแจ้งเตือน', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('ระดับความดุดันของ AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('ปรับระดับวิธีที่ AI กระตุ้นคุณ', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),

                  // Aggression Level Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('ระดับ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(settingsCtrl.personalityLabel, style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: settingsCtrl.aiAggressionLevel.value.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: settingsCtrl.personalityLabel,
                    activeColor: settingsCtrl.aiAggressionLevel.value == 2
                        ? Colors.red
                        : settingsCtrl.aiAggressionLevel.value == 1
                            ? Colors.orange
                            : AppTheme.accentGreen,
                    onChanged: (double val) => settingsCtrl.setAiAggressionLevel(val.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Text('สุภาพ', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('เป็นกันเอง', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('กระตุ้นแรง', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Preview Box
                  const Text('พรีวิวข้อความแจ้งเตือน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: settingsCtrl.aiAggressionLevel.value == 2
                          ? Colors.red.withOpacity(0.1)
                          : settingsCtrl.aiAggressionLevel.value == 1
                              ? Colors.orange.withOpacity(0.1)
                              : AppTheme.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: settingsCtrl.aiAggressionLevel.value == 2
                            ? Colors.red.withOpacity(0.3)
                            : settingsCtrl.aiAggressionLevel.value == 1
                                ? Colors.orange.withOpacity(0.3)
                                : AppTheme.accentGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(settingsCtrl.notificationPreviewTh, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  Text('ข้อความ: ${settingsCtrl.notificationPreviewTh.length} ตัวอักษร (สูงสุด 120)',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),

                  const SizedBox(height: 32),

                  // Notifications Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('เปิดการแจ้งเตือน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('รับการแจ้งเตือนจาก AI', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                      Switch(
                        value: settingsCtrl.notificationsEnabled.value,
                        onChanged: (bool val) => settingsCtrl.notificationsEnabled.value = val,
                        activeColor: AppTheme.accentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ปุ่มทดสอบส่งการแจ้งเตือนจริง (FR-5)
                  const Text('ทดสอบการแจ้งเตือน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final CalendarController calCtrl = Get.find<CalendarController>();
                      final AuthController authCtrl = Get.find<AuthController>();
                      final NotificationService notifService = NotificationService();
                      
                      // ดึง Event ถัดไปจาก Calendar
                      final upcoming = calCtrl.events
                          .where((e) => e.startTime.isAfter(DateTime.now()))
                          .toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
                      
                      if (upcoming.isEmpty) {
                        Get.snackbar('แจ้งเตือน', 'ไม่มีกิจกรรมในปฏิทินเพื่อทดสอบ',
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      
                      final user = authCtrl.currentUser.value;
                      if (user == null) return;
                      
                      // ส่ง Test Notification
                      await notifService.initialize();
                      final result = await notifService.sendTestNotification(
                        user.role,
                        user.personality,
                      );
                      
                      Get.snackbar(
                        'ทดสอบแจ้งเตือน',
                        result.message,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.notification_important),
                    label: const Text('ทดสอบส่งการแจ้งเตือนจากงานถัดไป'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.accentGray,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

