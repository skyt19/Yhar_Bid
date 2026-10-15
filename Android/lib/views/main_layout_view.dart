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
      backgroundColor: const Color(0xFFCFD8DC), // Background สีฟ้าเทาตาม Mockup
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFD8DC),
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
          Obx(() => GestureDetector(
            onTap: settingsCtrl.toggleLanguage,
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
