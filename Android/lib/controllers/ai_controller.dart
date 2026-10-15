/// lib/controllers/ai_controller.dart
/// Controller จัดการการสื่อสารกับ Gemini AI
/// Refactored: ใช้ AiService Layer แทนการเรียก API โดยตรง (Clean Architecture)
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/calendar_event_model.dart';
import '../controllers/auth_controller.dart';
import '../services/ai_service.dart';

class AiController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AiService _aiService = AiService();
  
  final RxList<Map<String, String>> chatMessages = <Map<String, String>>[].obs;
  final RxBool isTyping = false.obs;
  final RxString errorMessage = ''.obs;

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
}
