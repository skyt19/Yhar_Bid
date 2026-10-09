/// lib/views/dashboard/dashboard_view.dart
/// Dashboard — Strictly Matches assets/mockups2/หน้าเเรก.jpg
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.find<CalendarController>();
    final authCtrl = Get.find<AuthController>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2-column grid (Left + Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN
              Expanded(
                child: Column(
                  children: [
                    _buildTaskCard('(task)', true),
                    const SizedBox(height: 16),
                    _buildIncomingWorkSection(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // RIGHT COLUMN
              Expanded(
                child: Column(
                  children: [
                    _buildTaskCard('(task)', true),
                    const SizedBox(height: 16),
                    _buildWeekTaskCard(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom: Calendar API Section
          _buildCalendarApiSection(calCtrl, authCtrl),
        ],
      ),

  // Task Card with Toggle (White background)
  Widget _buildTaskCard(String title, bool toggleValue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceGray, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              const Text(
                '(Time)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              _buildToggleSwitch(toggleValue),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Toggle Switch (Green when ON, Gray when OFF)
  Widget _buildToggleSwitch(bool value) {
    return Container(
      width: 52,
      height: 28,
      decoration: BoxDecoration(
        color: value ? AppTheme.accentPrimary : AppTheme.accentSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),

  // Incoming Work Section (Dark Gray Background)
  Widget _buildIncomingWorkSection() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: const Center(
        child: Text(
          'Incoming Work\n(On Day)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  // Word in Week Task Card (White + Dark Gray section)
  Widget _buildWeekTaskCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium),
                topRight: Radius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'word in week (task)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      '(Time)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildToggleSwitch(true),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '',
                style: TextStyle(color: AppTheme.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calendar API Section (Full Width Dark Gray)
  Widget _buildCalendarApiSection(CalendarController calCtrl, AuthController authCtrl) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Calendar API',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (authCtrl.currentUser.value == null) {
              return _buildSignInButton(authCtrl);
            }
            return const Text(
              'Synced',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.accentPrimary,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ],
      ),
    );
  }

  // Sign In Button (White pill with Google icon)
  Widget _buildSignInButton(AuthController authCtrl) {
    return ElevatedButton.icon(
      onPressed: () => authCtrl.signInWithGoogle(),
      icon: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF4285F4),
              Color(0xFFEA4335),
              Color(0xFFFBBC05),
              Color(0xFF34A853),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      label: const Text(
        'Sign in Google Calendar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surfaceLight,
        foregroundColor: AppTheme.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        elevation: 0,
      ),
    );
  }
}


        ),
      ),
    );
  }

    );
  }
