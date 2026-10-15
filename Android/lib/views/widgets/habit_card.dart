/// lib/views/widgets/habit_card.dart
/// Card แสดงข้อมูล Habit รายการ — ใช้ใน HabitTrackerView
import 'package:flutter/material.dart';
import '../../models/habit_model.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onMarkCompleted;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final bool completedToday = habit.isCompletedToday();
    final DateTime weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final double rate = habit.calculateWeeklySuccessRate(weekStart);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            // ปุ่มเช็คทำเสร็จ
            GestureDetector(
              onTap: completedToday ? null : onMarkCompleted,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: completedToday ? AppTheme.accentSecondary : AppTheme.cardLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completedToday ? AppTheme.accentSecondary : AppTheme.cardLight,
                    width: 2,
                  ),
                ),
                child: completedToday
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // ข้อมูล Habit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar รายสัปดาห์
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: AppTheme.cardLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completedToday ? AppTheme.accentSecondary : AppTheme.accentPrimary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'สัปดาห์นี้: ${(rate * 100).toStringAsFixed(0)}%  •  เป้าหมาย ${habit.targetDaysPerWeek} วัน/สัปดาห์',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
