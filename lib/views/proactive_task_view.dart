/// lib/views/proactive_task_view.dart
/// Enhanced with Proactive Scan Button and Approval Workflow (FR-3, NFR-6)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/proactive_controller.dart';
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

  @override
  void initState() {
    super.initState();
    // ลง ProactiveController ถ้ายังไม่มี
    if (!Get.isRegistered<ProactiveController>()) {
      Get.put(ProactiveController());
    }
  }

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
    final ProactiveController proactiveCtrl = Get.find<ProactiveController>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Obx(() => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text(_getRoleLabel(authCtrl.currentUser.value?.role),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
              )),
          
          // ปุ่ม "ให้เลขาตรวจตารางและเตรียมงานทันที" (FR-3, NFR-6)
          Obx(() => ElevatedButton.icon(
                onPressed: proactiveCtrl.isScanning.value
                    ? null
                    : () async {
                        await proactiveCtrl.runProactiveScan();
                      },
                icon: proactiveCtrl.isScanning.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  proactiveCtrl.isScanning.value ? 'กำลังวิเคราะห์...' : 'ให้เลขาตรวจตารางและเตรียมงานทันที',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppTheme.accentGray,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              )),
          
          const SizedBox(height: 8),
          
          // แสดงสถานะการสแกน
          Obx(() => proactiveCtrl.statusMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    proactiveCtrl.statusMessage.value,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink()),
          
          const SizedBox(height: 16),
          
          // ส่วนแสดง Proposals ที่รอตรวจสอบ (Pending)
          Obx(() {
            final pendingProposals = proactiveCtrl.pendingProposals;
            
            if (pendingProposals.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('ข้อเสนอจากเลขา AI (รอตรวจสอบ)', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...pendingProposals.map((proposal) => _buildProposalCard(proposal, proactiveCtrl)),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Event List (เดิม)
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
        leading: const Icon(Icons.event, color: AppTheme.accentGreen),
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
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('สร้าง', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
  
  /// สร้างการ์ดแสดง Proposal พร้อมปุ่ม Approve/Reject (FR-3: Review & Approval UI)
  Widget _buildProposalCard(proposal, ProactiveController proactiveCtrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.auto_awesome, color: AppTheme.accentGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    proposal.event.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // AI Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  proposal.aiContent,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                
                if (proposal.suggestedTasks.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  const Text('งานย่อยที่แนะนำ:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...proposal.suggestedTasks.map((task) => Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(child: Text(task, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => proactiveCtrl.rejectProposal(proposal.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('ปฏิเสธ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: proactiveCtrl.isProcessing.value
                        ? null
                        : () => proactiveCtrl.approveProposal(proposal.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('อนุมัติและนำไปใช้'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

