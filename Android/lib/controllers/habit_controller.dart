/// lib/controllers/habit_controller.dart
/// Controller จัดการ Habit Tracking — CRUD Habits, คำนวณ Success Rate
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

class HabitController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<HabitModel> habits = <HabitModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble weeklySuccessRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleHabits();
  }

  /// โหลดตัวอย่าง Habits ตามบทบาท (ใน production จะดึงจาก Firestore)
  void _loadSampleHabits() {
    final UserRole role = _authController.currentUser.value?.role ?? UserRole.student;
    habits.value = _getSampleHabitsForRole(role);
    _calculateWeeklySuccessRate();
  }

  /// สร้าง Habits ตัวอย่างตามบทบาท
  List<HabitModel> _getSampleHabitsForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return <HabitModel>[
          HabitModel(
            id: 'h1',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'อ่านหนังสือ 1 ชั่วโมง',
            description: 'อ่านและทบทวนบทเรียนประจำวัน',
            linkedRole: UserRole.student,
            completedDates: <DateTime>[
              DateTime.now().subtract(const Duration(days: 1)),
              DateTime.now().subtract(const Duration(days: 2)),
            ],
            targetDaysPerWeek: 5,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          HabitModel(
            id: 'h2',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'ทบทวนงานส่ง',
            description: 'ตรวจสอบ Deadline งานส่งประจำสัปดาห์',
            linkedRole: UserRole.student,
            completedDates: <DateTime>[DateTime.now()],
            targetDaysPerWeek: 3,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
      case UserRole.corporateEmployee:
        return <HabitModel>[
          HabitModel(
            id: 'h3',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'เตรียม Daily Report',
            description: 'สรุปผลงานประจำวันก่อนเลิกงาน',
            linkedRole: UserRole.corporateEmployee,
            completedDates: <DateTime>[DateTime.now()],
            targetDaysPerWeek: 5,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          HabitModel(
            id: 'h4',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'อ่าน Email สำคัญ',
            description: 'ตรวจสอบและตอบ Email สำคัญทุกเช้า',
            linkedRole: UserRole.corporateEmployee,
            completedDates: <DateTime>[
              DateTime.now().subtract(const Duration(days: 1)),
            ],
            targetDaysPerWeek: 5,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
      case UserRole.educator:
        return <HabitModel>[
          HabitModel(
            id: 'h5',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'เตรียมแผนการสอน',
            description: 'จัดเตรียมแผนการสอนสำหรับวันถัดไป',
            linkedRole: UserRole.educator,
            completedDates: <DateTime>[DateTime.now()],
            targetDaysPerWeek: 5,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          HabitModel(
            id: 'h6',
            userId: _authController.currentUser.value?.uid ?? '',
            title: 'ตรวจการบ้านนักเรียน',
            description: 'ตรวจและให้คะแนนการบ้านนักเรียน',
            linkedRole: UserRole.educator,
            completedDates: <DateTime>[
              DateTime.now().subtract(const Duration(days: 2)),
            ],
            targetDaysPerWeek: 3,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
    }
  }

  /// มาร์คว่าทำนิสัยนี้แล้ววันนี้
  Future<void> markHabitCompleted(String habitId) async {
    final int index = habits.indexWhere((HabitModel h) => h.id == habitId);
    if (index == -1) return;
    final HabitModel habit = habits[index];
    if (habit.isCompletedToday()) return; // ทำแล้ววันนี้
    final List<DateTime> updatedDates = List<DateTime>.from(habit.completedDates)
      ..add(DateTime.now());
    habits[index] = HabitModel(
      id: habit.id,
      userId: habit.userId,
      title: habit.title,
      description: habit.description,
      linkedRole: habit.linkedRole,
      completedDates: updatedDates,
      targetDaysPerWeek: habit.targetDaysPerWeek,
      createdAt: habit.createdAt,
    );
    _calculateWeeklySuccessRate();
  }

  /// คำนวณ Habit Success Rate รวมทุกนิสัย รายสัปดาห์
  void _calculateWeeklySuccessRate() {
    if (habits.isEmpty) {
      weeklySuccessRate.value = 0.0;
      return;
    }
    final DateTime weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final double total = habits.fold<double>(
      0.0,
      (double sum, HabitModel h) => sum + h.calculateWeeklySuccessRate(weekStart),
    );
    weeklySuccessRate.value = (total / habits.length).clamp(0.0, 1.0);
  }
}
