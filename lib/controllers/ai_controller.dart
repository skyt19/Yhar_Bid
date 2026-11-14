/// lib/controllers/ai_controller.dart
/// Controller จัดการการสื่อสารกับ Gemini AI
/// Refactored: ใช้ AiService Layer แทนการเรียก API โดยตรง (Clean Architecture)
/// Phase 1-3: Context-Aware AI with Dynamic Discovery
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/calendar_event_model.dart';
import '../models/context_snapshot_model.dart';
import '../models/ai_discovery_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/calendar_controller.dart';
import '../services/ai_service.dart';
import '../services/context_retrieval_service.dart';

class AiController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AiService _aiService = AiService();
  final ContextRetrievalService _contextService = ContextRetrievalService();

  final RxList<Map<String, String>> chatMessages = <Map<String, String>>[].obs;
  final RxBool isTyping = false.obs;
  final RxString errorMessage = ''.obs;

  // Phase 1-3: Context-Aware Analysis State
  final Rx<ContextSnapshot?> currentContext = Rx<ContextSnapshot?>(null);
  final Rx<AnalysisResult?> currentAnalysis = Rx<AnalysisResult?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxBool isLoadingContext = false.obs;
  final RxString analysisError = ''.obs;

  /// ส่งข้อความหา AI (Chat Interface)
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    chatMessages.add(<String, String>{'role': 'user', 'content': message});
    isTyping.value = true;
    errorMessage.value = '';
    
    try {
      final UserRole role = _authController.currentUser.value?.role ?? UserRole.student;
      final String aiResponse = await _aiService.chat(message: message, role: role);
      chatMessages.add(<String, String>{'role': 'assistant', 'content': aiResponse});
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาด: ${e.toString()}';
      chatMessages.add(<String, String>{'role': 'assistant', 'content': 'ขออภัย เกิดข้อผิดพลาดในการเชื่อมต่อ'});
    } finally {
      isTyping.value = false;
    }
  }

  /// Generate Event Preparation (Role-based)
  Future<String> generateEventPreparation(CalendarEventModel event) async {
    final UserRole role = _authController.currentUser.value?.role ?? UserRole.student;
    return await _aiService.generateEventPreparation(event: event, role: role);
  }

  /// Quick Prompt: สรุปงานสัปดาห์นี้
  Future<void> askWeeklySummary() async {
    await sendMessage('สรุปงานสัปดาห์นี้ให้หน่อย');
  }

  /// Quick Prompt: วิเคราะห์งานด่วน
  Future<void> askUrgentTasks() async {
    await sendMessage('ช่วยวิเคราะห์งานด่วนที่ต้องทำในวันนี้');
  }

  /// Quick Prompt: เตรียมหัวข้อประชุม/ส่งงาน
  Future<void> askMeetingPrep() async {
    await sendMessage('ช่วยเตรียมหัวข้อสั้นๆ สำหรับประชุม/ส่งงาน');
  }

  void clearChat() => chatMessages.clear();

  // ============================================================================
  // PHASE 1-3: CONTEXT-AWARE AI WITH DYNAMIC DISCOVERY
  // ============================================================================

  /// Phase 1: Retrieve complete user context
  /// Fetches tasks, calendar events, and user profile
  Future<void> retrieveContext() async {
    try {
      isLoadingContext.value = true;
      analysisError.value = '';

      // Get calendar events from CalendarController if available
      List<CalendarEventModel> calendarEvents = [];
      try {
        final calendarCtrl = Get.find<CalendarController>();
        calendarEvents = calendarCtrl.events.toList();
      } catch (e) {
        // CalendarController not initialized yet
      }

      // Retrieve context with calendar events
      final response = await _contextService.retrieveContextWithCalendar(calendarEvents);

      if (response.status && response.data != null) {
        currentContext.value = response.data;
      } else {
        analysisError.value = response.message;
      }
    } catch (e) {
      analysisError.value = 'ไม่สามารถโหลดข้อมูลได้: $e';
    } finally {
      isLoadingContext.value = false;
    }
  }

  /// Phase 2 & 3: Generate context-aware analysis with dynamic discovery
  /// AI reasons about user's situation and generates original task proposals
  Future<void> generateContextAwareAnalysis() async {
    try {
      isAnalyzing.value = true;
      analysisError.value = '';
      currentAnalysis.value = null;

      // Ensure context is loaded
      if (currentContext.value == null) {
        await retrieveContext();
      }

      final context = currentContext.value;
      if (context == null) {
        analysisError.value = 'ไม่สามารถโหลดข้อมูลได้';
        return;
      }

      // Check if context has data
      if (!context.hasData) {
        analysisError.value = 'ไม่พบข้อมูลที่ต้องวิเคราะห์';
        currentAnalysis.value = emptyAnalysisResult(
          message: 'ไม่พบงานหรือกิจกรรมในขณะนี้',
        );
        return;
      }

      // Call AI service for analysis
      final response = await _aiService.generateContextAwareAnalysis(
        context: context,
      );

      if (response.status && response.data != null) {
        currentAnalysis.value = response.data as AnalysisResult;
      } else {
        analysisError.value = response.message;
        currentAnalysis.value = emptyAnalysisResult(
          message: 'ไม่สามารถวิเคราะห์ข้อมูลได้',
        );
      }
    } catch (e) {
      analysisError.value = 'เกิดข้อผิดพลาด: $e';
      currentAnalysis.value = emptyAnalysisResult(
        message: 'เกิดข้อผิดพลาดในการวิเคราะห์',
      );
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Refresh context and re-analyze
  Future<void> refreshAnalysis() async {
    currentContext.value = null;
    currentAnalysis.value = null;
    await generateContextAwareAnalysis();
  }

  /// Clear analysis state
  void clearAnalysis() {
    currentContext.value = null;
    currentAnalysis.value = null;
    analysisError.value = '';
  }
}
