/// lib/models/task_preparation_model.dart
/// โมเดลผลลัพธ์จาก AI เลขาเตรียมงานล่วงหน้า
/// แยกตามบทบาท: Student (Task Outline), Employee (Meeting Agenda), Educator (Lesson Structure)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// ประเภทการเตรียมงาน ตาม SRS Section 3 (FR-3)
enum PreparationContentType { taskOutline, meetingAgenda, lessonStructure }

class TaskPreparationModel {
  final String id;
  final String userId;
  final String linkedEventId; // Google Calendar Event ID
  final String eventTitle;
  final DateTime eventDateTime;
  final UserRole generatedForRole;
  final PreparationContentType contentType;
  final List<String> contentItems; // รายการหัวข้อที่ AI สร้างขึ้น
  final String rawAiResponse; // Response ดิบจาก Gemini API
  final DateTime generatedAt;
  final bool isOfflineFallback; // ใช้ fallback template หรือเปล่า

  const TaskPreparationModel({
    required this.id,
    required this.userId,
    required this.linkedEventId,
    required this.eventTitle,
    required this.eventDateTime,
    required this.generatedForRole,
    required this.contentType,
    required this.contentItems,
    required this.rawAiResponse,
    required this.generatedAt,
    this.isOfflineFallback = false,
  });

  /// Label แสดงประเภทเนื้อหาเป็นภาษาไทย
  String get contentTypeLabel {
    switch (contentType) {
      case PreparationContentType.taskOutline:
        return 'โครงร่างงาน (Task Outline)';
      case PreparationContentType.meetingAgenda:
        return 'วาระการประชุม (Meeting Agenda)';
      case PreparationContentType.lessonStructure:
        return 'โครงสร้างบทเรียน (Lesson Structure)';
    }
  }

  factory TaskPreparationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data()!;
    final List<dynamic> rawItems = data['contentItems'] as List<dynamic>? ?? <dynamic>[];
    return TaskPreparationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      linkedEventId: data['linkedEventId'] as String? ?? '',
      eventTitle: data['eventTitle'] as String? ?? '',
      eventDateTime: (data['eventDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      generatedForRole: UserRole.values.firstWhere(
        (UserRole r) => r.name == (data['generatedForRole'] as String? ?? 'student'),
        orElse: () => UserRole.student,
      ),
      contentType: PreparationContentType.values.firstWhere(
        (PreparationContentType t) => t.name == (data['contentType'] as String? ?? 'taskOutline'),
        orElse: () => PreparationContentType.taskOutline,
      ),
      contentItems: rawItems.cast<String>(),
      rawAiResponse: data['rawAiResponse'] as String? ?? '',
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOfflineFallback: data['isOfflineFallback'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'linkedEventId': linkedEventId,
      'eventTitle': eventTitle,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'generatedForRole': generatedForRole.name,
      'contentType': contentType.name,
      'contentItems': contentItems,
      'rawAiResponse': rawAiResponse,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'isOfflineFallback': isOfflineFallback,
    };
  }
}
