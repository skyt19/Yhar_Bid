/// lib/main.dart
/// จุดเข้าหลักของแอปพลิเคชัน Yharbid
/// เริ่มต้น Firebase, Env Config และ Routing ผ่าน GetX
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/theme/app_theme.dart';
import 'views/login_view.dart';
import 'views/main_dashboard_view.dart';
import 'views/ai_chatbot_view.dart';
import 'views/calendar_view.dart';
import 'views/settings_view.dart';
import 'views/advanced_settings_view.dart';
import 'views/tos_view.dart';
import 'views/role_selection_view.dart';
import 'views/ai_personality_view.dart';
import 'views/proactive_task_view.dart';
import 'views/habit_tracker_view.dart';
import 'views/analytics_dashboard_view.dart';
import 'views/notification_settings_view.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // โหลด Environment Variables จาก .env (API keys, config)
  await dotenv.load(fileName: '.env');

  // ลงทะเบียน Global Controllers ก่อน runApp
  Get.put<AuthController>(AuthController());
  Get.put<SettingsController>(SettingsController());

  runApp(const YharbidApp());
}

class YharbidApp extends StatelessWidget {
  const YharbidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Yharbid',
      debugShowCheckedModeBanner: false,

      // Theme Engine — รองรับ Light/Dark ตาม Mockup
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Route Map ทุกหน้าของแอปพลิเคชัน
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const LoginView()),
        GetPage(name: AppRoutes.roleSelection, page: () => const RoleSelectionView()),
        GetPage(name: AppRoutes.aiPersonality, page: () => const AiPersonalityView()),
        GetPage(name: AppRoutes.dashboard, page: () => const MainDashboardView()),
        GetPage(name: AppRoutes.aiChatbot, page: () => const AiChatbotView()),
        GetPage(name: AppRoutes.calendar, page: () => const CalendarView()),
        GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
        GetPage(name: AppRoutes.advancedSettings, page: () => const AdvancedSettingsView()),
        GetPage(name: AppRoutes.tos, page: () => const TosView()),
        GetPage(name: AppRoutes.proactiveTask, page: () => const ProactiveTaskView()),
        GetPage(name: AppRoutes.habitTracker, page: () => const HabitTrackerView()),
        GetPage(name: AppRoutes.analytics, page: () => const AnalyticsDashboardView()),
        GetPage(name: AppRoutes.notificationSettings, page: () => const NotificationSettingsView()),
      ],
    );
  }
}

/// Route constants — ชื่อ Route ทุกหน้า
class AppRoutes {
  AppRoutes._();
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String aiPersonality = '/ai-personality';
  static const String dashboard = '/dashboard';
  static const String aiChatbot = '/ai-chatbot';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String advancedSettings = '/advanced-settings';
  static const String tos = '/tos';
  static const String proactiveTask = '/proactive-task';
  static const String habitTracker = '/habit-tracker';
  static const String analytics = '/analytics';
  static const String notificationSettings = '/notification-settings';
}
