/// lib/controllers/calendar_controller.dart
/// Controller จัดการ Google Calendar — ดึง Events, คำนวณ Compliance Rate
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Events จาก Google Calendar
  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;

  // Calendar Compliance Rate รายสัปดาห์ (0.0 - 1.0)
  final RxDouble calendarComplianceRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  /// ดึง Events จาก Google Calendar API
  Future<void> fetchEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String? token = await _authController.getAccessToken();
      if (token == null) {
        errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนใช้งาน Calendar';
        return;
      }

      // กำหนดช่วงวันที่ดึง: จากต้นสัปดาห์ถึงสิ้นเดือน
      final DateTime now = DateTime.now();
      final String timeMin = DateTime(now.year, now.month, 1).toUtc().toIso8601String();
      final String timeMax = DateTime(now.year, now.month + 1, 0).toUtc().toIso8601String();

      final Uri uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events'
        '?timeMin=$timeMin&timeMax=$timeMax&singleEvents=true&orderBy=startTime',
      );

      final http.Response response = await http.get(
        uri,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>? ?? <dynamic>[];
        events.value = items
            .cast<Map<String, dynamic>>()
            .map((Map<String, dynamic> e) => CalendarEventModel.fromJson(e))
            .toList();
        _calculateComplianceRate();
      } else {
        errorMessage.value = 'ไม่สามารถดึงข้อมูล Calendar ได้ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาดในการเชื่อมต่อ Calendar API';
    } finally {
      isLoading.value = false;
    }
  }

  /// กรอง Events ตามวันที่เลือก
  List<CalendarEventModel> getEventsForDay(DateTime day) {
    return events.where((CalendarEventModel e) => e.isOnDate(day)).toList();
  }

  /// คำนวณ Calendar Compliance Rate (events ที่ผ่านมาแล้วในสัปดาห์นี้)
  void _calculateComplianceRate() {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<CalendarEventModel> thisWeekPast = events.where(
      (CalendarEventModel e) =>
          e.startTime.isAfter(weekStart) && e.startTime.isBefore(now),
    ).toList();
    final List<CalendarEventModel> thisWeekAll = events.where(
      (CalendarEventModel e) =>
          e.startTime.isAfter(weekStart) &&
          e.startTime.isBefore(weekStart.add(const Duration(days: 7))),
    ).toList();
    if (thisWeekAll.isEmpty) {
      calendarComplianceRate.value = 0.0;
      return;
    }
    calendarComplianceRate.value =
        (thisWeekPast.length / thisWeekAll.length).clamp(0.0, 1.0);
  }

  /// เปลี่ยนวันที่เลือกใน Calendar
  void selectDay(DateTime day, DateTime focused) {
    selectedDay.value = day;
    focusedDay.value = focused;
  }
}
