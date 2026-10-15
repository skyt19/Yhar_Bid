/// lib/controllers/calendar_controller.dart
/// Controller จัดการ Google Calendar State — เชื่อมต่อ GoogleCalendarService กับ Views
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../services/google_calendar_service.dart';
import '../services/auth_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/proactive_controller.dart';
import '../controllers/analytics_controller.dart';

class CalendarController extends GetxController {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  final AuthService _authService = AuthService();

  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final RxDouble calendarComplianceRate = 0.0.obs;
  
  final RxBool isCalendarConnected = false.obs;
  final RxString calendarConnectionStatus = 'ยังไม่ได้เชื่อมต่อ'.obs;

  Future<void> fetchEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    calendarConnectionStatus.value = 'กำลังเชื่อมต่อ Google Calendar...';

    // ตรวจสอบ Token ก่อน — ถ้าไม่มีให้ขอใหม่
    String? token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      calendarConnectionStatus.value = 'กำลังขอสิทธิ์ Calendar...';
      final bool granted = await _authService.requestCalendarScope();
      if (!granted) {
        errorMessage.value = 'กรุณาอนุญาตการเข้าถึง Google Calendar';
        calendarConnectionStatus.value = 'ผู้ใช้ปฏิเสธการให้สิทธิ์';
        isCalendarConnected.value = false;
        isLoading.value = false;
        Get.snackbar(
          '⚠️ ต้องการสิทธิ์ Calendar',
          'กรุณาอนุญาตให้แอปเข้าถึง Google Calendar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }
      // ลองดึง Token อีกครั้งหลังจากขอสิทธิ์
      token = await _authService.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'ไม่สามารถรับ Access Token ได้';
        calendarConnectionStatus.value = 'Token Error';
        isCalendarConnected.value = false;
        isLoading.value = false;
        return;
      }
    }

    final CalendarServiceResponse response = await _calendarService.fetchUpcomingEvents(token);
    isLoading.value = false;

    if (response.status && response.data != null) {
      events.value = response.data as List<CalendarEventModel>;
      _calculateComplianceRate();
      isCalendarConnected.value = true;
      calendarConnectionStatus.value = 'เชื่อมต่อสำเร็จ: ${events.length} events';
    } else {
      errorMessage.value = response.message;
      calendarConnectionStatus.value = 'ล้มเหลว: ${response.message}';
      isCalendarConnected.value = false;
    }
  }

  Future<bool> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    bool isAllDay = false,
  }) async {
    final String? token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนสร้าง Event';
      return false;
    }

    final CalendarServiceResponse response = await _calendarService.createEvent(
      token,
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      isAllDay: isAllDay,
    );

    if (response.status && response.data != null) {
      events.add(response.data as CalendarEventModel);
      _calculateComplianceRate();
      return true;
    } else {
      errorMessage.value = response.message;
      return false;
    }
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final AuthController authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    if (user == null) {
      Get.snackbar('Error', 'Please sign in first', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      isLoading.value = true;
      final success = await createEvent(title: title, startTime: startTime, endTime: endTime, description: description);
      if (success) {
        Get.snackbar('Success', 'Event "$title" added successfully', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent({required String eventId, required String title, required String description}) async {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = events[index];
    final updated = CalendarEventModel(id: event.id, title: title, description: description, startTime: event.startTime, endTime: event.endTime, calendarId: event.calendarId, isAllDay: event.isAllDay);
    events[index] = updated;
    events.refresh();
    Get.snackbar('Success', 'Event updated', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteEvent(String eventId) async {
    events.removeWhere((e) => e.id == eventId);
    Get.snackbar('Success', 'Event deleted', snackPosition: SnackPosition.BOTTOM);
  }

  List<CalendarEventModel> getEventsForDay(DateTime day) {
    return events.where((CalendarEventModel e) => e.isOnDate(day)).toList();
  }

  void _calculateComplianceRate() {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<CalendarEventModel> thisWeekPast = events.where((CalendarEventModel e) => e.startTime.isAfter(weekStart) && e.startTime.isBefore(now)).toList();
    final List<CalendarEventModel> thisWeekAll = events.where((CalendarEventModel e) => e.startTime.isAfter(weekStart) && e.startTime.isBefore(weekStart.add(const Duration(days: 7)))).toList();
    if (thisWeekAll.isEmpty) {
      calendarComplianceRate.value = 0.0;
      return;
    }
    calendarComplianceRate.value = (thisWeekPast.length / thisWeekAll.length).clamp(0.0, 1.0);
  }

  void selectDay(DateTime day, DateTime focused) {
    selectedDay.value = day;
    focusedDay.value = focused;
  }

  /// Create Sample Role-Based Events for Testing (FR-2: Two-Way Write Sync)
  /// ตาม SRS Section 3: "Seed Real Test Events Button"
  Future<void> createSampleRoleEvents() async {
    try {
      isLoading.value = true;
      
      final AuthController authCtrl = Get.find<AuthController>();
      final user = authCtrl.currentUser.value;
      if (user == null) {
        Get.snackbar('Error', 'Please sign in first', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // สร้าง 3 Events ตาม Role
      final List<Map<String, dynamic>> roleEvents = [];
      
      // Student Event: Deadline 3 days ahead
      roleEvents.add({
        'title': 'Software Engineering - Final Project Deadline',
        'description': 'Submit complete SRS document and UML diagrams',
        'startTime': DateTime.now().add(const Duration(days: 3, hours: 23, minutes: 59)),
        'endTime': DateTime.now().add(const Duration(days: 4)),
        'isAllDay': false,
      });
      
      // Corporate Employee Event: Meeting tomorrow
      roleEvents.add({
        'title': 'Q4 Strategy Meeting',
        'description': 'Discuss annual targets and departmental KPIs',
        'startTime': DateTime.now().add(const Duration(days: 1, hours: 14)),
        'endTime': DateTime.now().add(const Duration(days: 1, hours: 16)),
        'isAllDay': false,
      });
      
      // Educator Event: Teaching session in 2 days
      roleEvents.add({
        'title': 'Introduction to AI - Lecture 8',
        'description': 'Neural Networks and Deep Learning fundamentals',
        'startTime': DateTime.now().add(const Duration(days: 2, hours: 9)),
        'endTime': DateTime.now().add(const Duration(days: 2, hours: 12)),
        'isAllDay': false,
      });
      
      int successCount = 0;
      for (final eventData in roleEvents) {
        final success = await createEvent(
          title: eventData['title'] as String,
          startTime: eventData['startTime'] as DateTime,
          endTime: eventData['endTime'] as DateTime,
          description: eventData['description'] as String,
          isAllDay: eventData['isAllDay'] as bool,
        );
        if (success) successCount++;
      }
      
      await fetchEvents(); // Refresh to show new events
      
      // FR-3: Trigger Proactive Scan after creating events
      try {
        final ProactiveController proactiveCtrl = Get.find<ProactiveController>();
        await proactiveCtrl.runProactiveScan();
      } catch (e) {
        debugPrint('⚠️ Proactive Controller not found: $e');
      }

      // FR-6: Recalculate Analytics
      try {
        final AnalyticsController analyticsCtrl = Get.find<AnalyticsController>();
        await analyticsCtrl.recalculateMetrics();
      } catch (e) {
        debugPrint('⚠️ Analytics Controller not found: $e');
      }
      
      Get.snackbar(
        'Sample Events Created',
        'Created $successCount role-based events (FR-2 Write Sync + FR-3 Scan)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create sample events: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

