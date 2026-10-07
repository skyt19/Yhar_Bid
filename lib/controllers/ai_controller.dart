/// lib/controllers/ai_controller.dart
/// Controller จัดการการสื่อสารกับ Gemini AI
/// รวม Role-based prompt selection และ offline fallback templates
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/task_preparation_model.dart';
import '../models/calendar_event_model.dart';
import '../controllers/auth_controller.dart';

class AiController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final RxList<Map<String, String>> chatMessages = <Map<String, String>>[].obs;
  final RxBool isTyping = false.obs;
  final RxString errorMessage = ''.obs;

  // Offline Fallback Templates ตาม SRS Section 3.B
  static const Map<String, List<String>> _fallbackTaskOutlines = <String, List<String>>{
    'student': <String>[
      '1. อ่านทบทวนเนื้อหาที่เกี่ยวข้อง',
      '2. สรุปประเด็นหลักที่ต้องนำเสนอ',
      '3. เตรียมเอกสารและแหล่งอ้างอิง',
      '4. ทดลองฝึกซ้อมนำเสนอ',
      '5. ตรวจสอบ Deadline และรูปแบบการส่ง',
    ],
    'corporateEmployee': <String>[
      '1. ศึกษาวาระการประชุมล่วงหน้า',
      '2. รวบรวมข้อมูลที่เกี่ยวข้อง',
      '3. เตรียมคำถามและข้อเสนอแนะ',
      '4. สรุปประเด็นที่ต้องตัดสินใจ',
      '5. แจ้งผู้เกี่ยวข้องล่วงหน้า',
    ],
    'educator': <String>[
      '1. ทบทวนหัวข้อบทเรียนและวัตถุประสงค์',
      '2. เตรียม Slides และสื่อการสอน',
      '3. ออกแบบกิจกรรมและแบบฝึกหัด',
      '4. เตรียมตัวอย่างและกรณีศึกษา',
      '5. วางแผนการประเมินผลนักเรียน',
    ],
  };

  // Role-Based System Prompt Matrix ตาม SRS Section 3.A
  String _buildSystemPrompt(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'คุณคือ AI เลขานักศึกษา ช่วยตรวจ Deadline และสร้าง Task Outline ล่วงหน้า 3 วัน ตอบภาษาไทย กระชับ';
      case UserRole.corporateEmployee:
        return 'คุณคือ AI เลขาพนักงาน ช่วยเตรียม Meeting Agenda และ Discussion Points ตอบภาษาไทย กระชับ มืออาชีพ';
      case UserRole.educator:
        return 'คุณคือ AI เลขาครู ช่วยเตรียม Lesson Structure และ Exam Content ตอบภาษาไทย กระชับ';
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    chatMessages.add(<String, String>{'role': 'user', 'content': message});
    isTyping.value = true;
    errorMessage.value = '';
    try {
      final String? apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        await _sendFallbackResponse();
        return;
      }
      final UserRole role = _authController.currentUser.value?.role ?? UserRole.student;
      final Uri uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
      );
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(<String, dynamic>{
          'contents': <Map<String, dynamic>>[
            <String, dynamic>{
              'role': 'user',
              'parts': <Map<String, dynamic>>[
                <String, dynamic>{'text': '${_buildSystemPrompt(role)}\n\nUser: $message'},
              ],
            },
          ],
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> candidates = data['candidates'] as List<dynamic>? ?? <dynamic>[];
        if (candidates.isNotEmpty) {
          final String aiText = (((candidates.first as Map<String, dynamic>)['content']
                  as Map<String, dynamic>)['parts'] as List<dynamic>)
              .first['text'] as String? ?? '';
          chatMessages.add(<String, String>{'role': 'ai', 'content': aiText});
        }
      } else {
        await _sendFallbackResponse();
      }
    } catch (e) {
      await _sendFallbackResponse();
    } finally {
      isTyping.value = false;
    }
  }

  Future<void> _sendFallbackResponse() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    chatMessages.add(<String, String>{
      'role': 'ai',
      'content': 'ขออภัย ไม่สามารถเชื่อมต่อ AI ได้ขณะนี้ กรุณาลองใหม่อีกครั้ง',
    });
  }

  Future<TaskPreparationModel?> generateTaskPreparation(
    CalendarEventModel event,
    UserRole role,
    String userId,
  ) async {
    final List<String> items = _fallbackTaskOutlines[role.name] ?? _fallbackTaskOutlines['student']!;
    return TaskPreparationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      linkedEventId: event.id,
      eventTitle: event.title,
      eventDateTime: event.startTime,
      generatedForRole: role,
      contentType: _getContentType(role),
      contentItems: items,
      rawAiResponse: items.join('\n'),
      generatedAt: DateTime.now(),
      isOfflineFallback: true,
    );
  }

  PreparationContentType _getContentType(UserRole role) {
    switch (role) {
      case UserRole.student:
        return PreparationContentType.taskOutline;
      case UserRole.corporateEmployee:
        return PreparationContentType.meetingAgenda;
      case UserRole.educator:
        return PreparationContentType.lessonStructure;
    }
  }

  void clearChat() => chatMessages.clear();
}
