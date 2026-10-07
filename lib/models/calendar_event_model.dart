/// lib/models/calendar_event_model.dart
/// โมเดล Google Calendar Event — Mapping จาก Calendar REST API
class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String calendarId;
  final bool isAllDay;
  final String? colorId;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.calendarId,
    this.isAllDay = false,
    this.colorId,
  });

  /// แปลงจาก Google Calendar API JSON Response
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? start = json['start'] as Map<String, dynamic>?;
    final Map<String, dynamic>? end = json['end'] as Map<String, dynamic>?;

    final bool allDay = start?.containsKey('date') ?? false;
    final DateTime startDt = allDay
        ? DateTime.parse(start!['date'] as String)
        : DateTime.parse((start?['dateTime'] ?? DateTime.now().toIso8601String()) as String);
    final DateTime endDt = allDay
        ? DateTime.parse(end!['date'] as String)
        : DateTime.parse((end?['dateTime'] ?? DateTime.now().toIso8601String()) as String);

    return CalendarEventModel(
      id: json['id'] as String? ?? '',
      title: json['summary'] as String? ?? '(ไม่มีชื่อ)',
      description: json['description'] as String?,
      startTime: startDt,
      endTime: endDt,
      calendarId: json['calendarId'] as String? ?? 'primary',
      isAllDay: allDay,
      colorId: json['colorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'summary': title,
      'description': description,
      'start': isAllDay
          ? <String, dynamic>{'date': startTime.toIso8601String().substring(0, 10)}
          : <String, dynamic>{'dateTime': startTime.toIso8601String()},
      'end': isAllDay
          ? <String, dynamic>{'date': endTime.toIso8601String().substring(0, 10)}
          : <String, dynamic>{'dateTime': endTime.toIso8601String()},
      'colorId': colorId,
    };
  }

  /// ตรวจว่า Event นี้อยู่ในวันที่ระบุหรือไม่
  bool isOnDate(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }
}
