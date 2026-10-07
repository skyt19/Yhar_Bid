import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/navigation_controller.dart';
import 'dashboard/dashboard_view.dart';
import 'calendar/calendar_view.dart';
import 'ai/ai_workspace_view.dart';
import 'tasks/tasks_view.dart';
import 'settings_view.dart';

class MainLayoutView extends StatelessWidget {
  const MainLayoutView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.put(NavigationController());
    final authCtrl = Get.find<AuthController>();
    
    final List<Widget> pages = [const DashboardView(), const CalendarView(), const AIWorkspaceView(), const TasksView(), const SettingsView()];
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          _buildSidebar(navCtrl, authCtrl),
          Expanded(child: Obx(() => pages[navCtrl.currentIndex.value])),
        ],
      ),
    );
  }

  Widget _buildSidebar(NavigationController navCtrl, AuthController authCtrl) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(color: Color(0xFF1E293B), border: Border(right: BorderSide(color: Color(0xFF334155), width: 1))),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF4FD1C5)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.psychology, color: Colors.white, size: 28)),
            const SizedBox(width: 12),
            const Text('Yharbid AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
          ]),
          const SizedBox(height: 48),
          _buildMenuItem(navCtrl, 0, Icons.dashboard, 'Dashboard'),
          _buildMenuItem(navCtrl, 1, Icons.calendar_today, 'Calendar'),
          _buildMenuItem(navCtrl, 2, Icons.smart_toy, 'AI Workspace'),
          _buildMenuItem(navCtrl, 3, Icons.task_alt, 'Tasks'),
          _buildMenuItem(navCtrl, 4, Icons.settings, 'Settings'),
          const Spacer(),
          _buildUserProfile(authCtrl),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(NavigationController navCtrl, int index, IconData icon, String label) {
    return Obx(() {
      final isActive = navCtrl.currentIndex.value == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => navCtrl.changePage(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: isActive ? const Color(0xFF38BDF8) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [Icon(icon, color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 22), const SizedBox(width: 12), Text(label, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF94A3B8), fontSize: 15, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal))]),
          ),
        ),
      );
    });
  }

  Widget _buildUserProfile(AuthController authCtrl) {
    return Obx(() {
      final user = authCtrl.currentUser.value;
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          CircleAvatar(backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl) : null, backgroundColor: const Color(0xFF38BDF8), radius: 20, child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.displayName ?? 'User', style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 2), Text(user?.role.name ?? 'student', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))])),
        ]),
      );
    });
  }
}
