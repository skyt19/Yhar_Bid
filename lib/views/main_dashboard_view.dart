/// lib/views/main_dashboard_view.dart
/// [Mockup 3_Main.jpg] — หน้า Dashboard หลัก: 2 Card บน (Incoming Work, Word in Week)
/// + ปุ่ม Calendar API ตรงกลาง + Bottom Nav 4 ปุ่มวงกลม
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/ai_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import '../main.dart';
import 'ai_chatbot_view.dart';
import 'calendar_view.dart';
import 'habit_tracker_view.dart';
import 'settings_view.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});
  @override
  State<MainDashboardView> createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  int _currentIndex = 0;

  // หน้าย่อยทั้ง 4 (AI, Calendar, จัดการงาน, ตั้งค่า)
  final List<Widget> _pages = <Widget>[
    const AiChatbotView(),
    const CalendarView(),
    const HabitTrackerView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    // ลงทะเบียน Controllers ที่ยังไม่มี
    if (!Get.isRegistered<CalendarController>()) Get.put<CalendarController>(CalendarController());
    if (!Get.isRegistered<HabitController>()) Get.put<HabitController>(HabitController());
    if (!Get.isRegistered<AiController>()) Get.put<AiController>(AiController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
