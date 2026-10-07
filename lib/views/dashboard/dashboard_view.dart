/// lib/views/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.find<CalendarController>();
    final authCtrl = Get.find<AuthController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authCtrl.currentUser.value == null) _buildSignInBanner(authCtrl),
          if (authCtrl.currentUser.value == null) const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Deadlines', '3', Icons.event, const Color(0xFF38BDF8))),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard('Tasks', '7', Icons.task_alt, const Color(0xFFF97316))),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard('AI Tips', '2', Icons.lightbulb, const Color(0xFF4FD1C5))),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildAgendaPanel(calCtrl)),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildAIPanel()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInBanner(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF4FD1C5)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Sign in with Google to unlock AI features',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => authCtrl.signInWithGoogle(),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildAgendaPanel(CalendarController calCtrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('This Week Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => calCtrl.fetchEvents(),
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Sync'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (calCtrl.isLoading.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF38BDF8))));
            }
            if (calCtrl.events.isEmpty) {
              return Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('No events', style: TextStyle(color: Color(0xFF94A3B8)))));
            }
            return Column(
              children: calCtrl.events.take(5).map((e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Container(width: 4, height: 48, decoration: BoxDecoration(color: const Color(0xFF38BDF8), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF8FAFC))),
                    Text('${e.startTime.day}/${e.startTime.month}', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ])),
                ]),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAIPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF4FD1C5)]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.smart_toy, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              const Text('Yharbid AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
            ],
          ),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(hintText: 'Ask me...', hintStyle: const TextStyle(color: Color(0xFF64748B)), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), suffixIcon: const Icon(Icons.send, color: Color(0xFF38BDF8))), style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          _buildAISuggestion('Summarize meetings', Icons.calendar_today),
          const SizedBox(height: 8),
          _buildAISuggestion('Create checklist', Icons.checklist),
        ],
      ),
    );
  }

  Widget _buildAISuggestion(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Icon(icon, color: const Color(0xFF94A3B8), size: 18), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))]),
    );
  }
}

