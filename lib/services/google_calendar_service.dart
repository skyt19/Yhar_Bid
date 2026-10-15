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

  /// Fetch Calendar List (all user calendars including Google Classroom, University, etc.)
  /// Returns list of calendar IDs to fetch events from
  Future<CalendarServiceResponse> fetchCalendarList(String accessToken) async {
    try {
      if (accessToken.isEmpty) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หายไป');
      }
      final Uri uri = Uri.parse('$_baseUrl/users/me/calendarList');
      final http.Response response = await http.get(
        uri, 
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken', 
          'Accept': 'application/json'
        }
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>? ?? <dynamic>[];
        // Extract calendar IDs from calendars user has read access to
        final List<String> calendarIds = items
            .cast<Map<String, dynamic>>()
            .where((Map<String, dynamic> cal) {
              final String? accessRole = cal['accessRole'] as String?;
              final bool? selected = cal['selected'] as bool?;
              // Include primary, selected calendars, or calendars with reader/owner/writer access
              return (cal['primary'] == true) || 
                     (selected == true) || 
                     (accessRole == 'owner' || accessRole == 'writer' || accessRole == 'reader');
            })
            .map((Map<String, dynamic> cal) => cal['id'] as String)
            .toList();
        return CalendarServiceResponse(
          status: true, 
          message: 'พบ ${calendarIds.length} ปฏิทิน', 
          data: calendarIds
        );
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ');
      } else {
        return CalendarServiceResponse(status: false, message: 'ไม่สามารถดึงรายการปฏิทินได้ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  /// Fetch events from multiple calendars (University, Classroom, Personal)
  /// Aggregates and deduplicates events by ID
  Future<CalendarServiceResponse> fetchUpcomingEvents(
    String accessToken, {
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    try {
      if (accessToken.isEmpty) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หายไป กรุณาเข้าสู่ระบบใหม่');
      }
      
      // Fetch calendar list first
      final CalendarServiceResponse calListResponse = await fetchCalendarList(accessToken);
      List<String> calendarIds = <String>['primary']; // Always include primary
      
      if (calListResponse.status && calListResponse.data != null) {
        calendarIds = calListResponse.data as List<String>;
      }
      
      // SPECIFICATION #3: TODAY + NEXT 14 DAYS ONLY (NO PAST EVENTS)
      final DateTime min = timeMin ?? DateTime.now();  // Strictly starting from NOW
      final DateTime max = timeMax ?? DateTime.now().add(const Duration(days: 14));
      final String minIso = min.toUtc().toIso8601String();
      final String maxIso = max.toUtc().toIso8601String();
      
      final Map<String, CalendarEventModel> allEventsMap = <String, CalendarEventModel>{};
      int successCount = 0;
      
      // Fetch events from each calendar
      for (final String calendarId in calendarIds) {
        try {
          final String encodedCalId = Uri.encodeComponent(calendarId);
          final Uri uri = Uri.parse(
            '$_baseUrl/calendars/$encodedCalId/events?timeMin=$minIso&timeMax=$maxIso&singleEvents=true&orderBy=startTime'
          );
          final http.Response response = await http.get(
            uri, 
            headers: <String, String>{
              'Authorization': 'Bearer $accessToken', 
              'Accept': 'application/json'
            }
          );
          
          if (response.statusCode == 200) {
            successCount++;
            final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
            final List<dynamic> items = data['items'] as List<dynamic>? ?? <dynamic>[];
            for (final dynamic item in items) {
              final Map<String, dynamic> eventJson = item as Map<String, dynamic>;
              final CalendarEventModel event = CalendarEventModel.fromJson(eventJson);
              // Deduplicate by event ID
              allEventsMap[event.id] = event;
            }
          }
        } catch (e) {
          // Continue fetching other calendars even if one fails
          continue;
        }
      }
      
      final List<CalendarEventModel> events = allEventsMap.values.toList();
      // Sort by start time and filter out past events (SPECIFICATION #3)
      final DateTime now = DateTime.now();
      final List<CalendarEventModel> futureEvents = events
          .where((CalendarEventModel e) => e.startTime.isAfter(now))
          .toList();
      futureEvents.sort((CalendarEventModel a, CalendarEventModel b) => 
        a.startTime.compareTo(b.startTime)
      );
      
      return CalendarServiceResponse(
        status: true, 
        message: 'ดึง Events สำเร็จจาก $successCount ปฏิทิน (${futureEvents.length} รายการ)', 
        data: futureEvents
      );
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
        'start': isAllDay ? <String, dynamic>{'date': startTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': startTime.toIso8601String(), 'timeZone': 'Asia/Bangkok'},
        'end': isAllDay ? <String, dynamic>{'date': endTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': endTime.toIso8601String(), 'timeZone': 'Asia/Bangkok'},
      };
      if (colorId != null && colorId.isNotEmpty) eventBody['colorId'] = colorId;
      final http.Response response = await http.post(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(eventBody));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final CalendarEventModel newEvent = CalendarEventModel.fromJson(data);
        return CalendarServiceResponse(status: true, message: 'สร้าง Event สำเร็จ', data: newEvent);
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ กรุณาเข้าสู่ระบบใหม่');
      } else if (response.statusCode == 403) {
        String errorMsg = 'ไม่มีสิทธิ์เขียนปฏิทิน กรุณาอนุญาต Calendar Access';
        try {
          final Map<String, dynamic> err = json.decode(response.body) as Map<String, dynamic>;
          errorMsg += '\nDetail: ${err['error']?['message'] ?? response.body}';
        } catch (_) {}
        return CalendarServiceResponse(status: false, message: errorMsg);
      } else {
        String errorMsg = 'ไม่สามารถสร้าง Event ได้ (HTTP ${response.statusCode})';
        try {
          final Map<String, dynamic> err = json.decode(response.body) as Map<String, dynamic>;
          errorMsg += '\nError: ${err['error']?['message'] ?? response.body}';
        } catch (_) {
          errorMsg += '\nResponse: ${response.body.substring(0, 200)}';
        }
        return CalendarServiceResponse(status: false, message: errorMsg);
      }
    } catch (e) {
      return CalendarServiceResponse(status: false, message: 'เกิดข้อผิดพลาดในการสร้าง Event: ${e.toString()}');
    }
  }
  Future<CalendarServiceResponse> updateEvent(String accessToken, {required String eventId, required String title, required DateTime startTime, required DateTime endTime, String? description, String? colorId, bool isAllDay = false}) async {
    try {
      if (accessToken.isEmpty) return const CalendarServiceResponse(status: false, message: 'Access Token หายไป');
      
      // URL-encode eventId to handle special characters
      final String encodedEventId = Uri.encodeComponent(eventId);
      final Uri uri = Uri.parse('$_baseUrl/calendars/primary/events/$encodedEventId');
      
      final Map<String, dynamic> eventBody = <String, dynamic>{
        'summary': title,
        'description': description ?? '',
        'start': isAllDay ? <String, dynamic>{'date': startTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': startTime.toIso8601String(), 'timeZone': 'Asia/Bangkok'},
        'end': isAllDay ? <String, dynamic>{'date': endTime.toIso8601String().substring(0, 10)} : <String, dynamic>{'dateTime': endTime.toIso8601String(), 'timeZone': 'Asia/Bangkok'},
      };
      if (colorId != null && colorId.isNotEmpty) eventBody['colorId'] = colorId;
      
      final http.Response response = await http.put(uri, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'}, body: json.encode(eventBody));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return CalendarServiceResponse(status: true, message: 'อัปเดต Event สำเร็จ', data: CalendarEventModel.fromJson(data));
      } else if (response.statusCode == 401) {
        return const CalendarServiceResponse(status: false, message: 'Access Token หมดอายุ');
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        // Graceful fallback for read-only calendars (University, Public Holidays)
        // Log warning but return success so local save proceeds
        print('⚠️ Cannot write to calendar (403/404) - likely read-only calendar. Saving locally only.');
        return CalendarServiceResponse(status: true, message: 'บันทึกในเครื่องเรียบร้อย (ปฏิทินอ่านอย่างเดียว)', data: null);
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

