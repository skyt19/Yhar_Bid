/// lib/models/habit_model.dart
/// โมเดลนิสัยและเป้าหมาย — เชื่อมกับบทบาทผู้ใช้ตาม SRS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final UserRole linkedRole; // นิสัยนี้ผูกกับบทบาทใด
  final List<DateTime> completedDates; // วันที่ทำสำเร็จ
  final int targetDaysPerWeek; // เป้าหมายต่อสัปดาห์
  final DateTime createdAt;
  final bool isActive;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.linkedRole,
    required this.completedDates,
    required this.targetDaysPerWeek,
    required this.createdAt,
    this.isActive = true,
  });

  /// คำนวณ Habit Success Rate รายสัปดาห์ (คืนค่า float 0.0-1.0)
  double calculateWeeklySuccessRate(DateTime weekStart) {
    final DateTime weekEnd = weekStart.add(const Duration(days: 7));
    final int completedThisWeek = completedDates
        .where((DateTime d) => d.isAfter(weekStart) && d.isBefore(weekEnd))
        .length;
    if (targetDaysPerWeek == 0) return 0.0;
    return (completedThisWeek / targetDaysPerWeek).clamp(0.0, 1.0);
  }

  /// ตรวจว่าทำนิสัยนี้แล้ววันนี้หรือยัง
  bool isCompletedToday() {
    final DateTime today = DateTime.now();
    return completedDates.any((DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }

  factory HabitModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data()!;
    final List<dynamic> rawDates = data['completedDates'] as List<dynamic>? ?? <dynamic>[];
    return HabitModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      linkedRole: UserRole.values.firstWhere(
        (UserRole r) => r.name == (data['linkedRole'] as String? ?? 'student'),
        orElse: () => UserRole.student,
      ),
      completedDates: rawDates
          .map((dynamic e) => (e as Timestamp).toDate())
          .toList(),
      targetDaysPerWeek: data['targetDaysPerWeek'] as int? ?? 5,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'linkedRole': linkedRole.name,
      'completedDates': completedDates.map((DateTime d) => Timestamp.fromDate(d)).toList(),
      'targetDaysPerWeek': targetDaysPerWeek,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
