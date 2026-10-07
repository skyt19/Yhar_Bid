import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'dashboard/dashboard_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});
  
  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const DashboardView(),
    const Center(child: Text('Schedule', style: TextStyle(color: Colors.white, fontSize: 24))),
    const Center(child: Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 24))),
    const Center(child: Text('Tasks', style: TextStyle(color: Colors.white, fontSize: 24))),
    const Center(child: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24))),
  ];
  
  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          _buildSidebar(authCtrl),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthController authCtrl) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Color(0xFF334155), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF4FD1C5)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('Yharbid AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
            ],
          ),
          const SizedBox(height: 48),
          _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
          _buildMenuItem(1, Icons.calendar_today, 'Schedule'),
          _buildMenuItem(2, Icons.smart_toy, 'AI Assistant'),
          _buildMenuItem(3, Icons.task_alt, 'Tasks'),
          _buildMenuItem(4, Icons.settings, 'Settings'),
          const Spacer(),
          Obx(() => _buildUserProfile(authCtrl)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }


  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8), size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(AuthController authCtrl) {
    if (authCtrl.currentUser.value == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Text('Not signed in', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => authCtrl.signInWithGoogle(),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign In', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(authCtrl.currentUser.value!.photoUrl), radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(authCtrl.currentUser.value!.displayName.split(' ').first, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF8FAFC)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(_getRoleLabel(authCtrl.currentUser.value!.role), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          IconButton(onPressed: () => authCtrl.signOut(), icon: const Icon(Icons.logout, color: Color(0xFF94A3B8), size: 20)),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.student: return 'Student';
      case UserRole.corporateEmployee: return 'Employee';
      case UserRole.educator: return 'Educator';
    }
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Color(0xFF1E293B), border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1))),
      child: Row(
        children: [
          Text(_getPageTitle(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFF8FAFC))),
          const SizedBox(width: 16),
          Text(_getCurrentDate(), style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          const Spacer(),
          Obx(() {
            final authCtrl = Get.find<AuthController>();
            return Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: authCtrl.isFirebaseConnected.value ? const Color(0xFF22C55E) : const Color(0xFF94A3B8), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('Connected', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            );
          }),
          const SizedBox(width: 16),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 18), label: const Text('Add Task', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.white)),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Schedule';
      case 2: return 'AI Assistant';
      case 3: return 'Tasks';
      case 4: return 'Settings';
      default: return 'Yharbid';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

