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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_available, color: AppTheme.accentPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                'incoming_work'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (calendarCtrl.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'no_tasks'.tr,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: timeUntil.inHours < 24 ? Colors.red.shade300 : Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: timeUntil.inHours < 24 ? Colors.red : AppTheme.accentPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(event.startTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: timeUntil.inHours < 24
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppTheme.accentPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              urgencyLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: timeUntil.inHours < 24 ? Colors.red : AppTheme.accentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
