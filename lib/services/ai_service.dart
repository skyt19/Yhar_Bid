/// lib/services/ai_service.dart
/// AI Service Layer — Routes Groq requests through a Supabase Edge Function
/// proxy so that GROQ_API_KEY never ships to the Flutter Web client.
///
/// Architecture:
///   Flutter Web (Firebase Hosting) -> Firebase Auth -> Supabase Edge Function -> Groq API
///
/// The proxy verifies the Firebase ID Token (RS256, Google public certs),
/// then forwards the request to Groq with the server-side GROQ_API_KEY.
/// Groq model is LOCKED to openai/gpt-oss-20b in both client and proxy.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/calendar_event_model.dart';
import '../models/context_snapshot_model.dart';
import '../models/ai_discovery_model.dart';
import '../core/config/app_config.dart';
import 'ai_service_types.dart';

/// Standard AI Service Response Format
class AiServiceResponse {
  final bool status;
  final String message;
  final dynamic data;
  const AiServiceResponse({required this.status, required this.message, this.data});
}

/// AI Service Layer — Proxied Groq API via Supabase Edge Function
class AiService {
  /// CRITICAL: LOCKED GROQ MODEL - NEVER CHANGE THIS
  /// This model is permanently locked and cannot be overridden
  static const String _LOCKED_GROQ_MODEL = 'openai/gpt-oss-20b';

  /// Supabase Edge Function endpoint (proxies to Groq with server-side key)
  static const String _proxyUrl =
      'https://aanochhlejpbhdhkgjpx.supabase.co/functions/v1/groq-proxy';

  /// Get the locked model identifier - IMMUTABLE
  static String get lockedModel => _LOCKED_GROQ_MODEL;

  /// Offline Fallback Templates
  static const Map<String, List<String>> _fallbackTaskOutlines = <String, List<String>>{
    'student': <String>[
      'อ่านทบทวนเนื้อหาที่เกี่ยวข้อง',
      'สรุปประเด็นหลักที่ต้องนำเสนอ',
      'เตรียมเอกสารและแหล่งอ้างอิง',
      'ทดลองฝึกซ้อมนำเสนอ',
      'ตรวจสอบ Deadline และรูปรูปแบบการส่ง',
    ],
    'corporateEmployee': <String>[
      'ศึกษาวาระการประชุมล่วงหน้า',
      'รวบรวมข้อมูลที่เกี่ยวข้อง',
      'เตรียมคำถามและข้อเสนอแนะ',
      'สรุปประเด็นที่ต้องตัดสินใจ',
      'แจ้งผู้เกี่ยวข้องล่วงหน้า',
    ],
    'educator': <String>[
      'ทบทวนหัวข้อบทเรียนและวัตถุประสงค์',
      'เตรียม Slides และสื่อการสอน',
      'ออกแบบกิจกรรมและแบบฝึกหัด',
      'เตรียมตัวอย่างและกรณีศึกษา',
      'วางแผนการประเมินผลนักเรียน',
    ],
  };

  /// Verify Firebase Auth is active and return a fresh ID Token
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ [AiService] Firebase Auth: No authenticated user');
      return null;
    }
    // firebase_auth ^4.x: getIdToken takes a positional forceRefresh bool.
    // Force refresh ensures a valid token even after a long-idle session.
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      debugPrint('❌ [AiService] getIdToken returned empty token');
      return null;
    }
    return idToken;
  }

  /// Call the Supabase proxy with a Firebase-authenticated request.
  Future<Map<String, dynamic>> _callProxy({
    required String operation,
    required List<Map<String, String>> messages,
    int maxTokens = 500,
    double temperature = 0.7,
  }) async {
    final idToken = await _getIdToken();
    if (idToken == null) {
      throw Exception('Authentication required');
    }

    final body = json.encode({
      'operation': operation,
      'messages': messages,
      'max_tokens': maxTokens,
      'temperature': temperature,
    });

    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
        'apikey': AppConfig.supabasePublishableKey,
      },
      body: body,
    ).timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['ok'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception('Proxy returned malformed success body');
    }

    final errBody = response.body.length > 200
        ? response.body.substring(0, 200)
        : response.body;
    debugPrint('❌ [AiService] proxy error ${response.statusCode}: $errBody');

    if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded');
    } else if (response.statusCode == 504) {
      throw Exception('AI service timeout');
    } else {
      throw Exception('Proxy error: ${response.statusCode}');
    }
  }

  /// Build system prompt for a user role
  String _buildRoleSystemPrompt(String role, String languageCode) {
    final Map<String, String> roleDescriptions = {
      'student': 'You are an AI assistant helping a student manage academic responsibilities.',
      'corporateEmployee': 'You are an AI assistant helping a corporate employee manage work responsibilities.',
      'educator': 'You are an AI assistant helping an educator manage teaching responsibilities.',
    };

    final description = roleDescriptions[role] ?? roleDescriptions['student']!;
    final language = languageCode == 'th' ? 'Thai' : 'English';

    return '$description Respond in $language. Be concise and practical.';
  }

  /// Generate task outline from existing task data
  /// Phase 1: Uses pure template-based recommendations (no AI)
  Future<AiServiceResponse> generateTaskOutline({
    required UserModel user,
    required String taskTitle,
    required String taskDescription,
  }) async {
    try {
      // Use fallback template based on user role
      final steps = _fallbackTaskOutlines[user.role] ?? _fallbackTaskOutlines['student']!;

      debugPrint('✅ [AiService] Generated outline with ${steps.length} steps (offline)');

      return AiServiceResponse(
        status: true,
        message: 'Task outline generated successfully',
        data: steps,
      );
    } catch (e) {
      debugPrint('❌ [AiService] Outline generation failed: $e');
      return AiServiceResponse(
        status: false,
        message: 'Failed to generate task outline: $e',
      );
    }
  }

  /// Generate suggestions from existing task data
  /// Phase 2: Uses existing user task data, sends to AI via proxy
  Future<AiServiceResponse> generateTaskSuggestions({
    required UserModel user,
    required List<Map<String, dynamic>> existingTasks,
  }) async {
    try {
      debugPrint('🔍 [AiService] Generating suggestions from ${existingTasks.length} tasks');

      final String idToken = await _getIdToken() ?? '';
      if (idToken.isEmpty) {
        return const AiServiceResponse(
          status: false,
          message: 'Authentication required',
        );
      }

      // Build role-aware system prompt
      final String rolePrompt = _buildRoleSystemPrompt(
        user.role.name,
        user.languageCode,
      );

      // Build task-based suggestion prompt
      final StringBuffer promptBuffer = StringBuffer();
      promptBuffer.writeln('ANALYZE USER TASKS AND SUGGEST IMPROVEMENTS');
      promptBuffer.writeln('');
      promptBuffer.writeln('EXISTING TASKS:');
      for (final task in existingTasks) {
        promptBuffer.writeln('- ${task['title']}: ${task['description']}');
        if (task['dueDate'] != null) {
          promptBuffer.writeln('  Due: ${task['dueDate']}');
        }
      }
      promptBuffer.writeln('');
      promptBuffer.writeln('Suggest 2-3 actionable improvements or additions.');

      final suggestionPrompt = promptBuffer.toString();

      // Call Groq via proxy
      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {'role': 'system', 'content': rolePrompt},
          {'role': 'user', 'content': suggestionPrompt},
        ],
        maxTokens: 500,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        debugPrint('⚠️ [AiService] Empty AI response');
        return const AiServiceResponse(
          status: false,
          message: 'Empty AI response',
        );
      }

      debugPrint('✅ [AiService] Generated suggestions (${content.length} chars)');

      return AiServiceResponse(
        status: true,
        message: 'Suggestions generated successfully',
        data: content,
      );
    } catch (e) {
      debugPrint('❌ [AiService] Suggestion generation failed: $e');
      return AiServiceResponse(
        status: false,
        message: 'Failed to generate suggestions: $e',
      );
    }
  }

  /// Generate context-aware analysis and discover new tasks
  /// Phase 3: Uses Firestore + Calendar context, sends to AI via proxy
  Future<AiServiceResponse> generateContextAwareAnalysis({
    required ContextSnapshot context,
  }) async {
    try {
      debugPrint('🔍 [AI Discovery] Starting context-aware analysis');
      debugPrint('   Tasks: ${context.tasks.length}');
      debugPrint('   Events: ${context.calendarEvents.length}');
      debugPrint('   Role: ${context.userRole}');

      final String? idToken = await _getIdToken();
      if (idToken == null || idToken.isEmpty) {
        debugPrint('❌ [AI Discovery] Authentication required');
        return const AiServiceResponse(
          status: false,
          message: 'Authentication required',
        );
      }

      // Build role-aware system prompt
      final String rolePrompt = _buildRoleSystemPrompt(
        context.userRole.name,
        context.languageCode,
      );

      // Build discovery prompt
      final String discoveryPrompt = _buildDiscoveryPrompt(context);

      debugPrint('🤖 [AI Discovery] Sending request to Groq proxy...');

      // Call Groq via Supabase proxy
      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
          'apikey': AppConfig.supabasePublishableKey,
        },
        body: jsonEncode({
          'operation': 'chat',
          'messages': [
            {'role': 'system', 'content': rolePrompt},
            {'role': 'user', 'content': discoveryPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 4000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('❌ [AI Discovery] HTTP ${response.statusCode}: ${response.body}');
        return AiServiceResponse(
          status: false,
          message: 'AI request failed: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract content from proxy response format: {ok: true, data: {choices: [...]}}
      final Map<String, dynamic>? data = responseData['data'] as Map<String, dynamic>?;
      final String? content = data?['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        debugPrint('⚠️ [AI Discovery] Empty AI response');
        return const AiServiceResponse(
          status: false,
          message: 'Empty AI response',
        );
      }

      debugPrint('✅ [AI Discovery] Received AI response (${content.length} chars)');

      // Parse AI response as JSON with robust extraction
      final ParseResult parseResult = parseDiscoveryResponse(content);

      if (!parseResult.success) {
        debugPrint('❌ [AI Discovery] Parse failed: ${parseResult.error}');
        return AiServiceResponse(
          status: false,
          message: parseResult.error ?? 'Failed to parse AI response',
        );
      }

      final AnalysisResult analysisResult = parseResult.result!;

      debugPrint('✅ [AI Discovery] Analysis complete:');
      debugPrint('   Proposals: ${analysisResult.proposals.length}');
      debugPrint('   Issues: ${analysisResult.identifiedIssues.length}');
      debugPrint('   Clarification needed: ${analysisResult.requiresClarification}');

      return AiServiceResponse(
        status: true,
        message: 'Analysis complete',
        data: analysisResult,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AI Discovery] Error: $e');
      debugPrint('   Stack trace: $stackTrace');
      return AiServiceResponse(
        status: false,
        message: 'Discovery failed: $e',
      );
    }
  }

  /// Build discovery prompt from context snapshot
  /// Phase 3: Instructs AI to discover new tasks from actual user data
  String _buildDiscoveryPrompt(ContextSnapshot context) {
    final buffer = StringBuffer();

    buffer.writeln('ANALYZE THE USER\'S CURRENT SITUATION AND DISCOVER RELEVANT TASKS');
    buffer.writeln('');
    buffer.writeln('USER CONTEXT:');
    buffer.writeln(context.toContextSummary());
    buffer.writeln('');
    buffer.writeln('YOUR TASK:');
    buffer.writeln('1. Analyze the retrieved context');
    buffer.writeln('2. Identify incomplete responsibilities');
    buffer.writeln('3. Detect upcoming events and deadlines');
    buffer.writeln('4. Identify possible conflicts and time constraints');
    buffer.writeln('5. Discover responsibilities that may require preparation');
    buffer.writeln('6. Generate original, context-specific task proposals');
    buffer.writeln('');
    buffer.writeln('RULES:');
    buffer.writeln('- Base proposals ONLY on actual retrieved data');
    buffer.writeln('- Do NOT generate generic topics unrelated to context');
    buffer.writeln('- Do NOT duplicate existing tasks');
    buffer.writeln('- Do NOT treat Calendar Events as existing tasks');
    buffer.writeln('- Do NOT invent deadlines or claim events exist when they do not');
    buffer.writeln('- Explain uncertainty rather than presenting assumptions as facts');
    buffer.writeln('- Support situations where NO recommendation is necessary');
    buffer.writeln('');
    buffer.writeln('RESPOND IN JSON FORMAT:');
    buffer.writeln('{');
    buffer.writeln('  "analysis": {');
    buffer.writeln('    "summary": "Summary of current situation",');
    buffer.writeln('    "identified_issues": ["issue1", "issue2"],');
    buffer.writeln('    "priorities": ["priority1", "priority2"]');
    buffer.writeln('  },');
    buffer.writeln('  "proposals": [');
    buffer.writeln('    {');
    buffer.writeln('      "id": "proposal_001",');
    buffer.writeln('      "title": "Task title",');
    buffer.writeln('      "description": "Task description",');
    buffer.writeln('      "reason": "Why this is relevant",');
    buffer.writeln('      "priority": "high|medium|low",');
    buffer.writeln('      "subtasks": ["subtask1", "subtask2"],');
    buffer.writeln('      "related_task_ids": [],');
    buffer.writeln('      "related_event_ids": [],');
    buffer.writeln('      "evidence": ["evidence from context"],');
    buffer.writeln('      "assumptions": ["any assumptions made"],');
    buffer.writeln('      "suggested_timing": "when to do this"');
    buffer.writeln('    }');
    buffer.writeln('  ],');
    buffer.writeln('  "requires_clarification": false,');
    buffer.writeln('  "clarification_questions": []');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Simple chat interface — wraps generateTaskSuggestions for backward compatibility
  /// Used by: ai_controller.dart, groq_api_test.dart
  Future<String> chat({
    required String message,
    required UserRole role,
  }) async {
    try {
      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {
            'role': 'system',
            'content': _buildRoleSystemPrompt(role.name, 'th'),
          },
          {'role': 'user', 'content': message},
        ],
        maxTokens: 500,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;
      return content ?? 'ไม่สามารถสร้างคำตอบได้';
    } catch (e) {
      debugPrint('❌ [AiService] Chat failed: $e');
      return 'เกิดข้อผิดพลาด: $e';
    }
  }

  /// Generate event preparation outline (role-based)
  /// Used by: ai_controller.dart
  Future<String> generateEventPreparation({
    required CalendarEventModel event,
    required UserRole role,
  }) async {
    try {
      final prompt = '''
Prepare for this event: ${event.title}
${event.description?.isNotEmpty == true ? 'Details: ${event.description}' : ''}
Date: ${event.startTime.toString().split(' ')[0]}

Generate 3-5 preparation steps in Thai.''';

      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {
            'role': 'system',
            'content': _buildRoleSystemPrompt(role.name, 'th'),
          },
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 400,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;
      return content ?? 'ไม่สามารถสร้างคำแนะนำได้';
    } catch (e) {
      debugPrint('❌ [AiService] Event preparation failed: $e');
      return 'เกิดข้อผิดพลาด: $e';
    }
  }

  /// Generate event preparation as JSON (structured response)
  /// Used by: task_plan_file_controller.dart
  Future<Map<String, dynamic>> generateEventPreparationJson({
    required CalendarEventModel event,
    required UserRole role,
  }) async {
    try {
      final prompt = '''
Analyze this event and generate preparation tasks in JSON format:

Event: ${event.title}
${event.description?.isNotEmpty == true ? 'Description: ${event.description}' : ''}
Date: ${event.startTime.toString().split(' ')[0]}

Respond with JSON:
{
  "summary": "Brief summary in Thai",
  "action_items": ["action 1", "action 2", "action 3"],
  "priority": "high|medium|low"
}''';

      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {
            'role': 'system',
            'content': _buildRoleSystemPrompt(role.name, 'th'),
          },
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 600,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        return _fallbackEventPreparation(event, role);
      }

      // Try to parse JSON from response
      try {
        final jsonText = extractJsonFromResponse(content);
        final parsed = jsonDecode(jsonText) as Map<String, dynamic>;
        return parsed;
      } catch (e) {
        debugPrint('⚠️ [AiService] JSON parse failed, using fallback: $e');
        return _fallbackEventPreparation(event, role);
      }
    } catch (e) {
      debugPrint('❌ [AiService] Event preparation JSON failed: $e');
      return _fallbackEventPreparation(event, role);
    }
  }

  /// Generate proactive task preparation as JSON
  /// Used by: proactive_controller.dart, groq_api_test.dart
  Future<Map<String, dynamic>> generateProactiveTaskPreparationJson({
    required CalendarEventModel event,
    required UserRole role,
  }) async {
    try {
      final prompt = '''
Generate proactive preparation tasks for this upcoming event in JSON format:

Event: ${event.title}
${event.description?.isNotEmpty == true ? 'Description: ${event.description}' : ''}
Date: ${event.startTime.toString().split(' ')[0]}
Time: ${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}

Respond with JSON:
{
  "summary": "Brief summary in Thai",
  "action_items": ["specific action 1", "specific action 2", "specific action 3"],
  "notification": "Reminder message in Thai",
  "priority": "high|medium|low"
}''';

      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {
            'role': 'system',
            'content': _buildRoleSystemPrompt(role.name, 'th'),
          },
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 600,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        return _fallbackProactivePreparation(event, role);
      }

      try {
        final jsonText = extractJsonFromResponse(content);
        final parsed = jsonDecode(jsonText) as Map<String, dynamic>;
        return parsed;
      } catch (e) {
        debugPrint('⚠️ [AiService] JSON parse failed, using fallback: $e');
        return _fallbackProactivePreparation(event, role);
      }
    } catch (e) {
      debugPrint('❌ [AiService] Proactive preparation failed: $e');
      return _fallbackProactivePreparation(event, role);
    }
  }

  /// Generate short content (notifications, summaries)
  /// Used by: notification_service.dart
  Future<AiServiceResponse> generateContent({
    required String prompt,
    required UserRole role,
    int maxTokens = 150,
  }) async {
    try {
      final response = await _callProxy(
        operation: 'chat',
        messages: [
          {
            'role': 'system',
            'content': _buildRoleSystemPrompt(role.name, 'th'),
          },
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: maxTokens,
        temperature: 0.7,
      );

      final String? content = response['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        return const AiServiceResponse(
          status: false,
          message: 'Empty AI response',
        );
      }

      return AiServiceResponse(
        status: true,
        message: 'Content generated successfully',
        data: content,
      );
    } catch (e) {
      debugPrint('❌ [AiService] Content generation failed: $e');
      return AiServiceResponse(
        status: false,
        message: 'Failed to generate content: $e',
      );
    }
  }

  /// Fallback event preparation (when AI fails)
  Map<String, dynamic> _fallbackEventPreparation(
    CalendarEventModel event,
    UserRole role,
  ) {
    final steps = _fallbackTaskOutlines[role.name] ?? _fallbackTaskOutlines['student']!;
    return {
      'summary': 'เตรียมตัวสำหรับ: ${event.title}',
      'action_items': steps.take(3).toList(),
      'priority': 'medium',
      '_fallback': true,
    };
  }

  /// Fallback proactive preparation (when AI fails)
  Map<String, dynamic> _fallbackProactivePreparation(
    CalendarEventModel event,
    UserRole role,
  ) {
    final steps = _fallbackTaskOutlines[role.name] ?? _fallbackTaskOutlines['student']!;
    return {
      'summary': 'เตรียมตัวสำหรับ: ${event.title}',
      'action_items': steps.take(4).toList(),
      'notification': 'อย่าลืมเตรียมตัวสำหรับ ${event.title}',
      'priority': 'medium',
      '_fallback': true,
    };
  }

  /// Sanitize chat response (backward compatibility)
  /// Used by: groq_api_test.dart
  @visibleForTesting
  String sanitizeChatResponse(String response) {
    // Remove common AI response prefixes/suffixes
    String sanitized = response.trim();

    // Remove markdown code fences if present
    final fencePattern = RegExp(r'```(?:text|markdown)?\s*\n?([\s\S]*?)\n?```');
    final fenceMatch = fencePattern.firstMatch(sanitized);
    if (fenceMatch != null) {
      sanitized = fenceMatch.group(1)?.trim() ?? sanitized;
    }

    // Remove common prefixes
    final prefixes = [
      'คำตอบ:',
      'ตอบ:',
      'Answer:',
      'Response:',
    ];

    for (final prefix in prefixes) {
      if (sanitized.startsWith(prefix)) {
        sanitized = sanitized.substring(prefix.length).trim();
      }
    }

    return sanitized;
  }

  /// Extract JSON from AI response with markdown fence handling
  /// Supports: plain JSON, ```json fences, ``` fences, surrounded text
  @visibleForTesting
  String extractJsonFromResponse(String content) {
    String text = content.trim();

    // Strategy 1: Look for ```json or ``` fenced blocks
    final RegExp jsonFencePattern = RegExp(
      r'```(?:json)?\s*\n?([\s\S]*?)\n?```',
      multiLine: true,
    );

    final Match? fenceMatch = jsonFencePattern.firstMatch(text);
    if (fenceMatch != null && fenceMatch.groupCount >= 1) {
      final String extracted = fenceMatch.group(1)?.trim() ?? '';
      if (extracted.isNotEmpty) {
        debugPrint('📦 [JSON Extract] Found fenced JSON (${extracted.length} chars)');
        return extracted;
      }
    }

    // Strategy 2: Find first '{' and last '}' for embedded JSON
    final int firstBrace = text.indexOf('{');
    final int lastBrace = text.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      final String extracted = text.substring(firstBrace, lastBrace + 1);
      debugPrint('📦 [JSON Extract] Found embedded JSON (${extracted.length} chars)');
      return extracted;
    }

    // Strategy 3: Return trimmed text as-is (already plain JSON)
    debugPrint('📦 [JSON Extract] Using plain text (${text.length} chars)');
    return text;
  }

  /// Parse AI discovery response with robust JSON extraction and validation
  @visibleForTesting
  ParseResult parseDiscoveryResponse(String content) {
    try {
      // Phase A: Extract JSON from response
      final String jsonText = extractJsonFromResponse(content);

      if (jsonText.isEmpty) {
        return const ParseResult.failure('Empty response after extraction');
      }

      // Parse JSON
      final dynamic parsed = jsonDecode(jsonText);

      if (parsed is! Map<String, dynamic>) {
        return const ParseResult.failure('Response is not a JSON object');
      }

      final Map<String, dynamic> json = parsed;

      // Phase B: Validate response structure
      final ValidationResult validation = validateDiscoveryResponse(json);

      if (!validation.isValid) {
        return ParseResult.failure('Invalid response schema: ${validation.errors.join(', ')}');
      }

      // Parse into AnalysisResult model
      final AnalysisResult result = AnalysisResult.fromJson(json);

      return ParseResult.success(result);
    } on FormatException catch (e) {
      debugPrint('⚠️ [AI Discovery] JSON parse error: $e');
      debugPrint('   Raw content (first 500 chars): ${content.substring(0, content.length > 500 ? 500 : content.length)}');
      return ParseResult.failure('Invalid JSON format: ${e.message}');
    } catch (e) {
      debugPrint('⚠️ [AI Discovery] Parse error: $e');
      return ParseResult.failure('Parse error: $e');
    }
  }

  /// Validate discovery response schema
  /// Phase B: Check required fields and structure
  @visibleForTesting
  ValidationResult validateDiscoveryResponse(Map<String, dynamic> json) {
    final List<String> errors = [];

    // Validate analysis object
    if (!json.containsKey('analysis')) {
      errors.add('Missing "analysis" object');
    } else {
      final dynamic analysis = json['analysis'];
      if (analysis is! Map<String, dynamic>) {
        errors.add('"analysis" must be an object');
      } else {
        // Check analysis fields (summary is required, others are optional)
        if (!analysis.containsKey('summary') || analysis['summary'] is! String) {
          errors.add('analysis.summary must be a string');
        }

        // identified_issues and priorities are optional but must be arrays if present
        if (analysis.containsKey('identified_issues') && analysis['identified_issues'] is! List) {
          errors.add('analysis.identified_issues must be an array');
        }
        if (analysis.containsKey('priorities') && analysis['priorities'] is! List) {
          errors.add('analysis.priorities must be an array');
        }
      }
    }

    // Validate proposals array (optional, can be empty)
    if (!json.containsKey('proposals')) {
      // proposals is optional; missing means no proposals
    } else {
      final dynamic proposals = json['proposals'];
      if (proposals is! List) {
        errors.add('"proposals" must be an array');
      } else {
        // Validate each proposal
        for (int i = 0; i < proposals.length; i++) {
          final dynamic proposal = proposals[i];
          if (proposal is! Map<String, dynamic>) {
            errors.add('proposals[$i] must be an object');
            continue;
          }

          // Required fields
          if (!proposal.containsKey('title') || proposal['title'] is! String) {
            errors.add('proposals[$i].title is required and must be a string');
          }
          if (!proposal.containsKey('description') || proposal['description'] is! String) {
            errors.add('proposals[$i].description is required and must be a string');
          }
          if (!proposal.containsKey('reason') || proposal['reason'] is! String) {
            errors.add('proposals[$i].reason is required and must be a string');
          }
          if (!proposal.containsKey('priority') || proposal['priority'] is! String) {
            errors.add('proposals[$i].priority is required and must be a string');
          }

          // Optional array fields (must be arrays if present)
          if (proposal.containsKey('subtasks') && proposal['subtasks'] is! List) {
            errors.add('proposals[$i].subtasks must be an array');
          }
          if (proposal.containsKey('evidence') && proposal['evidence'] is! List) {
            errors.add('proposals[$i].evidence must be an array');
          }
          if (proposal.containsKey('related_task_ids') && proposal['related_task_ids'] is! List) {
            errors.add('proposals[$i].related_task_ids must be an array');
          }
          if (proposal.containsKey('related_event_ids') && proposal['related_event_ids'] is! List) {
            errors.add('proposals[$i].related_event_ids must be an array');
          }
          if (proposal.containsKey('assumptions') && proposal['assumptions'] is! List) {
            errors.add('proposals[$i].assumptions must be an array');
          }
        }
      }
    }

    // requires_clarification is optional (defaults to false)
    if (json.containsKey('requires_clarification') && json['requires_clarification'] is! bool) {
      errors.add('"requires_clarification" must be a boolean');
    }

    // clarification_questions is optional but must be array if present
    if (json.containsKey('clarification_questions') && json['clarification_questions'] is! List) {
      errors.add('"clarification_questions" must be an array');
    }

    if (errors.isEmpty) {
      return const ValidationResult.valid();
    } else {
      return ValidationResult.invalid(errors);
    }
  }
}
