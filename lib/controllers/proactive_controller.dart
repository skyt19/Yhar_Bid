/// lib/controllers/proactive_controller.dart
/// Controller จัดการ Proactive Secretary Workflow พร้อม User Approval System
/// ตาม FR-3, NFR-6: Proactive Secretary & User Review Flow

import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../models/user_model.dart';
import '../models/task_preparation_model.dart';
import '../services/ai_service.dart';
import '../services/google_calendar_service.dart';
import '../services/auth_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/analytics_controller.dart';

/// สถานะของการเตรียมงาน
enum PreparationStatus {
  pending,    // รอตรวจสอบ
  approved,   // อนุมัติแล้ว
  rejected,   // ปฏิเสธ
}

/// โมเดลของ AI Preparation Proposal
class PreparationProposal {
  final String id;
  final CalendarEventModel event;
  final String aiContent;
  final PreparationStatus status;
  final DateTime createdAt;
  final List<String> suggestedTasks;

  const PreparationProposal({
    required this.id,
    required this.event,
    required this.aiContent,
    required this.status,
    required this.createdAt,
    required this.suggestedTasks,
  });

  PreparationProposal copyWith({
    String? id,
    CalendarEventModel? event,
    String? aiContent,
    PreparationStatus? status,
    DateTime? createdAt,
    List<String>? suggestedTasks,
  }) {
    return PreparationProposal(
      id: id ?? this.id,
      event: event ?? this.event,
      aiContent: aiContent ?? this.aiContent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      suggestedTasks: suggestedTasks ?? this.suggestedTasks,
    );
  }
}

class ProactiveController extends GetxController {
  final AiService _aiService = AiService();
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  final AuthService _authService = AuthService();

  final RxList<PreparationProposal> proposals = <PreparationProposal>[].obs;
  final RxBool isScanning = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString statusMessage = ''.obs;
  final RxInt scannedEventsCount = 0.obs;
  final RxInt generatedProposalsCount = 0.obs;

  /// Getter: รายการข้อเสนอที่รอตรวจสอบ (Pending Proposals)
  List<PreparationProposal> get pendingProposals =>
      proposals.where((PreparationProposal p) => p.status == PreparationStatus.pending).toList();


  /// รัน Proactive Scan: สแกนปฎิทินและสร้างข้อเสนอจาก AI
  /// ตาม FR-3: Proactive Secretary Workflow
  /// [specificEventId] ใช้สำหรับวิเคราะห์เฉพาะงานเดียว (optional)
  Future<void> runProactiveScan({String? specificEventId}) async {
    try {
      isScanning.value = true;
      statusMessage.value = 'กำลังสแกนตารางปฏิทิน...';
      scannedEventsCount.value = 0;
      generatedProposalsCount.value = 0;

      // ดึงข้อมูลผู้ใช้และ Calendar Controller
      final AuthController authCtrl = Get.find<AuthController>();
      final CalendarController calCtrl = Get.find<CalendarController>();
      final UserModel? user = authCtrl.currentUser.value;

      if (user == null) {
        Get.snackbar('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อนใช้งาน',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // ตรวจสอบว่ามี Events ในปฏิทินหรือยัง
      if (calCtrl.events.isEmpty) {
        await calCtrl.fetchEvents();
      }

      if (calCtrl.events.isEmpty) {
        statusMessage.value = 'ไม่พบกิจกรรมในปฏิทิน';
        Get.snackbar('แจ้งเตือน', 'ไม่พบกิจกรรมในปฏิทิน',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // กรอง Events ตาม specificEventId (ถ้ามี) หรือ 3 วัน (ตาม SRS FR-3)
      final DateTime now = DateTime.now();
      final DateTime threeDaysLater = now.add(const Duration(days: 3));

      List<CalendarEventModel> upcomingEvents;
      
      if (specificEventId != null) {
        // สแกนเฉพาะงานที่ระบุ
        upcomingEvents = calCtrl.events
            .where((CalendarEventModel e) => e.id == specificEventId)
            .toList();
        if (upcomingEvents.isEmpty) {
          statusMessage.value = 'ไม่พบงานที่ระบุ';
          Get.snackbar('ข้อผิดพลาด', 'ไม่พบงานที่ต้องการวิเคราะห์',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      } else {
        // สแกนทั้งหมดภายใน 3 วัน
        upcomingEvents = calCtrl.events
            .where((CalendarEventModel e) =>
                e.startTime.isAfter(now) && e.startTime.isBefore(threeDaysLater))
            .toList();
      }

      scannedEventsCount.value = upcomingEvents.length;

      if (upcomingEvents.isEmpty) {
        statusMessage.value = 'ไม่พบกิจกรรมที่กำลังจะมาถึงภายใน 3 วัน';
        Get.snackbar('แจ้งเตือน', 'ไม่พบกิจกรรมที่ต้องเตรียมล่วงหน้า',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      statusMessage.value = 'พบ ${upcomingEvents.length} กิจกรรม กำลังวิเคราะห์...';

      // สร้าง Preparation Proposals สำหรับแต่ละ Event
      for (final CalendarEventModel event in upcomingEvents) {
        statusMessage.value = 'กำลังวิเคราะห์: ${event.title}...';

        try {
          // SPECIFICATION #2 & #5: เรียก AI Service แบบ JSON Schema
          final Map<String, dynamic> aiResult = await _aiService.generateProactiveTaskPreparationJson(
            event: event,
            role: user.role,
          );

          // Extract action_items from JSON response
          final List<String> actionItems = (aiResult['action_items'] as List<dynamic>?)
              ?.map((item) => item.toString()).toList() ?? <String>[];
          final String summary = aiResult['summary'] as String? ?? event.title;
          final String notification = aiResult['notification'] as String? ?? 'อย่าลืมเตรียมตัว';

          // สร้าง Proposal
          final PreparationProposal proposal = PreparationProposal(
            id: '${event.id}_${DateTime.now().millisecondsSinceEpoch}',
            event: event,
            aiContent: summary,
            status: PreparationStatus.pending,
            createdAt: DateTime.now(),
            suggestedTasks: actionItems,
          );

          proposals.add(proposal);
          generatedProposalsCount.value++;

          // SPECIFICATION #5: Auto-populate Tasks to TaskController
          await _autoPopulateTasksToController(event, actionItems);
        } catch (e) {
          print('⚠️ Failed to generate preparation for event ${event.id}: $e');
        }
      }

      statusMessage.value =
          'สร้างข้อเสนอเสร็จสิ้น: ${generatedProposalsCount.value} รายการ';

      if (generatedProposalsCount.value > 0) {
        Get.snackbar(
          'สำเร็จ',
          'เลขา AI เตรียมงานเสร็จแล้ว ${generatedProposalsCount.value} รายการ',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      statusMessage.value = 'เกิดข้อผิดพลาด: ${e.toString()}';
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถสแกนปฏิทินได้: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isScanning.value = false;
    }
  }

  /// แยก Sub-tasks จากเนื้อหาที่ AI สร้างมา
  /// รองรับทั้ง Markdown list (- , *, 1.) และ Numbered list
  List<String> _extractTasksFromAIContent(String content) {
    final List<String> tasks = <String>[];
    final List<String> lines = content.split('\n');

    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // ตรวจจับรูปแบบ: - task, * task, 1. task, หรือ 1) task
      if (RegExp(r'^[-*•]\s+').hasMatch(trimmed)) {
        tasks.add(trimmed.replaceFirst(RegExp(r'^[-*•]\s+'), ''));
      } else if (RegExp(r'^\d+[.)]\s+').hasMatch(trimmed)) {
        tasks.add(trimmed.replaceFirst(RegExp(r'^\d+[.)]\s+'), ''));
      }
    }

    return tasks;
  }

  /// ผู้ใช้กดอนุมัติข้อเสนอ (Approve & Sync)
  /// ตาม FR-3: User Review & Approval Workflow
  Future<void> approveProposal(String proposalId) async {
    try {
      isProcessing.value = true;
      final int index = proposals.indexWhere((PreparationProposal p) => p.id == proposalId);

      if (index == -1) {
        Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อเสนอนี้', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final PreparationProposal proposal = proposals[index];

      // อัปเดตสถานะเป็น Approved
      proposals[index] = proposal.copyWith(status: PreparationStatus.approved);

      // 1. ซิงค์กลับไป Google Calendar (อัปเดต Description)
      await _syncToGoogleCalendar(proposal);

      // 2. สร้าง Sub-tasks ใน Task Tracker (ถ้ามี)
      if (proposal.suggestedTasks.isNotEmpty) {
        await _createTasksFromProposal(proposal);
      }

      Get.snackbar(
        'สำเร็จ',
        'อนุมัติและซิงค์ข้อมูลเรียบร้อยแล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถอนุมัติได้: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  /// ผู้ใช้กดปฏิเสธข้อเสนอ
  Future<void> rejectProposal(String proposalId) async {
    final int index = proposals.indexWhere((PreparationProposal p) => p.id == proposalId);

    if (index != -1) {
      proposals[index] = proposals[index].copyWith(status: PreparationStatus.rejected);
      Get.snackbar('ปฏิเสธแล้ว', 'ลบข้อเสนอออกจากรายการ',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// ซิงค์โครงร่างที่อนุมัติแล้วกลับไป Google Calendar
  /// ตาม FR-2: Two-Way Calendar Sync (Write Back)
  Future<void> _syncToGoogleCalendar(PreparationProposal proposal) async {
    try {
      final String? token = await _authService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบ Access Token');
      }

      // รวม Description เดิม + โครงร่างจาก AI
      final String originalDesc = proposal.event.description ?? '';
      final String newDescription = '''$originalDesc

--- เตรียมงานโดย Yharbid AI Secretary ---
${proposal.aiContent}
''';

      // เรียก updateEvent API
      final CalendarServiceResponse response = await _calendarService.updateEvent(
        token,
        eventId: proposal.event.id,
        title: proposal.event.title,
        startTime: proposal.event.startTime,
        endTime: proposal.event.endTime,
        description: newDescription,
        isAllDay: proposal.event.isAllDay,
        colorId: proposal.event.colorId,
      );


      if (!response.status) {
        throw Exception(response.message);
      }

      print('✅ Synced preparation to Google Calendar: ${proposal.event.title}');
    } catch (e) {
      print('⚠️ Failed to sync to Google Calendar: $e');
      throw Exception('ไม่สามารถซิงค์กลับ Google Calendar ได้');
    }
  }

  /// Auto-populate tasks to TaskController from AI action items (FR-3 + FR-4 + FR-6 Integration)
  /// Specification #5: Automatically populate tasks to "งานและโปรเจกต์" view
  /// FIXED: Create ONE parent task per event (not multiple sub-item duplicates)
  /// STRENGTHENED DEDUPLICATION: Uses event.id as unique identifier
  Future<void> _autoPopulateTasksToController(
    CalendarEventModel event,
    List<String> actionItems,
  ) async {
    try {
      final TaskController taskCtrl = Get.find<TaskController>();
      
      // STRICT DEDUPLICATION: Check if task for this EXACT event.id already exists
      // Search by Event ID marker (most reliable) OR exact title match
      final bool taskExists = taskCtrl.tasks.any((task) => 
        task.description.contains('Event ID: ${event.id}') || 
        (task.title == event.title && task.dueDate?.isAtSameMomentAs(event.startTime) == true));
      
      if (taskExists) {
        print('⚠️ [ProactiveController] Task for event "${event.title}" (ID: ${event.id}) already exists. Skipping duplicate.');
        return;
      }
      
      // Consolidate ALL action items into a single description (no separate task cards per bullet)
      final String consolidatedOutline = actionItems.isNotEmpty
          ? '**AI Preparation Outline:**\n\n${actionItems.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}\n\n---\nEvent ID: ${event.id}'
          : 'เตรียมตัวสำหรับ: ${event.title}\n\n---\nEvent ID: ${event.id}';
      
      // Create EXACTLY ONE task card per event (never loop through actionItems to create separate tasks)
      await taskCtrl.addTask(
        title: event.title,
        description: consolidatedOutline,
        dueDate: event.startTime,
        category: 'งานทั่วไป',
        priority: 'Medium',
      );

      // Recalculate FR-6 analytics metrics
      try {
        final analyticsCtrl = Get.find<AnalyticsController>();
        await analyticsCtrl.recalculateMetrics();
      } catch (e) {
        print('⚠️ Analytics controller not available: $e');
      }

      print('✅ [ProactiveController] Created 1 consolidated task for event: "${event.title}" (ID: ${event.id})');
    } catch (e) {
      print('⚠️ [ProactiveController] Failed to auto-populate task: $e');
    }
  }

  /// Create sub-tasks from approved proposal (legacy method for approval workflow)
  Future<void> _createTasksFromProposal(PreparationProposal proposal) async {
    await _autoPopulateTasksToController(proposal.event, proposal.suggestedTasks);
  }

  /// ลบข้อมูล Proposals ทั้งหมด
  void clearProposals() {
    proposals.clear();
    scannedEventsCount.value = 0;
    generatedProposalsCount.value = 0;
    statusMessage.value = '';
  }
}

