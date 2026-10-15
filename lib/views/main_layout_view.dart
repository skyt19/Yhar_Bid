/// lib/views/main_layout_view.dart
/// Main Layout with Bottom Navigation Bar (Mockup-Compliant Mobile-First Design)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/settings_controller.dart';
import 'dashboard/dashboard_view.dart';
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
    final authCtrl = Get.find<AuthController>();
    final settingsCtrl = Get.find<SettingsController>();
    
    final List<Widget> pages = [
      const DashboardView(),
      const CalendarView(),
      const AIWorkspaceView(),
      const TasksView(),
      const SettingsView(),
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background สีเทาอบอุ่น (NO BLUE)
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'App V. xxx',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          // SRS Test Lab Button
          IconButton(
            icon: Icon(Icons.science, color: AppTheme.accentGreen),
            tooltip: 'SRS Test Lab',
            onPressed: () {
              Get.toNamed('/srs-test-lab');
            },
          ),
          Obx(() => GestureDetector(
            onTap: () {
              // Toggle locale between TH and EN
              Get.updateLocale(
                Get.locale?.languageCode == 'th' 
                  ? const Locale('en', 'US') 
                  : const Locale('th', 'TH')
              );
              settingsCtrl.toggleLanguage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 16),
              child: Text(
                settingsCtrl.languageCode.value == 'th' ? 'TH / EN' : 'EN / TH',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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

