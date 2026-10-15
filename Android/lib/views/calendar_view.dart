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
                  backgroundColor: AppTheme.accentSecondary,
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
                  const Icon(Icons.calendar_month, color: AppTheme.accentPrimary, size: 24),
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
                              color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppTheme.accentPrimary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: AppTheme.accentSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
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
                  color: isConnected ? AppTheme.accentSecondary : AppTheme.cardLight,
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
                              backgroundColor: AppTheme.accentSecondary,
                              colorText: Colors.white,
                            );
                          }
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        isConnected ? Icons.check_circle : Icons.login,
                        color: isConnected ? Colors.white : AppTheme.accentPrimary,
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
}
