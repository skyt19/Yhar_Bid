/// lib/views/notification_settings_view.dart
/// Notification Settings — AI personality and notification preferences
/// Operate mode: clear controls, personality-based preview, warm design
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/auth_controller.dart';
import 'theme/app_theme.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('การแจ้งเตือน',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AI Personality section
                  _buildPersonalitySection(settingsCtrl),
                  const SizedBox(height: AppTheme.space24),

                  // Notification preferences
                  _buildNotificationPreferences(settingsCtrl),
                  const SizedBox(height: AppTheme.space24),

                  // Test notification
                  _buildTestSection(authCtrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── AI Personality Section ───────────────────────────────────────────────

  Widget _buildPersonalitySection(SettingsController settingsCtrl) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 24,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'บุคลิก AI',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.space2),
                    Text(
                      'ปรับวิธีที่ AI สื่อสารกับคุณ',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Obx(() {
            final level = settingsCtrl.aiAggressionLevel.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personality selector
                Row(
                  children: [
                    Expanded(
                      child: _personalityOption(
                        'สุภาพ',
                        'เป็นกันเอง มีมารยาท',
                        Icons.sentiment_satisfied_alt,
                        0,
                        level,
                        settingsCtrl,
                        AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: _personalityOption(
                        'เป็นกันเอง',
                        'ผ่อนคลาย ให้กำลังใจ',
                        Icons.sentiment_very_satisfied,
                        1,
                        level,
                        settingsCtrl,
                        AppTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: _personalityOption(
                        'กระตุ้นแรง',
                        'ท้าทาย จูงใจสูง',
                        Icons.local_fire_department,
                        2,
                        level,
                        settingsCtrl,
                        AppTheme.accentRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space20),
                const Divider(color: AppTheme.dividerColor, height: 1),
                const SizedBox(height: AppTheme.space20),
                // Preview
                _buildPreview(level),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _personalityOption(
    String label,
    String desc,
    IconData icon,
    int value,
    int currentValue,
    SettingsController ctrl,
    Color color,
  ) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => ctrl.setAiAggressionLevel(value),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppTheme.surfaceGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? color
                : AppTheme.borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              desc,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? color.withValues(alpha: 0.8)
                    : AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(int level) {
    final messages = [
      'คุณมีงานสำคัญในสัปดาห์นี้ครับ ผมแนะนำให้เริ่มเตรียมตัวตั้งแต่วันนี้เพื่อผลลัพธ์ที่ดีที่สุดครับ',
      'เฮ้! มีงานใหญ่เข้ามาแล้วนะ มาเริ่มเตรียมตัวกันดีกว่า จะได้ไม่ต้องเครียดตอนหลังไง 😊',
      'ตื่นได้แล้ว! งานสำคัญรออยู่ ถ้าไม่เริ่มเตรียมตัววันนี้ แล้วจะรอให้มันทำตัวเองเสร็จเหรอ? ไปทำเลย!',
    ];

    final colors = [
      AppTheme.accentGreen,
      AppTheme.accentOrange,
      AppTheme.accentRed,
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: colors[level].withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: colors[level].withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                size: 16,
                color: colors[level],
              ),
              const SizedBox(width: AppTheme.space6),
              Text(
                'ตัวอย่างข้อความ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors[level],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            messages[level],
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notification Preferences ─────────────────────────────────────────────

  Widget _buildNotificationPreferences(SettingsController settingsCtrl) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตั้งค่าการแจ้งเตือน',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'เปิด/ปิดการแจ้งเตือนทั้งหมด',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          Obx(() => _notificationToggle(
                'เปิดการแจ้งเตือน',
                'รับการแจ้งเตือนจากแอป Yharbid',
                Icons.notifications_active,
                settingsCtrl.notificationsEnabled.value,
                (val) => settingsCtrl.toggleNotifications(val),
              )),
        ],
      ),
    );
  }

  Widget _notificationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.accentGreen.withValues(alpha: 0.08)
            : AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: value
              ? AppTheme.accentGreen.withValues(alpha: 0.3)
              : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.accentGreen.withValues(alpha: 0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppTheme.accentGreen : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleSmall.copyWith(
                    color: value ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  subtitle,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentGreen,
          ),
        ],
      ),
    );
  }

  // ─── Test Section ─────────────────────────────────────────────────────────

  Widget _buildTestSection(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                'ทดสอบการแจ้งเตือน',
                style: AppTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'ส่งการแจ้งเตือนทดสอบเพื่อดูว่าทำงานถูกต้อง',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          ElevatedButton.icon(
            onPressed: () => _sendTestNotification(authCtrl),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('ส่งการแจ้งเตือนทดสอบ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: AppTheme.surfaceLight,
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.space14,
                horizontal: AppTheme.space20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification(AuthController authCtrl) {
    // Test notification logic
    Get.snackbar(
      'ส่งแล้ว',
      'ตรวจสอบการแจ้งเตือนของคุณ',
      backgroundColor: AppTheme.accentGreen,
      colorText: AppTheme.surfaceLight,
      icon: const Icon(Icons.check_circle, color: AppTheme.surfaceLight),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppTheme.space16),
      borderRadius: AppTheme.radiusMedium,
      duration: const Duration(seconds: 3),
    );
  }
}
