import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/proactive_controller.dart';
import '../../models/calendar_event_model.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final calCtrl = Get.put(CalendarController());
    final authCtrl = Get.find<AuthController>();
    final proactiveCtrl = Get.put(ProactiveController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCalendar(calCtrl),
              const SizedBox(height: 20),
              Obx(() {
                if (authCtrl.currentUser.value == null) {
                  return _buildSignInSection(authCtrl);
                }
                return Column(
                  children: [
                    _buildUpcomingTasksCard(calCtrl, proactiveCtrl),
                    const SizedBox(height: 16),
                    _buildWeeklySummaryCard(calCtrl),
                    const SizedBox(height: 16),
                    _buildSelectedDayEventsCard(calCtrl, proactiveCtrl),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarController calCtrl) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white, // White calendar container
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9E9E9E), width: 1.5), // Gray border
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Light gray header
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF9E9E9E), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
                      onPressed: () {},
                    ),
                    const Text(
                      'Calendar 2026 (month)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Black text
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white, // White calendar table
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: calCtrl.focusedDay.value,
                  selectedDayPredicate: (day) => isSameDay(calCtrl.selectedDay.value, day),
                  onDaySelected: (selected, focused) => calCtrl.selectDay(selected, focused),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), // Green highlight for today
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF2E7D32), // Dark green for selected
                      shape: BoxShape.circle,
                    ),
                    // Black text on white background
                    defaultTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendTextStyle: const TextStyle(
                      color: Color(0xFF2E7D32), // Green for weekends
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.white, // White text on green circle
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white, // White text on green circle
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    outsideTextStyle: const TextStyle(
                      color: Colors.black26, // Light gray for outside days
                      fontSize: 13,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), // Green dot marker
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerSize: 6.0,
                  ),
                  headerVisible: false,
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF4CAF50), // Green for weekend labels
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  eventLoader: (day) {
                    // Show green dots on days with events or tasks
                    return calCtrl.events.where((e) => isSameDay(e.startTime, day)).toList();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  /// SPECIFICATION #4: "Upcoming Tasks" Card
  /// Display upcoming events (today + next 14 days) with AI preparation button
  Widget _buildUpcomingTasksCard(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Obx(() {
      final DateTime now = DateTime.now();
      final DateTime twoWeeksLater = now.add(const Duration(days: 14));
      final List<CalendarEventModel> upcomingEvents = calCtrl.events
          .where((CalendarEventModel e) => 
              e.startTime.isAfter(now) && e.startTime.isBefore(twoWeeksLater))
          .toList();

      if (upcomingEvents.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'ไม่มีงานที่กำลังจะมาถึง',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Light gray header
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF9E9E9E), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note, color: Colors.black87, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'งานที่กำลังจะมาถึง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Black text
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${upcomingEvents.length} งาน',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: upcomingEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final CalendarEventModel event = upcomingEvents[index];
                final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(event.startTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hide AI preparation button for read-only/holiday events
                      if (!event.isReadOnly)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              proactiveCtrl.runProactiveScan(specificEventId: event.id);
                            },
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('ให้เลขา AI เตรียมงาน'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFBC02D)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.event_busy, size: 14, color: Color(0xFFF57F17)),
                              SizedBox(width: 4),
                              Text(
                                'วันหยุด / ปฏิทินอ่านอย่างเดียว',
                                style: TextStyle(fontSize: 11, color: Color(0xFFF57F17), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  /// SPECIFICATION #4: "Tasks Within Week" Summary Card
  /// Display event count and weekly adherence metrics
  Widget _buildWeeklySummaryCard(CalendarController calCtrl) {
    return Obx(() {
      final DateTime now = DateTime.now();
      final DateTime weekLater = now.add(const Duration(days: 7));
      final List<CalendarEventModel> weekEvents = calCtrl.events
          .where((CalendarEventModel e) => 
              e.startTime.isAfter(now) && e.startTime.isBefore(weekLater))
          .toList();

      final int totalEvents = weekEvents.length;
      final int pendingCount = totalEvents;
      final double adherenceRate = calCtrl.calendarComplianceRate.value * 100;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'งานในสัปดาห์นี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      'ทั้งหมด',
                      totalEvents.toString(),
                      const Color(0xFF22D3EE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      'รอดำเนินการ',
                      pendingCount.toString(),
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      'ทำตามแผน',
                      '${adherenceRate.toStringAsFixed(0)}%',
                      const Color(0xFF4FD1C5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// SPECIFICATION #4: Selected Day Events Display
  /// Show events when tapping a specific date on the calendar
  Widget _buildSelectedDayEventsCard(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Obx(() {
      final DateTime selectedDate = calCtrl.selectedDay.value;
      final List<CalendarEventModel> dayEvents = calCtrl.getEventsForDay(selectedDate);

      if (dayEvents.isEmpty) {
        return const SizedBox.shrink();
      }

      final DateFormat headerFormatter = DateFormat('dd MMM yyyy');
      final DateFormat timeFormatter = DateFormat('HH:mm');

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    headerFormatter.format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dayEvents.length} งาน',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: dayEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final CalendarEventModel event = dayEvents[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeFormatter.format(event.startTime),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSignInSection(AuthController authCtrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF757575),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => authCtrl.signInWithGoogle(),
          icon: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFFEA4335),
                  Color(0xFFFBBC05),
                  Color(0xFF34A853),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          label: const Text(
            'Sign in Google Calendar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

