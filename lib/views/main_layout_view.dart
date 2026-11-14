/// lib/views/main_layout_view.dart
/// Main Layout with Bottom Navigation Bar (Mockup-Compliant Mobile-First Design)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/settings_controller.dart';
import 'dashboard_home_view.dart';
import 'calendar/calendar_view.dart';
import 'ai/ai_workspace_view.dart';
import 'tasks/tasks_view.dart';
import 'settings_view.dart';
import 'widgets/bottom_nav_bar.dart';
import 'theme/app_theme.dart';

class MainLayoutView extends StatelessWidget {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.put(NavigationController());
    final settingsCtrl = Get.find<SettingsController>();

    final List<Widget> pages = [
      const DashboardHomeView(), // ✅ Impeccable-overhauled home
      const CalendarView(),
      const AIWorkspaceView(),
      const TasksView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Image.asset(
          'assets/icon/app_icon.png',
          height: 28,
          errorBuilder: (_, __, ___) => const Text(
            'Yharbid',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        actions: [
          // SRS Test Lab button — keep for QA access
          IconButton(
            icon: const Icon(Icons.science_outlined, color: AppTheme.accentGreen, size: 20),
            tooltip: 'SRS Test Lab',
            onPressed: () => Get.toNamed('/srs-test-lab'),
          ),
          // Language toggle
          Obx(() => GestureDetector(
            onTap: () {
              Get.updateLocale(
                Get.locale?.languageCode == 'th'
                    ? const Locale('en', 'US')
                    : const Locale('th', 'TH'),
              );
              settingsCtrl.toggleLanguage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                settingsCtrl.languageCode.value == 'th' ? 'TH' : 'EN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() => pages[navCtrl.currentIndex.value]),
      bottomNavigationBar: Obx(() => AppBottomNavBar(
        currentIndex: navCtrl.currentIndex.value,
        onTap: navCtrl.changePage,
      )),
    );
  }
}

