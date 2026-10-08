/// lib/services/ai_service.dart (Part 1/2)
/// Service Layer สำหรับ Gemini/Gemma AI Integration
/// รองรับ Role-based prompts พร้อม Offline Fallback Templates
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/calendar_event_model.dart';

/// Standard AI Service Response Format
class AiServiceResponse {
  final bool status;
  final String message;
  final dynamic data;
  const AiServiceResponse({required this.status, required this.message, this.data});
}

/// AI Service Layer — Pure Business Logic, ไม่ depend on Controllers
class AiService {
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  /// Gemma Model Fallback Chain ตามคำสั่ง: gemma-4-26b-a4b-it → gemma-4-31b-it
  static const List<String> _modelPriority = <String>[
    'gemma-4-26b-a4b-it',      // PRIMARY: Gemma 4 26B Apex Instruction-Tuned
    'gemma-4-31b-it',          // FALLBACK: Gemma 4 31B Instruction-Tuned
  ];

  /// Offline Fallback Templates ตาม .clinerules Section 3.B
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
      '5. แจ้งผู้เกี่ยวข้องล่วงหน่า',
    ],
    'educator': <String>[
      '1. ทบทวนหัวข้อบทเรียนและวัตถุประสงค์',
      '2. เตรียม Slides และสื่อการสอน',
      '3. ออกแบบกิจกรรมและแบบฝึกหัด',
      '4. เตรียมตัวอย่างและกรณีศึกษา',
      '5. วางแผนการประเมินผลนักเรียน',
    ],
  };

  /// Role-Based System Prompt Matrix ตาม SRS Section 3.A
  String _buildSystemPrompt(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'คุณคือ AI เลขานักศึกษา ช่วยตรวจ Deadline และสร้าง Task Outline ล่วงหน้า 3 วัน ตอบภาษาไทย กระชับ ไม่เกิน 120 คำ';
      case UserRole.corporateEmployee:
        return 'คุณคือ AI เลขาพนักงาน ช่วยเตรียม Meeting Agenda และ Discussion Points ตอบภาษาไทย กระชับ มืออาชีพ ไม่เกิน 120 คำ';
      case UserRole.educator:
        return 'คุณคือ AI เลขาครู ช่วยเตรียม Lesson Structure และ Exam Content ตอบภาษาไทย กระชับ ไม่เกิน 120 คำ';
    }
  }

  /// Generate Content with Gemini/Gemma API (Fallback Chain)
  Future<AiServiceResponse> generateContent({
    required String prompt,
    required UserRole role,
    int maxTokens = 512,
  }) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return AiServiceResponse(status: false, message: 'GEMINI_API_KEY ไม่พบใน .env', data: _getFallbackTemplate(role));
    }

    final String systemPrompt = _buildSystemPrompt(role);
    final String fullPrompt = '$systemPrompt\n\n$prompt';

    for (String model in _modelPriority) {
      try {
        final Uri uri = Uri.parse('$_geminiBaseUrl/$model:generateContent?key=$apiKey');
        final http.Response response = await http.post(
          uri,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: json.encode(<String, dynamic>{
            'contents': <Map<String, dynamic>>[
              <String, dynamic>{'role': 'user', 'parts': <Map<String, dynamic>>[<String, dynamic>{'text': fullPrompt}]},
            ],
            'generationConfig': <String, dynamic>{'maxOutputTokens': maxTokens, 'temperature': 0.7},
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          final List<dynamic> candidates = data['candidates'] as List<dynamic>? ?? <dynamic>[];
          if (candidates.isNotEmpty) {
            final String aiText = (((candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>)['parts'] as List<dynamic>).first['text'] as String? ?? '';
            if (aiText.isNotEmpty) return AiServiceResponse(status: true, message: 'สำเร็จ (Model: $model)', data: aiText);
          }
        } else if (response.statusCode == 404) {
          continue;
        }
      } catch (e) {
        continue;
      }
    }
    return AiServiceResponse(status: false, message: 'ใช้ Offline Template', data: _getFallbackTemplate(role));
  }

  String _getFallbackTemplate(UserRole role) {
    final List<String> items = _fallbackTaskOutlines[role.name] ?? _fallbackTaskOutlines['student']!;
    return '📝 **แนวทางการเตรียมงาน**\n\n${items.join('\n')}';
  }

  String _getFallbackPreparation(CalendarEventModel event, UserRole role) {
    final List<String> items = _fallbackTaskOutlines[role.name] ?? _fallbackTaskOutlines['student']!;
    return '📋 **เตรียมตัวสำหรับ: ${event.title}**\n\n${items.join('\n')}';
  }

  Future<String> generateEventPreparation({required CalendarEventModel event, required UserRole role}) async {
    final String prompt = 'งานที่จะถึง: ${event.title}\nรายละเอียด: ${event.description ?? 'ไม่มีรายละเอียด'}\nเวลา: ${event.startTime}\n\nช่วยสรุปหัวข้อเตรียมตัวสำหรับงานนี้ (ไม่เกิน 5 ข้อ)';
    final AiServiceResponse response = await generateContent(prompt: prompt, role: role, maxTokens: 256);
    return (response.status && response.data != null) ? response.data as String : _getFallbackPreparation(event, role);
  }

  Future<String> chat({required String message, required UserRole role}) async {
    final AiServiceResponse response = await generateContent(prompt: message, role: role, maxTokens: 512);
    return (response.status && response.data != null) ? response.data as String : 'ขออภัย ไม่สามารถเชื่อมต่อ AI ได้ในขณะนี้';
  }
}
