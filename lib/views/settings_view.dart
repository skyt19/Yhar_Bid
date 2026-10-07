/// lib/views/settings_view.dart
/// [Mockup 6] — Settings
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
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
      appBar: AppBar(
        title: const Text('ตั้งค่า', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: <Widget>[
          Obx(() => GestureDetector(
                onTap: settingsCtrl.toggleLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                  child: Text(settingsCtrl.languageCode.value == 'th' ? 'TH/EN' : 'EN/TH',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusMedium), topRight: Radius.circular(AppTheme.radiusMedium)),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _buildTile(context, 'การตั้งค่าขั้นสูง', Icons.tune_outlined, () => Get.toNamed(AppRoutes.advancedSettings)),
              _buildTile(context, 'ปรับระดับความดุด้าน AI', Icons.volume_up_outlined, () => Get.toNamed(AppRoutes.notificationSettings)),
              _buildDivider(),
              _buildTile(context, 'ล้างข้อความในแชช', Icons.cleaning_services_outlined, () async {
                await settingsCtrl.clearAppCache();
                Get.snackbar('สำเร็จ', 'ล้างข้อมูลแคชเรียบร้อย', snackPosition: SnackPosition.BOTTOM);
              }),
              _buildTile(context, 'ลืชล็อกเอา', Icons.logout_outlined, () {
                CustomDialog.show(
                  context: context,
                  title: 'ออกจากระบบ',
                  message: 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
                  confirmLabel: 'ออกจากระบบ',
                  onConfirm: () {
                    Navigator.of(context).pop();
                    authCtrl.signOut();
                  },
                  isDangerous: true,
                );
              }),
              _buildDivider(),
              _buildTile(context, 'ToS (ข้อตกลง)', Icons.article_outlined, () => Get.toNamed(AppRoutes.tos)),
              _buildTile(context, 'ติดต่อแอดมิน', Icons.contact_support_outlined, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
    );
  }

  Widget _buildDivider() => const Divider(height: 24, color: AppTheme.cardLight);
}
