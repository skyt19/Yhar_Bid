/// lib/views/notification_settings_view.dart
/// [Extrapolate SRS FR-5] — Notification Preview & Settings
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
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
                      Text(settingsCtrl.personalityLabel, style: const TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold)),
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
                            : AppTheme.accentPrimary,
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
                              : AppTheme.accentPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: settingsCtrl.aiAggressionLevel.value == 2
                            ? Colors.red.withOpacity(0.3)
                            : settingsCtrl.aiAggressionLevel.value == 1
                                ? Colors.orange.withOpacity(0.3)
                                : AppTheme.accentPrimary.withOpacity(0.3),
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
                        activeColor: AppTheme.accentPrimary,
                      ),
                    ],
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
