/// lib/controllers/analytics_controller.dart
/// Controller สำหรับ Analytics Dashboard (FR-6)

import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';
import 'calendar_controller.dart';
import 'habit_controller.dart';

class AnalyticsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxDouble calendarComplianceRate = 0.0.obs;
  final RxDouble habitSuccessRate = 0.0.obs;
  final RxInt totalEventsThisWeek = 0.obs;
  final RxInt completedEventsThisWeek = 0.obs;
  final RxInt totalHabitsThisWeek = 0.obs;
  final RxInt completedHabitsThisWeek = 0.obs;
  
  // Observable properties for SRS Test Lab View
  final RxDouble weeklyCalendarComplianceRate = 0.0.obs;
  final RxDouble weeklyHabitSuccessRate = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    calculateWeeklyAnalytics();
  }
  
  Future<void> calculateWeeklyAnalytics() async {
    try {
      isLoading.value = true;
      
      final AuthController authCtrl = Get.find<AuthController>();
      final UserModel? user = authCtrl.currentUser.value;
      
      if (user == null) {
        _resetAnalytics();
        return;
      }
      
      final DateTime now = DateTime.now();
      final DateTime weekStart = now.subtract(const Duration(days: 7));
      
      await _calculateCalendarCompliance(weekStart, now);
      await _calculateHabitSuccess(weekStart, now);
      
      // Sync with observable properties for Test Lab
      weeklyCalendarComplianceRate.value = calendarComplianceRate.value;
      weeklyHabitSuccessRate.value = habitSuccessRate.value;
      
      print('✅ Analytics: Calendar ${calendarComplianceRate.value.toStringAsFixed(1)}%, Habit ${habitSuccessRate.value.toStringAsFixed(1)}%');
    } catch (e) {
      print('❌ Error calculating analytics: $e');
      _resetAnalytics();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _calculateCalendarCompliance(DateTime start, DateTime end) async {
    try {
      final CalendarController calCtrl = Get.find<CalendarController>();
      
      final List<CalendarEventModel> weekEvents = calCtrl.events
          .where((event) => event.startTime.isAfter(start) && event.startTime.isBefore(end))
          .toList();
      
      totalEventsThisWeek.value = weekEvents.length;
      
      if (weekEvents.isEmpty) {
        calendarComplianceRate.value = 100.0;
        completedEventsThisWeek.value = 0;
        return;
      }
      
      final DateTime now = DateTime.now();
      final List<CalendarEventModel> completedEvents = weekEvents
          .where((event) => event.endTime.isBefore(now))
          .toList();
      
      completedEventsThisWeek.value = completedEvents.length;
      calendarComplianceRate.value = (completedEvents.length / weekEvents.length * 100);
    } catch (e) {
      calendarComplianceRate.value = 0.0;
    }
  }
  
  Future<void> _calculateHabitSuccess(DateTime start, DateTime end) async {
    try {
      final HabitController habitCtrl = Get.find<HabitController>();
      final List<HabitModel> activeHabits = habitCtrl.habits;
      
      if (activeHabits.isEmpty) {
        habitSuccessRate.value = 100.0;
        totalHabitsThisWeek.value = 0;
        completedHabitsThisWeek.value = 0;
        return;
      }
      
      int expectedCompletions = 0;
      int actualCompletions = 0;
      
      for (final habit in activeHabits) {
        expectedCompletions += habit.targetDaysPerWeek;
        final int completed = habit.completedDates
            .where((date) => date.isAfter(start) && date.isBefore(end))
            .length;
        actualCompletions += completed;
      }
      
      totalHabitsThisWeek.value = expectedCompletions;
      completedHabitsThisWeek.value = actualCompletions;
      
      if (expectedCompletions == 0) {
        habitSuccessRate.value = 100.0;
      } else {
        habitSuccessRate.value = (actualCompletions / expectedCompletions * 100).clamp(0.0, 100.0);
      }
    } catch (e) {
      habitSuccessRate.value = 0.0;
    }
  }
  
  void _resetAnalytics() {
    calendarComplianceRate.value = 0.0;
    habitSuccessRate.value = 0.0;
    totalEventsThisWeek.value = 0;
    completedEventsThisWeek.value = 0;
    totalHabitsThisWeek.value = 0;
    completedHabitsThisWeek.value = 0;
  }
  
  double get overallScore => (calendarComplianceRate.value + habitSuccessRate.value) / 2;
  
  String get statusMessage {
    final double score = overallScore;
    if (score >= 80) return 'ยอดเยี่ยม! 🎉';
    if (score >= 60) return 'ดีมาก! 👍';
    if (score >= 40) return 'พอใช้ 😊';
    return 'ต้องปรับปรุง 💪';
  }
  
  int get statusColor {
    final double score = overallScore;
    if (score >= 80) return 0xFF4CAF50;
    if (score >= 60) return 0xFF8BC34A;
    if (score >= 40) return 0xFFFFC107;
    return 0xFFF44336;
  }
  
  /// รีเฟรชข้อมูลทันที (สำหรับ SRS Test Lab)
  Future<void> recalculateMetrics() async {
    await calculateWeeklyAnalytics();
    Get.snackbar(
      'Metrics Recalculated',
      'Calendar: ${calendarComplianceRate.value.toStringAsFixed(1)}%, Habit: ${habitSuccessRate.value.toStringAsFixed(1)}%',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

