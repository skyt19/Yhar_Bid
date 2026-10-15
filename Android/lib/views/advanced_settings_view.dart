/// lib/views/advanced_settings_view.dart
/// [Mockup 7] — Advanced Settings ระดับ Production
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/auth_controller.dart';
import 'theme/app_theme.dart';

class AdvancedSettingsView extends StatelessWidget {
  const AdvancedSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsCtrl = Get.find<SettingsController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('advanced_settings'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Section 1: การจัดการแคชและข้อมูล ---
              Text('การจัดการแคชและข้อมูล', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
              const SizedBox(height: 16),
              
              _buildActionTile(
                icon: Icons.cleaning_services,
                label: 'clear_cache'.tr,
                onTap: () async {
                  final bool confirm = await _showConfirmDialog(
                    context,
                    title: 'ยืนยันการล้างแคช',
                    message: 'คุณต้องการล้างข้อมูลแคชชั่วคราวหรือไม่?',
                  );
                  if (confirm) { await settingsCtrl.clearAppCache(); }
                },
              ),
              
              _buildActionTile(
                icon: Icons.sync,
                label: 'reset_calendar'.tr,
                onTap: () async {
                  final bool confirm = await _showConfirmDialog(
                    context,
                    title: 'รีเซ็ตการเชื่อมต่อ Calendar',
                    message: 'ระบบจะยกเลิกสิทธิ์และขอ Token ใหม่ คุณต้องการดำเนินการต่อหรือไม่?',
                  );
                  if (confirm) {
                    Get.snackbar('รีเซ็ต Calendar', 'ยกเลิกการเชื่อมต่อสำเร็จ กรุณาล็อกอินใหม่', 
                      snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
              
              const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)),
              
              // --- Section 2: AI Settings ---
              Text('การปรับระดับ AI ช่วยจำ', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
              const SizedBox(height: 16),
              
              Obx(() => _buildSwitchTile(
                    label: 'ai_memory'.tr,
                    value: settingsCtrl.aiMemoryEnabled.value,
                    onChanged: (bool val) => settingsCtrl.toggleAiMemory(val),
                  )),
              
              const SizedBox(height: 16),
              _buildAiStyleDropdown(settingsCtrl),
              
              const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)),
              
              // --- Section 3: Account & Security ---
              Text('การตั้งค่าความปลอดภัยและบัญชี', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
              const SizedBox(height: 16),
              
              Obx(() => _buildInfoTile(
                    icon: Icons.email,
                    label: 'current_email'.tr,
                    value: authCtrl.currentUser.value?.email ?? 'ไม่ได้ล็อกอิน',
                  )),
              
              const SizedBox(height: 20),
              _buildSignOutButton(context, authCtrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppTheme.accentSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary))),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String label, required bool value, required Function(bool) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary))),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.accentPrimary),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppTheme.accentSecondary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiStyleDropdown(SettingsController settingsCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('ai_behavior'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<int>(
              value: settingsCtrl.aiAggressionLevel.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('สุภาพ (Polite Jarvis)')),
                DropdownMenuItem(value: 1, child: Text('เป็นกันเอง (Friendly)')),
                DropdownMenuItem(value: 2, child: Text('กระตุ้นแรง (Aggressive)')),
              ],
              onChanged: (int? val) {
                if (val != null) {
                  settingsCtrl.setAiAggressionLevel(val);
                  Get.snackbar('อัปเดตสไตล์ AI', 'เปลี่ยนเป็น ${settingsCtrl.personalityLabel} แล้ว', 
                    snackPosition: SnackPosition.BOTTOM);
                }
              },
            )),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthController authCtrl) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final bool confirm = await _showConfirmDialog(
            context,
            title: 'sign_out_confirm'.tr,
            message: 'คุณต้องการออกจากระบบและล้าง Session หรือไม่?',
          );
          if (confirm) { await authCtrl.signOut(); }
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text('sign_out'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context, {required String title, required String message}) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr, style: const TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPrimary),
                child: Text('confirm'.tr, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

