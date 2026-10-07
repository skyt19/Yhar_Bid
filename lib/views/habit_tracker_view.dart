/// lib/views/habit_tracker_view.dart
/// [Extrapolate SRS FR-4] — Role-Contextual Habit Tracker
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/habit_card.dart';

class HabitTrackerView extends StatelessWidget {
  const HabitTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController habitCtrl = Get.find<HabitController>();
    final AuthController authCtrl = Get.find<AuthController>();

    // ป้ายชื่อบทบาทตาม Role ปัจจุบัน
    String getRoleLabel(UserRole? role) {
      switch (role) {
        case UserRole.student:
          return 'นักศึกษา';
        case UserRole.corporateEmployee:
          return 'พนักงานองค์กร';
        case UserRole.educator:
          return 'ครู/อาจารย์';
        default:
          return 'ผู้ใช้งาน';
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('จัดการนิสัย', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusMedium), topRight: Radius.circular(AppTheme.radiusMedium)),
          ),
          child: Obx(() {
            final UserRole? role = authCtrl.currentUser.value?.role;
            final double rate = habitCtrl.weeklySuccessRate.value;

            return Column(
              children: <Widget>[
                // Summary Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('บทบาท: ${getRoleLabel(role)}',
                                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            const Text('ความสำเร็จสัปดาห์นี้', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      CircularProgressIndicator(
                        value: rate,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentSecondary),
                        strokeWidth: 8,
                      ),
                      const SizedBox(width: 12),
                      Text('${(rate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accentSecondary)),
                    ],
                  ),
                ),
                // Habit List
                Expanded(
                  child: habitCtrl.habits.isEmpty
                      ? const Center(child: Text('ยังไม่มีนิสัยที่กำหนด', style: TextStyle(color: AppTheme.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: habitCtrl.habits.length,
                          itemBuilder: (BuildContext ctx, int i) {
                            return HabitCard(
                              habit: habitCtrl.habits[i],
                              onMarkCompleted: () => habitCtrl.markHabitCompleted(habitCtrl.habits[i].id),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
