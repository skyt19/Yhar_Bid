library;

/// lib/views/dashboard_home_view.dart
/// [Mockup 3_Main.jpg] — Dashboard หลักตาม Wireframe
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/incoming_work_card.dart';
import 'widgets/work_in_week_card.dart';
import 'widgets/add_task_dialog.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarCtrl = Get.find<CalendarController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accentPrimary),
            onPressed: () async {
              await calendarCtrl.fetchEvents();
              Get.snackbar('Success', 'Calendar synced', snackPosition: SnackPosition.TOP);
            },
            tooltip: 'Sync Calendar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Expanded(child: IncomingWorkCard()),
                SizedBox(width: 16),
                Expanded(child: WorkInWeekCard()),
              ],
            ),
            const SizedBox(height: 24),
            _buildCalendarContainer(calendarCtrl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const AddTaskDialog()),
        backgroundColor: AppTheme.accentPrimary,
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarContainer(CalendarController calendarCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Calendar API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () async {
                  await calendarCtrl.fetchEvents();
                  Get.snackbar('Success', 'Synced', snackPosition: SnackPosition.BOTTOM);
                },
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Sync'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSecondary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: calendarCtrl.focusedDay.value,
                selectedDayPredicate: (DateTime day) => isSameDay(calendarCtrl.selectedDay.value, day),
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) => calendarCtrl.selectDay(selectedDay, focusedDay),
                calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: AppTheme.accentPrimary.withOpacity(0.5), shape: BoxShape.circle), selectedDecoration: const BoxDecoration(color: AppTheme.accentPrimary, shape: BoxShape.circle)),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                eventLoader: (DateTime day) => calendarCtrl.getEventsForDay(day),
              )),
        ],
      ),
    );
  }
}

