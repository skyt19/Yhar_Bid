/// lib/controllers/calendar_controller.dart
/// Controller จัดการ Google Calendar State — เชื่อมต่อ GoogleCalendarService กับ Views
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../services/google_calendar_service.dart';
import '../services/auth_service.dart';

class CalendarController extends GetxController {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  final AuthService _authService = AuthService();

  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
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

    final String? token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนใช้งาน Calendar';
      isLoading.value = false;
      return;
    }

    final CalendarServiceResponse response = await _calendarService.fetchUpcomingEvents(token);
    isLoading.value = false;

    if (response.status && response.data != null) {
      events.value = response.data as List<CalendarEventModel>;
      _calculateComplianceRate();
    } else {
      errorMessage.value = response.message;
    }
  }

  /// สร้าง Event ใหม่ลง Google Calendar (Two-way Sync)
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

  /// กรอง Events ตามวันที่เลือก
  List<CalendarEventModel> getEventsForDay(DateTime day) {
    return events.where((CalendarEventModel e) => e.isOnDate(day)).toList();
  }

  /// คำนวณ Calendar Compliance Rate (events ที่ผ่านมาแล้วในสัปดาห์นี้)
  void _calculateComplianceRate() {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<CalendarEventModel> thisWeekPast = events
        .where((CalendarEventModel e) => e.startTime.isAfter(weekStart) && e.startTime.isBefore(now))
        .toList();
    final List<CalendarEventModel> thisWeekAll = events
        .where((CalendarEventModel e) =>
            e.startTime.isAfter(weekStart) && e.startTime.isBefore(weekStart.add(const Duration(days: 7))))
        .toList();
    if (thisWeekAll.isEmpty) {
      calendarComplianceRate.value = 0.0;
      return;
    }
    calendarComplianceRate.value = (thisWeekPast.length / thisWeekAll.length).clamp(0.0, 1.0);
  }

  /// เปลี่ยนวันที่เลือกใน Calendar
  void selectDay(DateTime day, DateTime focused) {
    selectedDay.value = day;
    focusedDay.value = focused;
  }
}

