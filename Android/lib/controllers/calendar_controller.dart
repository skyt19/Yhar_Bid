/// lib/controllers/calendar_controller.dart
/// Controller จัดการ Google Calendar State — เชื่อมต่อ GoogleCalendarService กับ Views
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../services/google_calendar_service.dart';
import '../services/auth_service.dart';
import '../controllers/auth_controller.dart';

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

    final String? token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนใช้งาน Calendar';
      calendarConnectionStatus.value = 'ไม่มี Access Token';
      isCalendarConnected.value = false;
      isLoading.value = false;
      return;
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
}
