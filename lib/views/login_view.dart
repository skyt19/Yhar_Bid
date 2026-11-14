/// lib/views/login_view.dart
/// Redesigned Login: Premium AI-powered preparation assistant identity
/// Split-screen composition with brand moment and functional sign-in
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Main split-screen layout
            isWide ? _buildWideLayout(authCtrl) : _buildNarrowLayout(authCtrl),

            // Language toggle - top right on all layouts
            Positioned(
              top: 24,
              right: 24,
              child: Obx(() => _buildLanguageToggle(settingsCtrl)),
            ),
          ],
        ),
      ),
    );
  }

  // Wide layout: Split-screen with brand moment + sign-in
  Widget _buildWideLayout(AuthController authCtrl) {
    return Row(
      children: [
        // Left: Brand moment - AI preparation identity
        Expanded(
          flex: 5,
          child: Container(
            color: AppTheme.surfaceLight,
            padding: const EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // AI Preparation icon cluster
                Row(
                  children: [
                    _buildPreparationIconTile(Icons.auto_awesome, AppTheme.accentGreen, 0),
                    const SizedBox(width: 12),
                    _buildPreparationIconTile(Icons.calendar_month, AppTheme.textSecondary, 100),
                    const SizedBox(width: 12),
                    _buildPreparationIconTile(Icons.check_circle, AppTheme.accentGreen, 200),
                  ],
                ),
                const SizedBox(height: 40),
                // Product promise
                Text(
                  'Yharbid',
                  style: AppTheme.displayLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI-powered preparation\nfor every calendar event',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                // Value proposition badges
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildValueBadge('Proactive Intelligence'),
                    _buildValueBadge('Step-by-step Plans'),
                    _buildValueBadge('Adaptive Personality'),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),

        // Right: Sign-in form
        Expanded(
          flex: 4,
          child: _buildSignInPanel(authCtrl),
        ),
      ],
    );
  }

  // Narrow layout: Vertical stack
  Widget _buildNarrowLayout(AuthController authCtrl) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(Get.context!).size.height - MediaQuery.of(Get.context!).padding.top - MediaQuery.of(Get.context!).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              // Top: Brand moment
              Container(
                width: double.infinity,
                color: AppTheme.surfaceLight,
                padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPreparationIconTile(Icons.auto_awesome, AppTheme.accentGreen, 0),
                        const SizedBox(width: 8),
                        _buildPreparationIconTile(Icons.calendar_month, AppTheme.textSecondary, 100),
                        const SizedBox(width: 8),
                        _buildPreparationIconTile(Icons.check_circle, AppTheme.accentGreen, 200),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Yharbid',
                      style: AppTheme.displayLarge.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.02,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI-powered preparation\nfor every calendar event',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Bottom: Sign-in form
              Expanded(
                child: _buildSignInPanel(authCtrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPanel(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // Sign-in heading
          Text(
            'Get Started',
            style: AppTheme.displayMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Connect your calendar and let AI\nprepare you for what\'s ahead',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Google Sign-In button
          Obx(() => ElevatedButton(
            onPressed: authCtrl.isLoading.value ? null : () async {
              await authCtrl.signInWithGoogle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: AppTheme.surfaceGray,
            ).copyWith(
              overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
            ),
            child: authCtrl.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google "G" logo representation
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4285F4), // Google Blue
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Continue with Google',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
          )),

          const SizedBox(height: 24),

          // Error message
          Obx(() => authCtrl.errorMessage.value.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.accentRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.accentRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authCtrl.errorMessage.value,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),

          const Spacer(flex: 2),

          // Privacy note
          Text(
            'By continuing, you agree to connect your Google Calendar.\nWe use it only to generate preparation plans.',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textTertiary,
              fontSize: 11,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationIconTile(IconData icon, Color color, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color == AppTheme.accentGreen
                  ? AppTheme.accentGreen.withOpacity(0.12)
                  : AppTheme.surfaceGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: color == AppTheme.accentGreen ? [
                  BoxShadow(
                    color: AppTheme.accentGreen.withOpacity(0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: AppTheme.borderStrong.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(SettingsController settingsCtrl) {
    return GestureDetector(
      onTap: settingsCtrl.toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: AppTheme.borderStrong.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          settingsCtrl.languageCode.value == 'th' ? 'TH / EN' : 'EN / TH',
          style: AppTheme.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
