library;

/// lib/views/calendar_view.dart
/// [Mockup 5_CalendarManage.jpg] — Calendar View with Google Calendar Integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/calendar_event_model.dart';
import 'theme/app_theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calCtrl = Get.find<CalendarController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('calendar'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await calCtrl.fetchEvents();
              if (calCtrl.errorMessage.value.isEmpty) {
                Get.snackbar(
                  'calendar_synced'.tr,
                  '${calCtrl.events.length} ${'events_found'.tr}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.accentGray,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: <Widget>[
            // Calendar Title Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.calendar_month, color: AppTheme.accentGreen, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'calendar'.tr.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calendar Widget Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Obx(() {
                  if (calCtrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      // TableCalendar Widget
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
                            todayDecoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppTheme.accentGreen,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: AppTheme.accentGray,
                              shape: BoxShape.circle,
                            ),
                            // Fix calendar readability: white text on dark background
                            defaultTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Color(0xFF86EFAC), // Light green for weekends
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            outsideTextStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.38),
                              fontSize: 13,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            weekendStyle: TextStyle(
                              color: Color(0xFF86EFAC),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Upcoming Tasks & Week Summary Cards (Multi-Calendar Data)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            // Card 1: Upcoming Tasks (งานที่กำลังจะมาถึง)
                            _buildUpcomingTasksCard(calCtrl),
                            const SizedBox(height: 12),
                            // Card 2: Tasks Within Week (งานในสัปดาห์นี้)
                            _buildWeekSummaryCard(calCtrl),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Events List for Selected Day
                      Expanded(
                        child: calCtrl.getEventsForDay(calCtrl.selectedDay.value).isEmpty
                            ? Center(
                                child: Text(
                                  'no_events'.tr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: calCtrl.getEventsForDay(calCtrl.selectedDay.value).length,
                                itemBuilder: (BuildContext ctx, int i) {
                                  final CalendarEventModel event =
                                      calCtrl.getEventsForDay(calCtrl.selectedDay.value)[i];
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
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('HH:mm').format(event.startTime),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        if (event.description != null && event.description!.isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 6),
                                          Text(
                                            event.description!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
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
            const SizedBox(height: 16),

            // Login/Connect Button (ตาม mockup 5_CalendarManage.jpg)
            Obx(() {
              final bool isConnected = authCtrl.currentUser.value != null &&
                  authCtrl.currentUser.value!.email.isNotEmpty;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isConnected ? AppTheme.accentGray : AppTheme.cardLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: InkWell(
                  onTap: isConnected
                      ? null
                      : () async {
                          // เชื่อมต่อ Google Calendar
                          await authCtrl.signInWithGoogle();
                          // ตรวจสอบว่า login สำเร็จ
                          if (authCtrl.currentUser.value != null) {
                            await calCtrl.fetchEvents();
                            Get.snackbar(
                              'calendar_connected'.tr,
                              '${calCtrl.events.length} ${'events_found'.tr}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.accentGray,
                              colorText: Colors.white,
                            );
                          }
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        isConnected ? Icons.check_circle : Icons.login,
                        color: isConnected ? Colors.white : AppTheme.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          isConnected
                              ? '${'current_email'.tr}: ${authCtrl.currentUser.value!.email}'
                              : 'calendar_login_prompt'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: isConnected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Upcoming Tasks Card (งานที่กำลังจะมาถึง) - Real Multi-Calendar Data
  Widget _buildUpcomingTasksCard(CalendarController calCtrl) {
    final DateTime now = DateTime.now();
    final List<CalendarEventModel> upcomingEvents = calCtrl.events
        .where((CalendarEventModel e) => e.startTime.isAfter(now))
        .take(5)
        .toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.upcoming, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'งานที่กำลังจะมาถึง',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (upcomingEvents.isEmpty)
            Text('ไม่มีงานที่กำลังจะมาถึง', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))
          else
            ...upcomingEvents.map((CalendarEventModel event) {
              final int daysUntil = event.startTime.difference(now).inDays;
              final String timeText = daysUntil == 0
                  ? 'วันนี้ ${DateFormat('HH:mm').format(event.startTime)}'
                  : daysUntil == 1
                      ? 'พรุ่งนี้ ${DateFormat('HH:mm').format(event.startTime)}'
                      : 'อีก $daysUntil วัน';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: daysUntil <= 1 ? Colors.red : AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeText,
                      style: TextStyle(fontSize: 12, color: daysUntil <= 1 ? Colors.red : AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  /// Week Summary Card (งานในสัปดาห์นี้) - Real Metrics
  Widget _buildWeekSummaryCard(CalendarController calCtrl) {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));
    
    final List<CalendarEventModel> weekEvents = calCtrl.events
        .where((CalendarEventModel e) =>
            e.startTime.isAfter(weekStart) && e.startTime.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();
    
    final int total = weekEvents.length;
    final int completed = weekEvents.where((CalendarEventModel e) => e.startTime.isBefore(now)).length;
    final int pending = total - completed;
    final double successRate = total > 0 ? (completed / total * 100) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.calendar_view_week, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'งานในสัปดาห์นี้',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _metricItem('ทั้งหมด', total.toString(), AppTheme.accentGray),
              _metricItem('รอดำเนินการ', pending.toString(), Colors.orange),
              _metricItem('เสร็จแล้ว', completed.toString(), AppTheme.accentGreen),
              _metricItem('สำเร็จ', '${successRate.toStringAsFixed(0)}%', AppTheme.accentGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

