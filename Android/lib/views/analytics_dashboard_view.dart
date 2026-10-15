/// lib/views/analytics_dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/habit_controller.dart';
import '../controllers/calendar_controller.dart';
import 'theme/app_theme.dart';

class AnalyticsDashboardView extends StatelessWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController habitCtrl = Get.find<HabitController>();
    final CalendarController calCtrl = Get.find<CalendarController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final double hr = habitCtrl.weeklySuccessRate.value;
              final double cr = calCtrl.calendarComplianceRate.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('รายงานรายสัปดาห์', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('ความสำเร็จด้านนิสัยและ Calendar', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  Row(children: <Widget>[
                    Expanded(child: _rateCard('Habit Success', hr, AppTheme.accentSecondary, Icons.track_changes)),
                    const SizedBox(width: 12),
                    Expanded(child: _rateCard('Calendar Compliance', cr, AppTheme.accentPrimary, Icons.event_available)),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Chart รายสัปดาห์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildChart(hr, cr)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      const Text('สรุปข้อมูล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _row('จำนวนนิสัย', '${habitCtrl.habits.length} รายการ'),
                      _row('กิจกรรม Calendar', '${calCtrl.events.length} รายการ'),
                      _row('Habit Success', '${(hr * 100).toStringAsFixed(1)}%'),
                      _row('Calendar Compliance', '${(cr * 100).toStringAsFixed(1)}%'),
                    ]),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _rateCard(String label, double rate, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: <Widget>[
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text('${(rate * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildChart(double hr, double cr) {
    BarChartRodData rod(double y, Color c) => BarChartRodData(toY: y, color: c, width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)));
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 1.0,
      barGroups: <BarChartGroupData>[
        BarChartGroupData(x: 0, barRods: <BarChartRodData>[rod(hr, AppTheme.accentSecondary)]),
        BarChartGroupData(x: 1, barRods: <BarChartRodData>[rod(cr, AppTheme.accentPrimary)]),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (double v, TitleMeta m) => Text('${(v * 100).toInt()}%', style: const TextStyle(fontSize: 11)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double v, TitleMeta m) => Text(v == 0 ? 'Habit' : 'Calendar', style: const TextStyle(fontSize: 12)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      );
}
