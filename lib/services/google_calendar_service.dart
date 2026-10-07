/// lib/services/google_calendar_service.dart (Part 1/2)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/calendar_event_model.dart';

class CalendarServiceResponse {
  final bool status;
  final String message;
  final dynamic data;
  const CalendarServiceResponse({required this.status, required this.message, this.data});
}

class GoogleCalendarService {
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  // ignore: unused_element
  String get _clientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  // ignore: unused_element
  String get _clientSecret => dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';

  Future<CalendarServiceResponse> fetchUpcomingEvents(
    String accessToken, {
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    try {
      if (accessToken.isEmpty) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หายไป กรุณาเข้าสู่ระบบใหม่');
      }
      final DateTime min = timeMin ?? DateTime.now();
      final DateTime max = timeMax ?? DateTime.now().add(const Duration(days: 30));
      final String minIso = min.toUtc().toIso8601String();
      final String maxIso = max.toUtc().toIso8601String();
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events?timeMin=$minIso&timeMax=$maxIso&singleEvents=true&orderBy=startTime');
      final http.Response response = await http.get(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>? ?? <dynamic>[];
        final List<CalendarEventModel> events = items.cast<Map<String, dynamic>>().map((Map<String, dynamic> e) => CalendarEventModel.fromJson(e)).toList();
        return CalendarServiceResponse(status: true, message: 'ดึง Events สำเร็จ (${events.length} รายการ)', data: events);
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ กรุณาเข้าสู่ระบบใหม่');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถดึง Calendar ได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ API: ${e.toString()}');
    }
  }

  Future<CalendarServiceResponse> createEvent(
    String accessToken, {
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? colorId,
    bool isAllDay = false,
  }) async {
    try {
      if (accessToken.isEmpty) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หายไป กรุณาเข้าสู่ระบบใหม่');
      }
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events');
      final Map<String, dynamic> eventBody = <String, dynamic>{
        'summary': title,
        'description': description ?? '',
        'start': isAllDay ? <String, dynamic>{'date': startTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': startTime.toIso8601String(), 'timeZone': 'UTC'},
        'end': isAllDay ? <String, dynamic>{'date': endTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': endTime.toIso8601String(), 'timeZone': 'UTC'},
      };
      if (colorId != null && colorId.isNotEmpty) eventBody['colorId'] = colorId;
      final http.Response response = await http.post(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(eventBody));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final CalendarEventModel newEvent = CalendarEventModel.fromJson(data);
        return CalendarServiceResponse(status: true, message: 'สร้าง Event สำเร็จ', data: newEvent);
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ กรุณาเข้าสู่ระบบใหม่');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถสร้าง Event ได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาดในการสร้าง Event: ${e.toString()}');
    }
  }
  Future<CalendarServiceResponse> updateEvent(String accessToken, {required String eventId, required String title, required DateTime startTime, required DateTime endTime, String? description, String? colorId, bool isAllDay = false}) async {
    try {
      if (accessToken.isEmpty) return const CalendarServiceResponse(status: false, message: 'Access Token หายไป');
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events/$eventId');
      final Map<String, dynamic> eventBody = <String, dynamic>{
        'summary': title,
        'description': description ?? '',
        'start': isAllDay ? <String, dynamic>{'date': startTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': startTime.toIso8601String(), 'timeZone': 'UTC'},
        'end': isAllDay ? <String, dynamic>{'date': endTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': endTime.toIso8601String(), 'timeZone': 'UTC'},
      };
      if (colorId != null && colorId.isNotEmpty) eventBody['colorId'] = colorId;
      final http.Response response = await http.put(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(eventBody));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return CalendarServiceResponse(status: true, message: 'อัปเดต Event สำเร็จ', data: CalendarEventModel.fromJson(data));
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถอัปเดต Event ได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  Future<CalendarServiceResponse> deleteEvent(String accessToken, String eventId) async {
    try {
      if (accessToken.isEmpty) return const CalendarServiceResponse(status: false, message: 'Access Token หายไป');
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events/$eventId');
      final http.Response response = await http.delete(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 204 || response.statusCode == 200) {
        return const CalendarServiceResponse(status: true, message: 'ลบ Event สำเร็จ');
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถลบ Event ได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  Future<CalendarServiceResponse> getEvent(String accessToken, String eventId) async {
    try {
      if (accessToken.isEmpty) return const CalendarServiceResponse(status: false, message: 'Access Token หายไป');
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events/$eventId');
      final http.Response response = await http.get(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return CalendarServiceResponse(status: true, message: 'ดึง Event สำเร็จ', data: CalendarEventModel.fromJson(data));
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถดึง Event ได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
}

