library;

/// lib/views/widgets/incoming_work_card.dart
/// Card แสดงงานที่กำลังจะถึง Deadline (Incoming Work)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/calendar_event_model.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class IncomingWorkCard extends StatelessWidget {
  const IncomingWorkCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarCtrl = Get.find<CalendarController>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadowCard,
      ),
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.event_available, color: AppTheme.accentGreen, size: 24),
              const SizedBox(width: AppTheme.space8),
              Text(
                'incoming_work'.tr,
                style: AppTheme.title18,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          Obx(() {
            if (calendarCtrl.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.space20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // กรอง Events ที่กำลังจะมาถึง (ภายใน 7 วัน)
            final DateTime now = DateTime.now();
            final DateTime sevenDaysLater = now.add(const Duration(days: 7));
            
            final List<CalendarEventModel> upcomingEvents = calendarCtrl.events
                .where((CalendarEventModel event) =>
                    event.startTime.isAfter(now) &&
                    event.startTime.isBefore(sevenDaysLater))
                .toList()
              ..sort((CalendarEventModel a, CalendarEventModel b) => a.startTime.compareTo(b.startTime));

            if (upcomingEvents.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space20),
                  child: Text(
                    'no_tasks'.tr,
                    style: AppTheme.bodyMedium,
                  ),
                ),
              );
            }

            // แสดง 3 งานแรก
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
              itemBuilder: (BuildContext context, int index) {
                final CalendarEventModel event = upcomingEvents[index];
                return _buildEventTile(event);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventTile(CalendarEventModel event) {
    final DateFormat dateFormat = DateFormat('dd MMM, HH:mm');
    final Duration timeUntil = event.startTime.difference(DateTime.now());
    final String urgencyLabel = timeUntil.inHours < 24
        ? 'urgent'.tr
        : timeUntil.inDays == 1
            ? 'tomorrow'.tr
            : '${timeUntil.inDays} ${'days_left'.tr}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space8),
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: timeUntil.inHours < 24 ? AppTheme.accentRed.withValues(alpha: 0.6) : AppTheme.accentGray,
          width: 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: timeUntil.inHours < 24 ? AppTheme.accentRed : AppTheme.accentGreen,
              borderRadius: BorderRadius.circular(AppTheme.space2),
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style: AppTheme.body15.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  dateFormat.format(event.startTime),
                  style: AppTheme.body13.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space8, vertical: AppTheme.space4),
            decoration: BoxDecoration(
              color: timeUntil.inHours < 24
                  ? AppTheme.accentRed.withValues(alpha: 0.1)
                  : AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Text(
              urgencyLabel,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: timeUntil.inHours < 24 ? AppTheme.accentRed : AppTheme.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

