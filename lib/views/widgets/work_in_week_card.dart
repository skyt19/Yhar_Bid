/// lib/views/widgets/work_in_week_card.dart
/// Card สรุปงานในสัปดาห์นี้ (Work in Week)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/calendar_event_model.dart';
import '../theme/app_theme.dart';

class WorkInWeekCard extends StatelessWidget {
  const WorkInWeekCard({super.key});

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
              Icon(Icons.calendar_month, color: AppTheme.accentSecondary, size: 24),
              const SizedBox(width: 8),
              Text(
                'work_in_week'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (calendarCtrl.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // คำนวณงานในสัปดาห์นี้
            final DateTime now = DateTime.now();
            final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

            final List<CalendarEventModel> weekEvents = calendarCtrl.events
                .where((CalendarEventModel event) =>
                    event.startTime.isAfter(startOfWeek) &&
                    event.startTime.isBefore(endOfWeek))
                .toList();

            final int totalTasks = weekEvents.length;
            final int completedTasks = weekEvents
                .where((CalendarEventModel event) => event.startTime.isBefore(now))
                .length;
            final int remainingTasks = totalTasks - completedTasks;

            return Column(
              children: <Widget>[
                _buildStatRow(
                  icon: Icons.task_alt,
                  label: 'tasks_this_week'.tr,
                  value: '$totalTasks',
                  color: AppTheme.accentPrimary,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.check_circle,
                  label: 'completed_tasks'.tr,
                  value: '$completedTasks',
                  color: AppTheme.accentSecondary,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.pending_actions,
                  label: 'remaining_tasks'.tr,
                  value: '$remainingTasks',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 12),
                _buildComplianceRate(calendarCtrl.calendarComplianceRate.value),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceRate(double rate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'compliance_rate'.tr,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(rate * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentSecondary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
