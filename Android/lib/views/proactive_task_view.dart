/// lib/views/proactive_task_view.dart (Part 1)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/task_preparation_model.dart';
import '../models/calendar_event_model.dart';
import '../models/user_model.dart';
import 'theme/app_theme.dart';
import 'widgets/agenda_card.dart';

class ProactiveTaskView extends StatefulWidget {
  const ProactiveTaskView({super.key});
  @override
  State<ProactiveTaskView> createState() => _ProactiveTaskViewState();
}

class _ProactiveTaskViewState extends State<ProactiveTaskView> {
  final List<TaskPreparationModel> _preparations = <TaskPreparationModel>[];
  bool _isLoading = false;

  String _getRoleLabel(UserRole? role) {
    if (role == UserRole.student) return '📚 นักศึกษา';
    if (role == UserRole.corporateEmployee) return '💼 พนักงาน';
    if (role == UserRole.educator) return '🎓 ครู';
    return 'ผู้ใช้';
  }

  @override
  Widget build(BuildContext context) {
    final CalendarController calCtrl = Get.find<CalendarController>();
    final AiController aiCtrl = Get.find<AiController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('เตรียมงานล่วงหน้า', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: _buildBody(calCtrl, aiCtrl, authCtrl),
        ),
      ),
    );
  }

  Widget _buildBody(CalendarController calCtrl, AiController aiCtrl, AuthController authCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Obx(() => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text(_getRoleLabel(authCtrl.currentUser.value?.role),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
              )),
          _buildEventList(calCtrl, aiCtrl, authCtrl),
          if (_preparations.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const Text('ผลลัพธ์ที่สร้างแล้ว', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._preparations.map((TaskPreparationModel p) => AgendaCard(preparation: p)),
          ],
        ],
      ),
    );
  }

  Widget _buildEventList(CalendarController calCtrl, AiController aiCtrl, AuthController authCtrl) {
    return Obx(() {
      final List<CalendarEventModel> upcoming =
          calCtrl.events.where((CalendarEventModel e) => e.startTime.isAfter(DateTime.now())).take(5).toList();
      if (upcoming.isEmpty) {
        return const Padding(
            padding: EdgeInsets.all(20),
            child: Text('ไม่มีกิจกรรมที่กำลังจะมาถึง', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center));
      }
      return Column(children: upcoming.map((CalendarEventModel event) => _buildEventTile(event, aiCtrl, authCtrl)).toList());
    });
  }

  Widget _buildEventTile(CalendarEventModel event, AiController aiCtrl, AuthController authCtrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.event, color: AppTheme.accentPrimary),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${event.startTime.day}/${event.startTime.month}'),
        trailing: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  final String prep = await aiCtrl.generateEventPreparation(event);
                  Get.snackbar('AI Preparation', prep, snackPosition: SnackPosition.BOTTOM);
                  setState(() => _isLoading = false);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('สร้าง', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
