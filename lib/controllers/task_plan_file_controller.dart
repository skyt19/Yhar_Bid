/// lib/controllers/task_plan_file_controller.dart
/// Phase 4: Complete File Management System
/// Handles file lifecycle: list, preview, download, delete with proper state management

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/task_plan_file_model.dart';
import '../models/task_plan_document_model.dart';
import '../models/calendar_event_model.dart';
import '../models/user_model.dart';
import '../services/task_plan_txt_service.dart';
import '../services/task_plan_storage_service.dart';
import '../services/ai_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';

class TaskPlanFileController extends GetxController {
  final TaskPlanTxtService _txtService = TaskPlanTxtService();
  final TaskPlanStorageService _storageService = TaskPlanStorageService();
  final AiService _aiService = AiService();

  // Observable state
  final RxList<TaskPlanFile> files = <TaskPlanFile>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString statusMessage = ''.obs;
  final Rx<TaskPlanFile?> currentPreviewFile = Rx<TaskPlanFile?>(null);
  final RxString previewContent = ''.obs;

  // Diagnostic counts
  final RxInt eventsRetrieved = 0.obs;
  final RxInt eventsAccepted = 0.obs;
  final RxInt eventsSkipped = 0.obs;
  final RxInt eventsWithDescription = 0.obs;
  final RxInt eventsSentToAI = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFileList();
  }

  /// Phase 1-2-3 Integration: Generate Task Plan from Calendar
  Future<void> generateTaskPlanFromCalendar({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isGenerating.value = true;
      statusMessage.value = 'กำลังดึงข้อมูลปฏิทิน...';

      // Reset diagnostic counts
      eventsRetrieved.value = 0;
      eventsAccepted.value = 0;
      eventsSkipped.value = 0;
      eventsWithDescription.value = 0;
      eventsSentToAI.value = 0;

      // Get user and calendar data
      final authCtrl = Get.find<AuthController>();
      final calendarCtrl = Get.find<CalendarController>();
      final user = authCtrl.currentUser.value;

      if (user == null) {
        throw Exception('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      // Fetch events if not already loaded
      if (calendarCtrl.events.isEmpty) {
        await calendarCtrl.fetchEvents();
      }

      // PHASE 1: Calendar Data Retrieval and Validation
      final now = DateTime.now();
      final planStart = startDate ?? now;
      final planEnd = endDate ?? now.add(const Duration(days: 14));

      // Filter events within planning period
      final relevantEvents = calendarCtrl.events
          .where((event) =>
              event.startTime.isAfter(planStart) &&
              event.startTime.isBefore(planEnd) &&
              event.status != 'cancelled')
          .toList();

      eventsRetrieved.value = relevantEvents.length;

      if (relevantEvents.isEmpty) {
        throw Exception('ไม่พบกิจกรรมในช่วงเวลาที่เลือก');
      }

      debugPrint('📊 [TaskPlanFile] Phase 1 Diagnostics:');
      debugPrint('   Retrieved: ${eventsRetrieved.value} events');

      // Validate and accept events
      final validatedEvents = <CalendarEventModel>[];
      for (final event in relevantEvents) {
        // Validation criteria
        if (event.id.isEmpty) {
          eventsSkipped.value++;
          continue;
        }
        if (event.title.isEmpty || event.title == '(ไม่มีชื่อ)') {
          eventsSkipped.value++;
          continue;
        }

        // Track events with descriptions
        if (event.description != null && event.description!.isNotEmpty) {
          eventsWithDescription.value++;
        }

        validatedEvents.add(event);
        eventsAccepted.value++;
      }

      if (validatedEvents.isEmpty) {
        throw Exception('ไม่มีกิจกรรมที่ผ่านการตรวจสอบ');
      }

      debugPrint('   Accepted: ${eventsAccepted.value} events');
      debugPrint('   Skipped: ${eventsSkipped.value} events');
      debugPrint('   With descriptions: ${eventsWithDescription.value} events');

      // PHASE 2: AI Analysis for Each Event
      statusMessage.value = 'กำลังวิเคราะห์ด้วย AI...';
      final eventAnalyses = <EventAnalysis>[];

      for (final event in validatedEvents) {
        try {
          debugPrint('🤖 [TaskPlanFile] Analyzing: ${event.title}');

          // Call AI service
          final aiResponse = await _aiService.generateEventPreparationJson(
            event: event,
            role: user.role,
          );

          eventsSentToAI.value++;

          // Convert to EventAnalysis
          final analysis = EventAnalysis.fromCalendarAndAI(
            event: event,
            aiResponse: aiResponse,
          );

          if (!analysis.isValid) {
            debugPrint('⚠️ [TaskPlanFile] Invalid analysis for: ${event.title}');
            continue;
          }

          eventAnalyses.add(analysis);
          debugPrint('✅ [TaskPlanFile] Analysis complete: ${event.title}');
        } catch (e) {
          debugPrint('❌ [TaskPlanFile] AI analysis failed for ${event.title}: $e');
          // Continue with other events
        }
      }

      if (eventAnalyses.isEmpty) {
        throw Exception('ไม่สามารถวิเคราะห์กิจกรรมได้');
      }

      debugPrint('   Sent to AI: ${eventsSentToAI.value} events');
      debugPrint('   AI responses: ${eventAnalyses.length} valid analyses');

      // Create TaskPlanDocument
      final document = TaskPlanDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        generatedAt: DateTime.now(),
        planningStartDate: planStart,
        planningEndDate: planEnd,
        eventCount: eventAnalyses.length,
        events: eventAnalyses,
      );

      if (!document.isValid) {
        throw Exception('เอกสารแผนงานไม่ถูกต้อง');
      }

      // PHASE 3: TXT Generation
      statusMessage.value = 'กำลังสร้างไฟล์ TXT...';

      final txtBytes = _txtService.generateTxtBytes(document);

      // Validate TXT content
      if (!_txtService.validateTxtBytes(txtBytes)) {
        throw Exception('ไฟล์ TXT ไม่ถูกต้อง');
      }

      final txtContent = String.fromCharCodes(txtBytes);
      if (!_txtService.validateTxtContent(txtContent, document)) {
        throw Exception('เนื้อหาไฟล์ไม่ครบถ้วน');
      }

      debugPrint('✅ [TaskPlanFile] TXT generated: ${txtBytes.length} bytes');

      // Generate filename
      final filename = _txtService.generateFilename(document.generatedAt);

      // Upload to Firebase Storage
      statusMessage.value = 'กำลังอัปโหลดไฟล์...';

      final sourceEventIds = eventAnalyses.map((e) => e.eventId).toList();

      final fileMetadata = await _storageService.uploadTaskPlan(
        filename: filename,
        txtBytes: txtBytes,
        planningStartDate: planStart,
        planningEndDate: planEnd,
        sourceEventIds: sourceEventIds,
        eventCount: eventAnalyses.length,
      );

      debugPrint('✅ [TaskPlanFile] File uploaded: ${fileMetadata.id}');

      // Refresh file list
      await refreshFileList();

      statusMessage.value = 'สร้างแผนงานสำเร็จ';

      Get.snackbar(
        'สำเร็จ',
        'สร้างแผนการเตรียมงาน ${eventAnalyses.length} รายการแล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      statusMessage.value = 'เกิดข้อผิดพลาด: $e';
      debugPrint('❌ [TaskPlanFile] Generation failed: $e');

      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถสร้างแผนงานได้: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  /// Phase 4: List Files
  Future<void> refreshFileList() async {
    try {
      isLoading.value = true;
      statusMessage.value = 'กำลังโหลดรายการไฟล์...';

      final fileList = await _storageService.listUserFiles();
      files.assignAll(fileList);

      statusMessage.value = 'พบไฟล์ ${fileList.length} รายการ';
      debugPrint('📂 [TaskPlanFile] Loaded ${fileList.length} files');
    } catch (e) {
      statusMessage.value = 'ไม่สามารถโหลดรายการไฟล์ได้';
      debugPrint('❌ [TaskPlanFile] List refresh failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Phase 4: Preview File
  Future<void> previewFile(TaskPlanFile file) async {
    try {
      isLoading.value = true;
      statusMessage.value = 'กำลังโหลดตัวอย่าง...';

      final content = await _storageService.downloadFile(file);

      currentPreviewFile.value = file;
      previewContent.value = content;
      statusMessage.value = 'แสดงตัวอย่าง: ${file.filename}';

      debugPrint('📖 [TaskPlanFile] Preview loaded: ${content.length} chars');
    } catch (e) {
      statusMessage.value = 'ไม่สามารถแสดงตัวอย่างได้';
      debugPrint('❌ [TaskPlanFile] Preview failed: $e');

      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถแสดงตัวอย่างไฟล์ได้',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Phase 4: Request Delete Confirmation
  void requestDeleteConfirmation(TaskPlanFile file) {
    final index = files.indexWhere((f) => f.id == file.id);
    if (index == -1) return;

    // Update state to confirmation_requested
    files[index] = file.copyWith(
      deletionState: FileDeletionState.confirmationRequested,
    );
  }

  /// Phase 4: Cancel Delete
  void cancelDelete(TaskPlanFile file) {
    final index = files.indexWhere((f) => f.id == file.id);
    if (index == -1) return;

    // Return to idle state
    files[index] = file.copyWith(
      deletionState: FileDeletionState.idle,
    );
  }

  /// Phase 4: Delete File (confirmed)
  Future<void> deleteFile(TaskPlanFile file) async {
    final index = files.indexWhere((f) => f.id == file.id);
    if (index == -1) return;

    try {
      // Update state to deleting
      files[index] = file.copyWith(
        deletionState: FileDeletionState.deleting,
      );

      statusMessage.value = 'กำลังลบไฟล์...';

      // Perform deletion
      final success = await _storageService.deleteFile(file);

      if (success) {
        // Update state to deleted
        files[index] = file.copyWith(
          deletionState: FileDeletionState.deleted,
        );

        // Remove from list
        files.removeAt(index);

        statusMessage.value = 'ลบไฟล์สำเร็จ';

        debugPrint('✅ [TaskPlanFile] File deleted: ${file.filename}');

        Get.snackbar(
          'สำเร็จ',
          'ลบไฟล์ ${file.filename} แล้ว',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('การลบไม่สมบูรณ์');
      }
    } catch (e) {
      // Update state to failed
      files[index] = file.copyWith(
        deletionState: FileDeletionState.failed,
      );

      statusMessage.value = 'ลบไฟล์ไม่สำเร็จ';
      debugPrint('❌ [TaskPlanFile] Delete failed: $e');

      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถลบไฟล์ได้: $e',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Return to idle after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (index < files.length) {
        files[index] = file.copyWith(
          deletionState: FileDeletionState.idle,
        );
      }
    }
  }

  /// Clear preview
  void clearPreview() {
    currentPreviewFile.value = null;
    previewContent.value = '';
  }
}
