import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/analytics_controller.dart';
import '../../models/calendar_event_model.dart';
import '../theme/app_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.find<CalendarController>();
    final authCtrl = Get.find<AuthController>();
    final proactiveCtrl = Get.find<ProactiveController>();
    final habitCtrl = Get.find<HabitController>();
    final analyticsCtrl = Get.find<AnalyticsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Yhar Bid — เลขานุการอัจฉริยะ (Proactive Secretary)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildFeatureTestSection(authCtrl, calCtrl, proactiveCtrl, habitCtrl, analyticsCtrl),
          const SizedBox(height: 16),
          _buildUpcomingEventsSection(calCtrl, proactiveCtrl),
          const SizedBox(height: 16),
          _buildProposalsSection(proactiveCtrl),
          const SizedBox(height: 16),
          _buildCalendarApiSection(calCtrl, authCtrl, proactiveCtrl),
        ],
      ),
    );
  }

  Widget _buildFeatureTestSection(AuthController authCtrl, CalendarController calCtrl, ProactiveController proactiveCtrl, HabitController habitCtrl, AnalyticsController analyticsCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                '🧪 ทดสอบ Features (FR-1 ถึง FR-6)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final user = authCtrl.currentUser.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureStatus('FR-1: Role Selection', user != null, 'Role: ${user?.role.name ?? "N/A"}'),
                _buildFeatureStatus('FR-2: Calendar Sync', calCtrl.events.isNotEmpty, 'Events: ${calCtrl.events.length}'),
                _buildFeatureStatus('FR-3: AI Preparation', proactiveCtrl.proposals.isNotEmpty, 'Proposals: ${proactiveCtrl.proposals.length}'),
                _buildFeatureStatus('FR-4: Habit Tracker', habitCtrl.habits.isNotEmpty, 'Habits: ${habitCtrl.habits.length}'),
                _buildFeatureStatus('FR-5: Notifications', false, 'Status: Not Implemented'),
                _buildFeatureStatus('FR-6: Analytics', true, 'Overall: ${analyticsCtrl.overallScore.toStringAsFixed(1)}%'),
              ],
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                await calCtrl.fetchEvents();
                await proactiveCtrl.runProactiveScan();
                await analyticsCtrl.calculateWeeklyAnalytics();
                Get.back();
                Get.snackbar('🎉 สำเร็จ', 'ทดสอบทุก Features เรียบร้อย!', snackPosition: SnackPosition.BOTTOM);
              },
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('🚀 ทดสอบทั้งหมด (Run All Tests)', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(String title, bool status, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.radio_button_unchecked,
            color: status ? Colors.white : Colors.white60,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $detail',
              style: TextStyle(fontSize: 12, color: status ? Colors.white : Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9E9E9E), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'งานที่กำลังจะมาถึง',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (calCtrl.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (calCtrl.events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'ไม่มีงานในขณะนี้\n(กรุณากด Sync เพื่อดึงข้อมูล)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              );
            }
            final upcomingEvents = calCtrl.events.take(5).toList();
            return Column(
              children: upcomingEvents.map((event) => _buildEventCard(event, proactiveCtrl)).toList(),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildEventCard(CalendarEventModel event, ProactiveController proactiveCtrl) {
    final startTime = DateFormat('dd/MM/yyyy HH:mm').format(event.startTime);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 4),
          Text('📅 $startTime', style: const TextStyle(fontSize: 13, color: Colors.black87)),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('📍 ${event.location}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(event.description!, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar('🤖 กำลังวิเคราะห์...', 'เลขานุการ AI กำลังเตรียมข้อเสนอสำหรับ: ${event.title}', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
                proactiveCtrl.runProactiveScan(specificEventId: event.id);
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('ให้เลขาเตรียมหัวข้อ (Gemma AI)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsSection(ProactiveController proactiveCtrl) {
    return Obx(() {
      final pendingProposals = proactiveCtrl.proposals.where((p) => p.status == PreparationStatus.pending).toList();
      if (pendingProposals.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFB74D), width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Color(0xFFFF6F00)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ข้อเสนอจากเลขานุการ AI (รอการตรวจสอบ)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...pendingProposals.map((proposal) => _buildProposalCard(proposal, proactiveCtrl)).toList(),
          ],
        ),
      );
    });
  }


  Widget _buildProposalCard(PreparationProposal proposal, ProactiveController proactiveCtrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📌 ${proposal.event.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
            child: Text(proposal.aiContent, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
          ),
          if (proposal.suggestedTasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('งานย่อยที่แนะนำ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 4),
            ...proposal.suggestedTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 13)),
                    Expanded(child: Text(task, style: const TextStyle(fontSize: 12, color: Colors.black54))),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => proactiveCtrl.rejectProposal(proposal.id),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('ปฏิเสธ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => proactiveCtrl.approveProposal(proposal.id),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('อนุมัติและนำไปใช้'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarApiSection(CalendarController calCtrl, AuthController authCtrl, ProactiveController proactiveCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF616161), width: 3),
      ),
      child: Column(
        children: [
          const Text('Calendar API', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  onPressed: calCtrl.isLoading.value ? null : () => calCtrl.fetchEvents(),
                  icon: calCtrl.isLoading.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sync),
                  label: Text(calCtrl.isLoading.value ? 'กำลังดึง...' : 'Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton.icon(
                  onPressed: proactiveCtrl.isScanning.value ? null : () => proactiveCtrl.runProactiveScan(),
                  icon: proactiveCtrl.isScanning.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.smart_toy),
                  label: Text(proactiveCtrl.isScanning.value ? 'กำลังวิเคราะห์...' : 'ให้เลขา AI วิเคราะห์ตารางงาน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => proactiveCtrl.statusMessage.value.isNotEmpty ? Text(proactiveCtrl.statusMessage.value, style: const TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center) : const SizedBox.shrink()),
          const SizedBox(height: 16),
          Obx(() => TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: calCtrl.focusedDay.value,
            selectedDayPredicate: (day) => isSameDay(calCtrl.selectedDay.value, day),
            onDaySelected: (selectedDay, focusedDay) {
              calCtrl.selectedDay.value = selectedDay;
              calCtrl.focusedDay.value = focusedDay;
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          )),
        ],
      ),
    );
  }
}



