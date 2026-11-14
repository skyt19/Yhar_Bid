library;

/// lib/views/widgets/work_in_week_card.dart
/// Card สรุปงานในสัปดาห์นี้ (Work in Week)
/// IMPECCABLE UPDATE: Role-adaptive terminology (P1)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../theme/app_theme.dart';

class WorkInWeekCard extends StatelessWidget {
  const WorkInWeekCard({super.key});

  /// Get role-adaptive label
  String _getRoleAdaptiveLabel(String key, UserRole? role) {
    final Map<String, Map<UserRole, String>> roleLabels = {
      'work_in_week': {
        UserRole.student: 'กิจกรรมในสัปดาห์นี้',
        UserRole.corporateEmployee: 'งานในสัปดาห์นี้',
        UserRole.educator: 'บทเรียนในสัปดาห์นี้',
      },
      'tasks_this_week': {
        UserRole.student: 'รายการเรียนทั้งหมด',
        UserRole.corporateEmployee: 'นัดหมายทั้งหมด',
        UserRole.educator: 'บทเรียนทั้งหมด',
      },
      'completed_tasks': {
        UserRole.student: 'เรียนไปแล้ว',
        UserRole.corporateEmployee: 'ประชุมไปแล้ว',
        UserRole.educator: 'สอนไปแล้ว',
      },
      'remaining_tasks': {
        UserRole.student: 'คาบเรียนที่เหลือ',
        UserRole.corporateEmployee: 'นัดที่เหลือ',
        UserRole.educator: 'คาบสอนที่เหลือ',
      },
      'on_time_rate': {
        UserRole.student: 'อัตราเข้าเรียนตรงเวลา',
        UserRole.corporateEmployee: 'อัตราการทำงานตรงเวลา',
        UserRole.educator: 'อัตราการสอนตรงเวลา',
      },
    };

    if (role != null && roleLabels.containsKey(key) && roleLabels[key]!.containsKey(role)) {
      return roleLabels[key]![role]!;
    }
    return key.tr;
  }

  @override
  Widget build(BuildContext context) {
    final CalendarController calCtrl = Get.find<CalendarController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Obx(() {
      final UserModel? user = authCtrl.currentUser.value;
      final UserRole? role = user?.role;

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
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
                const Icon(Icons.calendar_month, color: AppTheme.accentGray, size: 24),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    _getRoleAdaptiveLabel('work_in_week', role),
                    style: AppTheme.title18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space20),
            Obx(() {
              if (calCtrl.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.space20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // คำนวณงานในสัปดาห์นี้
              final DateTime now = DateTime.now();
              final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

              final List<CalendarEventModel> weekEvents = calCtrl.events
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
                    label: _getRoleAdaptiveLabel('tasks_this_week', role),
                    value: '$totalTasks',
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(height: AppTheme.space12),
                  _buildStatRow(
                    icon: Icons.check_circle,
                    label: _getRoleAdaptiveLabel('completed_tasks', role),
                    value: '$completedTasks',
                    color: AppTheme.accentGray,
                  ),
                  const SizedBox(height: AppTheme.space12),
                  _buildStatRow(
                    icon: Icons.pending_actions,
                    label: _getRoleAdaptiveLabel('remaining_tasks', role),
                    value: '$remainingTasks',
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(height: AppTheme.space16),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  const SizedBox(height: AppTheme.space12),
                  _buildComplianceRate(calCtrl.calendarComplianceRate.value, role),
                ],
              );
            }),
          ],
        ),
      );
    });
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
        const SizedBox(width: AppTheme.space8),
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTheme.title18.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildComplianceRate(double rate, UserRole? role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                _getRoleAdaptiveLabel('on_time_rate', role),
                style: AppTheme.body13.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(rate * 100).toStringAsFixed(0)}%',
              style: AppTheme.titleSmall.copyWith(
                color: AppTheme.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXS),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: AppTheme.surfaceGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGray),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
