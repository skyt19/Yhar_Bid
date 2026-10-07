/// lib/main.dart
/// จุดเข้าหลักของแอปพลิเคชัน Yharbid
/// เริ่มต้น Firebase, Env Config และ Routing ผ่าน GetX
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
import 'views/diagnostics_view.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/calendar_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลด .env พร้อม fallback ป้องกัน crash
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Using default configuration.');
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }
  
  // Register Controllers
  Get.put<SettingsController>(SettingsController());
  Get.put<AuthController>(AuthController());
  Get.put<CalendarController>(CalendarController());
  
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

      initialRoute: AppRoutes.diagnostics,
      getPages: [
        GetPage(name: AppRoutes.diagnostics, page: () => const DiagnosticsView()),
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
  static const String diagnostics = '/diagnostics';
  static const String test = '/test';
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

class ServiceTestView extends StatelessWidget {
  const ServiceTestView({super.key});
  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final CalendarController calCtrl = Get.find<CalendarController>();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Service Test'), centerTitle: true, backgroundColor: AppTheme.accentPrimary, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Obx(() => Text(authCtrl.currentUser.value != null ? 'Logged: ${authCtrl.currentUser.value!.email}' : 'Not logged in', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: authCtrl.isLoading.value ? null : () async => await authCtrl.signInWithGoogle(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: calCtrl.isLoading.value ? null : () async => await calCtrl.fetchEvents(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSecondary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sync Calendar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final bool success = await calCtrl.createEvent(title: 'Test Event', startTime: DateTime.now().add(const Duration(hours: 1)), endTime: DateTime.now().add(const Duration(hours: 2)), description: 'Created by Yharbid');
                Get.snackbar(success ? 'สำเร็จ' : 'ล้มเหลว', success ? 'สร้าง Event สำเร็จ' : calCtrl.errorMessage.value);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Create Test Event'),
            ),
            const SizedBox(height: 24),
            Obx(() => Expanded(
                  child: calCtrl.events.isEmpty
                      ? const Center(child: Text('No events'))
                      : ListView.builder(
                          itemCount: calCtrl.events.length,
                          itemBuilder: (BuildContext ctx, int i) {
                            final event = calCtrl.events[i];
                            return ListTile(leading: const Icon(Icons.event, color: AppTheme.accentPrimary), title: Text(event.title), subtitle: Text('${event.startTime.day}/${event.startTime.month}'));
                          },
                        ),
                )),
          ],
        ),
      ),
    );
  }
}

