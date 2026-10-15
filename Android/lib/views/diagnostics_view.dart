/// lib/views/diagnostics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';

class DiagnosticsView extends StatelessWidget {
  const DiagnosticsView({super.key});
  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final calCtrl = Get.find<CalendarController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(title: const Text('Diagnostics'), centerTitle: true, backgroundColor: const Color(0xFF1E293B), foregroundColor: const Color(0xFFF8FAFC)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Obx(() => Text('Firebase: ' + authCtrl.connectionStatus.value, style: const TextStyle(color: Colors.white))),
            const SizedBox(height: 12),
            Obx(() => Text('Calendar: ' + calCtrl.calendarConnectionStatus.value, style: const TextStyle(color: Colors.white))),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => authCtrl.checkExistingSession(), child: const Text('Check Session')),
            ElevatedButton(onPressed: () => authCtrl.signInWithGoogle(), child: const Text('Sign In')),
            ElevatedButton(onPressed: () => calCtrl.fetchEvents(), child: const Text('Sync Calendar')),
            const SizedBox(height: 24),
            Obx(() => Text('Events: ' + calCtrl.events.length.toString(), style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}