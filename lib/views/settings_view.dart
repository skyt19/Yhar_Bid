/// lib/views/settings_view.dart
/// Settings Screen — Account info, preferences, navigation
/// Operate mode: clear grouping, warm neutral, preserved existing behavior
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import '../main.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Page title
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppTheme.space20, top: AppTheme.space4),
                    child: Text('การตั้งค่า', style: AppTheme.titleLarge),
                  ),

                  // Profile card
                  Obx(() => _buildProfileCard(authCtrl)),

                  const SizedBox(height: AppTheme.space20),

                  // General settings
                  _sectionLabel('ทั่วไป'),
                  const SizedBox(height: AppTheme.space8),
                  _buildSettingsGroup([
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      label: 'ภาษา',
                      trailing: Obx(() => Text(
                            settingsCtrl.languageCode.value == 'th'
                                ? 'ไทย'
                                : 'English',
                            style: AppTheme.bodyMedium,
                          )),
                      onTap: () {
                        Get.updateLocale(
                          Get.locale?.languageCode == 'th'
                              ? const Locale('en', 'US')
                              : const Locale('th', 'TH'),
                        );
                        settingsCtrl.toggleLanguage();
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'การแจ้งเตือน',
                      onTap: () =>
                          Get.toNamed(AppRoutes.notificationSettings),
                    ),
                  ]),

                  const SizedBox(height: AppTheme.space20),

                  // AI settings
                  _sectionLabel('AI และการเตรียมงาน'),
                  const SizedBox(height: AppTheme.space8),
                  _buildSettingsGroup([
                    Obx(() {
                      final p = Get.find<AuthController>()
                          .currentUser
                          .value
                          ?.personality;
                      return _SettingsTile(
                        icon: Icons.psychology_outlined,
                        label: 'บุคลิก AI',
                        subtitle: _personalityName(p),
                        onTap: () => Get.toNamed(AppRoutes.aiPersonality),
                      );
                    }),
                  ]),

                  const SizedBox(height: AppTheme.space20),

                  // Advanced
                  _sectionLabel('ขั้นสูง'),
                  const SizedBox(height: AppTheme.space8),
                  _buildSettingsGroup([
                    _SettingsTile(
                      icon: Icons.tune_rounded,
                      label: 'การตั้งค่าขั้นสูง',
                      onTap: () => Get.toNamed(AppRoutes.advancedSettings),
                    ),
                  ]),

                  const SizedBox(height: AppTheme.space20),

                  // Account
                  _sectionLabel('บัญชี'),
                  const SizedBox(height: AppTheme.space8),
                  _buildSettingsGroup([
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: 'ออกจากระบบ',
                      textColor: AppTheme.accentRed,
                      iconColor: AppTheme.accentRed,
                      onTap: () => _confirmSignOut(authCtrl),
                    ),
                  ]),

                  const SizedBox(height: AppTheme.space32),

                  // App version
                  Center(
                    child: Text(
                      'Yharbid — Adaptive Routine & Reminder Assistant',
                      style: AppTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Center(
                    child: Text(
                      'openai/gpt-oss-20b · Firebase Spark',
                      style: AppTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Profile card ─────────────────────────────────────────────────────────

  Widget _buildProfileCard(AuthController authCtrl) {
    final user = authCtrl.currentUser.value;
    if (user == null) {
      return Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  size: 24, color: AppTheme.textTertiary),
            ),
            const SizedBox(width: AppTheme.space12),
            const Text('ยังไม่ได้เข้าสู่ระบบ',
                style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            ),
            child: user.photoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(user.displayName),
                    ),
                  )
                : _initials(user.displayName),
          ),
          const SizedBox(width: AppTheme.space12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: AppTheme.titleSmall),
                const SizedBox(height: AppTheme.space2),
                Text(user.email, style: AppTheme.bodySmall),
                const SizedBox(height: AppTheme.space4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space8, vertical: AppTheme.space2),
                  decoration: AppTheme.statusBadgeDecoration(AppTheme.accentGreen),
                  child: Text(
                    _roleName(user.role),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : 'U';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentGreenDark,
          fontFamily: 'NotoSansThai',
        ),
      ),
    );
  }

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'นักศึกษา';
      case UserRole.corporateEmployee:
        return 'พนักงาน';
      case UserRole.educator:
        return 'ครูผู้สอน';
    }
  }

  String _personalityName(AiPersonality? p) {
    switch (p) {
      case AiPersonality.politeJarvis:
        return 'Polite Jarvis';
      case AiPersonality.friendly:
        return 'Friendly';
      case AiPersonality.aggressiveMotivator:
        return 'Aggressive Motivator';
      default:
        return '';
    }
  }

  // ─── Section helpers ──────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.space4),
      child: Text(
        label,
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              const Divider(
                  height: 1,
                  color: AppTheme.dividerColor,
                  indent: AppTheme.space52,
                  endIndent: AppTheme.space16),
          ],
        ],
      ),
    );
  }

  void _confirmSignOut(AuthController authCtrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: const Text('ออกจากระบบ', style: AppTheme.titleMedium),
        content: const Text(
          'ต้องการออกจากระบบใช่ไหม?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authCtrl.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}

// ─── Tile component ────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space16, vertical: AppTheme.space14),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: iconColor ?? AppTheme.textSecondary),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? AppTheme.textPrimary,
                        fontFamily: 'NotoSansThai',
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.space2),
                      Text(subtitle!, style: AppTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.textTertiary)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
