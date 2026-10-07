/// lib/views/calendar_view.dart
/// [Mockup 5] — Calendar View with table_calendar
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_event_model.dart';
import 'theme/app_theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calCtrl = Get.find<CalendarController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), onPressed: calCtrl.fetchEvents),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusMedium), topRight: Radius.circular(AppTheme.radiusMedium)),
          ),
          child: Obx(() {
            if (calCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: <Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                  child: const Text('โปรดล็อกอินเข้าอีเมลที่ต้องการให้สร้างงาน (อีเมลที่มีเนื้อหาในปฏิทิน)',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TableCalendar<CalendarEventModel>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: calCtrl.focusedDay.value,
                    selectedDayPredicate: (DateTime day) => isSameDay(calCtrl.selectedDay.value, day),
                    calendarFormat: CalendarFormat.month,
                    eventLoader: calCtrl.getEventsForDay,
                    onDaySelected: (DateTime selected, DateTime focused) {
                      calCtrl.selectDay(selected, focused);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: AppTheme.accentPrimary.withOpacity(0.3), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: AppTheme.accentPrimary, shape: BoxShape.circle),
                      markerDecoration: const BoxDecoration(color: AppTheme.accentSecondary, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: calCtrl.getEventsForDay(calCtrl.selectedDay.value).length,
                    itemBuilder: (BuildContext ctx, int i) {
                      final CalendarEventModel event = calCtrl.getEventsForDay(calCtrl.selectedDay.value)[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(DateFormat('HH:mm').format(event.startTime), style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            if (event.description != null && event.description!.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(event.description!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
