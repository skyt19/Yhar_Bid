library;

/// lib/views/calendar_view.dart
/// Redesigned Calendar: Preparation coverage visualization with AI insights
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/proactive_controller.dart';
import '../controllers/prepared_plan_controller.dart';
import '../models/calendar_event_model.dart';
import 'theme/app_theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calCtrl = Get.find<CalendarController>();
    final ProactiveController proactiveCtrl = Get.find<ProactiveController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: AppTheme.accentGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'calendar'.tr,
              style: AppTheme.titleLarge,
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: <Widget>[
          // Sync button
          TextButton.icon(
            onPressed: () async {
              await calCtrl.fetchEvents();
              if (calCtrl.errorMessage.value.isEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${'calendar_synced'.tr}: ${calCtrl.events.length} ${'events_found'.tr}',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('sync'.tr),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide ? _buildWideLayout(calCtrl, proactiveCtrl) : _buildNarrowLayout(calCtrl, proactiveCtrl),
    );
  }

  Widget _buildWideLayout(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Calendar with preparation coverage
        Expanded(
          flex: 6,
          child: _buildCalendarPanel(calCtrl, proactiveCtrl),
        ),
        const SizedBox(width: 24),
        // Right: Event list and preparation status
        Expanded(
          flex: 4,
          child: _buildEventListPanel(calCtrl, proactiveCtrl),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendarPanel(calCtrl, proactiveCtrl),
          const SizedBox(height: 24),
          _buildEventListPanel(calCtrl, proactiveCtrl),
        ],
      ),
    );
  }

  Widget _buildCalendarPanel(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Obx(() {
        if (calCtrl.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month/Year header with preparation coverage summary
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(calCtrl.focusedDay.value),
                        style: AppTheme.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final eventsThisMonth = calCtrl.events.where((e) =>
                          e.startTime.month == calCtrl.focusedDay.value.month &&
                          e.startTime.year == calCtrl.focusedDay.value.year
                        ).length;
                        // Get approved prepared plans (actual PreparedPlanModel)
                        final preparedCtrl = Get.find<PreparedPlanController>();
                        final preparedCount = preparedCtrl.allPlans.where((p) =>
                          p.eventDateTime.month == calCtrl.focusedDay.value.month &&
                          p.eventDateTime.year == calCtrl.focusedDay.value.year
                        ).length;

                        return Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: AppTheme.accentGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$preparedCount / $eventsThisMonth prepared',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                // Month navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final newFocused = DateTime(
                          calCtrl.focusedDay.value.year,
                          calCtrl.focusedDay.value.month - 1,
                        );
                        calCtrl.focusedDay.value = newFocused;
                      },
                      icon: const Icon(Icons.chevron_left),
                      color: AppTheme.textSecondary,
                    ),
                    IconButton(
                      onPressed: () {
                        final newFocused = DateTime(
                          calCtrl.focusedDay.value.year,
                          calCtrl.focusedDay.value.month + 1,
                        );
                        calCtrl.focusedDay.value = newFocused;
                      },
                      icon: const Icon(Icons.chevron_right),
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Calendar with preparation coverage markers
            TableCalendar<CalendarEventModel>(
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
                  color: AppTheme.accentGreen.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentGreen, width: 2),
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                defaultTextStyle: AppTheme.bodyMedium,
                weekendTextStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                todayTextStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
                selectedTextStyle: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                outsideTextStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
              headerVisible: false,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                weekendStyle: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEventListPanel(CalendarController calCtrl, ProactiveController proactiveCtrl) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected day header
          Obx(() {
            final selectedDay = calCtrl.selectedDay.value;
            final isToday = isSameDay(selectedDay, DateTime.now());

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                          ),
                          child: Text(
                            'Today',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.accentGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (isToday) const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE').format(selectedDay),
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('d MMMM yyyy').format(selectedDay),
                    style: AppTheme.displayMedium,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Events for selected day
          Obx(() {
            final events = calCtrl.getEventsForDay(calCtrl.selectedDay.value);

            if (events.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_events_for_this_day'.tr,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: events.map((event) => _buildEventCard(event, proactiveCtrl)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEventModel event, ProactiveController proactiveCtrl) {
    // Check if event has a prepared plan
    try {
      final preparedCtrl = Get.find<PreparedPlanController>();
      final hasPlan = preparedCtrl.allPlans.any((p) => p.eventId == event.id);
    } catch (e) {
      // PreparedPlanController not initialized
    }
    final hasPlan = false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: hasPlan
            ? AppTheme.accentGreen.withOpacity(0.3)
            : AppTheme.borderColor,
          width: hasPlan ? 2 : 1,
        ),
        boxShadow: hasPlan ? [
          BoxShadow(
            color: AppTheme.accentGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getEventColor(event),
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
                      style: AppTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(event.startTime),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasPlan)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppTheme.accentGreen,
                  ),
                ),
            ],
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              event.description!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _getEventColor(CalendarEventModel event) {
    // Color based on event proximity
    final now = DateTime.now();
    final diff = event.startTime.difference(now);

    if (diff.inHours < 0) return AppTheme.textTertiary; // Past
    if (diff.inHours < 2) return AppTheme.accentRed; // Urgent
    if (diff.inHours < 24) return AppTheme.accentOrange; // Soon
    return AppTheme.accentGreen; // Prepared
  }
}
