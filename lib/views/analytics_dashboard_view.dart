/// lib/views/analytics_dashboard_view.dart
/// Analytics Dashboard — Visual insights and success metrics
/// Operate mode: data-driven visualization, warm neutral design
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/habit_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/task_controller.dart';
import 'theme/app_theme.dart';

class AnalyticsDashboardView extends StatelessWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final habitCtrl = Get.find<HabitController>();
    final calCtrl = Get.find<CalendarController>();
    final taskCtrl = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overview metrics
                  _buildOverviewMetrics(habitCtrl, calCtrl, taskCtrl),
                  const SizedBox(height: AppTheme.space20),

                  // Weekly performance chart
                  _buildWeeklyChart(habitCtrl, calCtrl),
                  const SizedBox(height: AppTheme.space20),

                  // Task completion breakdown
                  _buildTaskBreakdown(taskCtrl),
                  const SizedBox(height: AppTheme.space20),

                  // Insights summary
                  _buildInsightsSummary(habitCtrl, calCtrl, taskCtrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Overview Metrics ─────────────────────────────────────────────────────

  Widget _buildOverviewMetrics(
    HabitController habitCtrl,
    CalendarController calCtrl,
    TaskController taskCtrl,
  ) {
    return Obx(() {
      final habitRate = habitCtrl.weeklySuccessRate.value;
      final calRate = calCtrl.calendarComplianceRate.value;
      final taskDone = taskCtrl.tasks.where((t) => t.isDone).length;
      final taskTotal = taskCtrl.tasks.length;
      final taskRate = taskTotal > 0 ? (taskDone / taskTotal) : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ภาพรวมรายสัปดาห์',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'ข้อมูลและความคืบหน้าของคุณ',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  '${(habitRate * 100).toStringAsFixed(0)}%',
                  'Habit Success',
                  Icons.track_changes,
                  AppTheme.accentGreen,
                  habitRate,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _metricCard(
                  '${(calRate * 100).toStringAsFixed(0)}%',
                  'Calendar',
                  Icons.event_available,
                  AppTheme.accentOrange,
                  calRate,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _metricCard(
                  '${(taskRate * 100).toStringAsFixed(0)}%',
                  'Tasks',
                  Icons.task_alt,
                  AppTheme.accentGreen,
                  taskRate,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _metricCard(
    String value,
    String label,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowCard,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppTheme.space12),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(color: color),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Weekly Chart ─────────────────────────────────────────────────────────

  Widget _buildWeeklyChart(
    HabitController habitCtrl,
    CalendarController calCtrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'แนวโน้มรายสัปดาห์',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.space2),
                  Text(
                    '7 วันที่ผ่านมา',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          SizedBox(
            height: 200,
            child: Obx(() => LineChart(
                  _buildChartData(
                    habitCtrl.weeklySuccessRate.value,
                    calCtrl.calendarComplianceRate.value,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('Habits', AppTheme.accentGreen),
        const SizedBox(width: AppTheme.space8),
        _legendItem('Calendar', AppTheme.accentOrange),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.space4),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData(double habitRate, double calRate) {
    // Generate sample data for 7 days
    final habitSpots = List.generate(7, (i) {
      // Simulate trend data
      return FlSpot(i.toDouble(), (habitRate * 100) + (i * 2 - 6));
    });

    final calSpots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), (calRate * 100) + (i * 1.5 - 5));
    });

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppTheme.dividerColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const days = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
              if (value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[value.toInt()],
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textTertiary,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // Habits line
        LineChartBarData(
          spots: habitSpots,
          isCurved: true,
          color: AppTheme.accentGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.accentGreen.withValues(alpha: 0.1),
          ),
        ),
        // Calendar line
        LineChartBarData(
          spots: calSpots,
          isCurved: true,
          color: AppTheme.accentOrange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.accentOrange.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  // ─── Task Breakdown ───────────────────────────────────────────────────────

  Widget _buildTaskBreakdown(TaskController taskCtrl) {
    return Obx(() {
      final done = taskCtrl.tasks.where((t) => t.isDone).length;
      final pending = taskCtrl.tasks.where((t) => !t.isDone).length;
      final total = taskCtrl.tasks.length;

      return Container(
        padding: const EdgeInsets.all(AppTheme.space20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สรุปงาน',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space16),
            Row(
              children: [
                Expanded(
                  child: _taskStat(
                    '$total',
                    'ทั้งหมด',
                    Icons.list_alt,
                    AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: _taskStat(
                    '$done',
                    'เสร็จแล้ว',
                    Icons.check_circle_outline,
                    AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: _taskStat(
                    '$pending',
                    'รอดำเนินการ',
                    Icons.pending_outlined,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _taskStat(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Insights Summary ─────────────────────────────────────────────────────

  Widget _buildInsightsSummary(
    HabitController habitCtrl,
    CalendarController calCtrl,
    TaskController taskCtrl,
  ) {
    return Obx(() {
      final habitCount = habitCtrl.habits.length;
      final eventCount = calCtrl.events.length;
      final taskCount = taskCtrl.tasks.length;
      final habitRate = habitCtrl.weeklySuccessRate.value;

      return Container(
        padding: const EdgeInsets.all(AppTheme.space20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.insights,
                    size: 20,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Text(
                  'สรุปข้อมูล',
                  style: AppTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            _insightRow('จำนวนนิสัย', '$habitCount รายการ'),
            _insightRow('กิจกรรม Calendar', '$eventCount รายการ'),
            _insightRow('งานทั้งหมด', '$taskCount รายการ'),
            _insightRow(
              'Habit Success Rate',
              '${(habitRate * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      );
    });
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
