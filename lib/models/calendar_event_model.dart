/// lib/models/calendar_event_model.dart
/// โมเดล Google Calendar Event — Mapping จาก Calendar REST API
/// Enhanced: ตาม FR-2 รองรับข้อมูลเชิงลึก (location, attendees, status)
class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String calendarId;
  final bool isAllDay;
  final String? colorId;
  
  // Enhanced Fields (FR-2: Two-Way Sync Requirements)
  final String? location;
  final List<String>? attendees;
  final String? status; // 'confirmed', 'tentative', 'cancelled'
  final String? htmlLink;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.calendarId,
    this.isAllDay = false,
    this.colorId,
    this.location,
    this.attendees,
    this.status,
    this.htmlLink,
  });

  /// แปลงจาก Google Calendar API JSON Response
  /// Enhanced: ดึงข้อมูล location, attendees, status ตาม FR-2
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

    // Parse attendees (ผู้เข้าร่วม)
    final List<dynamic>? attendeesJson = json['attendees'] as List<dynamic>?;
    final List<String>? attendeeEmails = attendeesJson
        ?.map((dynamic a) => (a as Map<String, dynamic>)['email'] as String?)
        .where((String? email) => email != null)
        .cast<String>()
        .toList();

    return CalendarEventModel(
      id: json['id'] as String? ?? '',
      title: json['summary'] as String? ?? '(ไม่มีชื่อ)',
      description: json['description'] as String?,
      startTime: startDt,
      endTime: endDt,
      calendarId: json['calendarId'] as String? ?? 'primary',
      isAllDay: allDay,
      colorId: json['colorId'] as String?,
      location: json['location'] as String?,
      attendees: attendeeEmails,
      status: json['status'] as String?,
      htmlLink: json['htmlLink'] as String?,
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
      if (colorId != null) 'colorId': colorId,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
      if (attendees != null && attendees!.isNotEmpty)
        'attendees': attendees!.map((String email) => <String, String>{'email': email}).toList(),
    };
  }

  /// ตรวจว่า Event นี้อยู่ในวันที่ระบุหรือไม่
  bool isOnDate(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }

  /// ตรวจว่า Event นี้มาจากปฏิทินที่อ่านอย่างเดียว (e.g. Holidays, Public Calendar)
  /// ใช้สำหรับ skip การ update/delete
  bool get isReadOnly {
    // Public holidays or system calendars are read-only
    final String lowerTitle = title.toLowerCase();
    return lowerTitle.contains('holiday') || 
           lowerTitle.contains('วันหยุด') ||
           calendarId.contains('holiday') ||
           calendarId.contains('public');
  }
}
