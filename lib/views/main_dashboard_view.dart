library;

/// lib/views/main_dashboard_view.dart
/// [Mockup 3_Main.jpg] — หน้า Dashboard หลัก: 2 Card บน + Calendar API Container ใหญ่ด้านล่าง
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/ai_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'calendar_view.dart';
import 'habit_tracker_view.dart';
import 'settings_view.dart';
import 'ai_chatbot_view.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});
  @override
  State<MainDashboardView> createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CalendarController>()) Get.put<CalendarController>(CalendarController());
    if (!Get.isRegistered<HabitController>()) Get.put<HabitController>(HabitController());
    if (!Get.isRegistered<AiController>()) Get.put<AiController>(AiController());
    
    // Auto-sync calendar เมื่อเปิดแอป
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CalendarController calendarCtrl = Get.find<CalendarController>();
      if (calendarCtrl.events.isEmpty) {
        calendarCtrl.fetchEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const AiChatbotView(), // หน้าที่ 1: AI จัสวีส (ตาม mockup)
      const CalendarView(),  // หน้าที่ 2: ปฏิทิน
      const HabitTrackerView(), // หน้าที่ 3: จัดการงาน
      const SettingsView(), // หน้าที่ 4: ตั้งค่า
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
