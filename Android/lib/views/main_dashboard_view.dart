library;

/// lib/views/main_dashboard_view.dart
/// [Mockup 3_Main.jpg] — หน้า Dashboard หลัก: 5 แท็บ (Dashboard + AI + Calendar + Tasks + Settings)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/ai_controller.dart';
import '../controllers/task_controller.dart';
import 'theme/app_theme.dart';
import 'dashboard_home_view.dart';
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
    if (!Get.isRegistered<TaskController>()) Get.put<TaskController>(TaskController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CalendarController calendarCtrl = Get.find<CalendarController>();
      if (calendarCtrl.events.isEmpty) calendarCtrl.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const DashboardHomeView(),
      const AiChatbotView(),
      const CalendarView(),
      const HabitTrackerView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final List<_NavItem> items = <_NavItem>[
      _NavItem(icon: Icons.dashboard_rounded, labelKey: 'dashboard'),
      _NavItem(icon: Icons.psychology_outlined, labelKey: 'ai_assistant'),
      _NavItem(icon: Icons.calendar_month_outlined, labelKey: 'calendar'),
      _NavItem(icon: Icons.assignment_outlined, labelKey: 'tasks_manage'),
      _NavItem(icon: Icons.settings_outlined, labelKey: 'settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusLarge), topRight: Radius.circular(AppTheme.radiusLarge)),
        boxShadow: <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, -3))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(items.length, (int index) {
          final bool isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.cardLight : AppTheme.cardLight.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: isSelected ? <BoxShadow>[BoxShadow(color: AppTheme.accentPrimary.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: 2)] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(items[index].icon, color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary, size: 24),
                  const SizedBox(height: 4),
                  Text(items[index].labelKey.tr, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String labelKey;
  const _NavItem({required this.icon, required this.labelKey});
}

