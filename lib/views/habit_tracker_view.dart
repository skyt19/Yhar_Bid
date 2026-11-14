/// lib/views/habit_tracker_view.dart
/// Habit Tracking Screen — Progress patterns and completion visualization
/// Operate mode: scan-first habits, progress-driven, warm neutral design
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/habit_controller.dart';
import '../controllers/task_controller.dart';
import '../models/habit_model.dart';
import 'theme/app_theme.dart';

class HabitTrackerView extends StatelessWidget {
  const HabitTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final habitCtrl = Get.put(HabitController());
    final taskCtrl = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(habitCtrl),
            _buildWeekOverview(habitCtrl),
            Expanded(child: _buildHabitList(habitCtrl, taskCtrl)),
          ],
        ),
      ),
      floatingActionButton: null, // Temporarily disabled - add habit functionality not implemented
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(HabitController habitCtrl) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Obx(() {
        final total = habitCtrl.habits.length;
        final activeToday = habitCtrl.habits
            .where((h) => h.isCompletedToday())
            .length;
        final successRate = total > 0 ? (activeToday / total * 100) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('นิสัยของคุณ', style: AppTheme.titleLarge),
            const SizedBox(height: AppTheme.space8),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '$total',
                    'นิสัยทั้งหมด',
                    Icons.track_changes,
                    AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: _statCard(
                    '$activeToday',
                    'เสร็จวันนี้',
                    Icons.check_circle_outline,
                    AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: _statCard(
                    '${successRate.toStringAsFixed(0)}%',
                    'อัตราความสำเร็จ',
                    Icons.trending_up,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(color: color),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Week Overview ────────────────────────────────────────────────────────

  Widget _buildWeekOverview(HabitController habitCtrl) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return day;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space16,
        AppTheme.space8,
        AppTheme.space16,
        AppTheme.space16,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7 วันที่ผ่านมา',
                  style: AppTheme.titleMedium,
                ),
                Obx(() {
                  final weeklyRate = habitCtrl.weeklySuccessRate.value;
                  return Text(
                    '${(weeklyRate * 100).toStringAsFixed(0)}%',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.accentGreen,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return _dayColumn(day, habitCtrl);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayColumn(DateTime day, HabitController habitCtrl) {
    final isToday = DateFormat('yyyy-MM-dd').format(day) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dayLabel = DateFormat('E', 'th').format(day).substring(0, 1);
    final dateLabel = DateFormat('d').format(day);

    return Obx(() {
      final completedCount = habitCtrl.habits
          .where((h) => h.completedDates.any((d) =>
              d.year == day.year && d.month == day.month && d.day == day.day))
          .length;
      final totalHabits = habitCtrl.habits.length;
      final hasCompleted = completedCount > 0;

      return Column(
        children: [
          Text(
            dayLabel,
            style: AppTheme.caption.copyWith(
              color: isToday
                  ? AppTheme.accentGreen
                  : AppTheme.textTertiary,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hasCompleted
                  ? AppTheme.accentGreen.withValues(alpha: 0.15)
                  : AppTheme.surfaceGray,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasCompleted
                    ? AppTheme.accentGreen
                    : isToday
                        ? AppTheme.accentGreen.withValues(alpha: 0.3)
                        : AppTheme.borderColor,
                width: isToday ? 2.0 : 1.0,
              ),
            ),
            child: Center(
              child: Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: hasCompleted
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          if (totalHabits > 0)
            Text(
              '$completedCount/$totalHabits',
              style: AppTheme.caption.copyWith(
                fontSize: 10,
                color: hasCompleted
                    ? AppTheme.accentGreen
                    : AppTheme.textTertiary,
              ),
            ),
        ],
      );
    });
  }

  // ─── Habit List ───────────────────────────────────────────────────────────

  Widget _buildHabitList(
      HabitController habitCtrl, TaskController taskCtrl) {
    return Obx(() {
      if (habitCtrl.habits.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space16,
          0,
          AppTheme.space16,
          AppTheme.space80,
        ),
        itemCount: habitCtrl.habits.length,
        itemBuilder: (context, i) => _habitCard(
          habitCtrl.habits[i],
          habitCtrl,
          taskCtrl,
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.track_changes,
                size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.space12),
            Text(
              'ยังไม่มีนิสัยที่ติดตาม',
              style: AppTheme.titleSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            const Text(
              'กด + เพื่อเริ่มสร้างนิสัยใหม่',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Habit Card ───────────────────────────────────────────────────────────

  Widget _habitCard(
    HabitModel habit,
    HabitController habitCtrl,
    TaskController taskCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowCard,
          border: habit.isCompletedToday()
              ? Border.all(
                  color: AppTheme.accentGreen.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => habitCtrl.markHabitCompleted(habit.id),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: habit.isCompletedToday()
                            ? AppTheme.accentGreen
                            : AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: habit.isCompletedToday()
                              ? AppTheme.accentGreen
                              : AppTheme.borderStrong,
                          width: 2.0,
                        ),
                      ),
                      child: habit.isCompletedToday()
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppTheme.surfaceLight,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: AppTheme.titleMedium.copyWith(
                            decoration: habit.isCompletedToday()
                                ? TextDecoration.lineThrough
                                : null,
                            color: habit.isCompletedToday()
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        if (habit.description.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.space4),
                          Text(
                            habit.description!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Temporarily disable more menu - delete functionality not implemented
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: AppTheme.space12),
              const Divider(color: AppTheme.dividerColor, height: 1),
              const SizedBox(height: AppTheme.space12),
              // Progress stats
              Row(
                children: [
                  _progressBadge(
                    '${_calculateCurrentStreak(habit)} วัน',
                    'ติดต่อกัน',
                    Icons.local_fire_department,
                    _calculateCurrentStreak(habit) > 0
                        ? AppTheme.accentOrange
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: AppTheme.space12),
                  _progressBadge(
                    '${habit.completedDates.length}',
                    'ครั้งทั้งหมด',
                    Icons.check_circle_outline,
                    habit.completedDates.isNotEmpty
                        ? AppTheme.accentGreen
                        : AppTheme.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBadge(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppTheme.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Methods ───────────────────────────────────────────────────────

  int _calculateCurrentStreak(HabitModel habit) {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates = habit.completedDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    int streak = 0;
    DateTime expectedDate = DateTime.now();

    for (final date in sortedDates) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final expectedOnly = DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

      if (dateOnly.isAtSameMomentAs(expectedOnly)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (dateOnly.isBefore(expectedOnly)) {
        break;
      }
    }

    return streak;
  }
}
