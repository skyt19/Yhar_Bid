/// lib/services/ai_json_parser.dart
/// Robust JSON parsing for AI responses with repair and retry logic
/// Phase 1: Enhanced JSON extraction and validation

import 'dart:convert';
import 'package:flutter/foundation.dart';

/// JSON parsing result with success/failure state
class JsonParseResult {
  final bool success;
  final dynamic data;
  final String? error;
  final bool wasRepaired;

  const JsonParseResult.success(this.data, {this.wasRepaired = false})
      : success = true,
        error = null;

  const JsonParseResult.failure(this.error)
      : success = false,
        data = null,
        wasRepaired = false;
}

/// Robust JSON parser with multiple extraction and repair strategies
class AiJsonParser {
  static const int maxRepairAttempts = 2;

  /// Parse JSON with robust extraction and optional repair
  static JsonParseResult parse(String content, {bool allowRepair = true}) {
    if (content.trim().isEmpty) {
      return const JsonParseResult.failure('Empty content');
    }

    // Strategy 1: Extract from markdown code fences
    String extracted = _extractFromCodeFence(content);

    // Strategy 2: Extract from braces (embedded JSON)
    if (extracted == content) {
      extracted = _extractFromBraces(content);
    }

    // Strategy 3: Try parsing as-is
    try {
      final parsed = jsonDecode(extracted);
      debugPrint('✅ [JsonParser] Parsed successfully (${extracted.length} chars)');
      return JsonParseResult.success(parsed);
    } on FormatException catch (e) {
      debugPrint('⚠️ [JsonParser] Parse failed: ${e.message}');

      if (allowRepair) {
        // Strategy 4: Attempt repair
        return _attemptRepair(extracted, e);
      }

      return JsonParseResult.failure('Invalid JSON: ${e.message}');
    } catch (e) {
      return JsonParseResult.failure('Parse error: $e');
    }
  }

  /// Extract JSON from markdown code fences
  static String _extractFromCodeFence(String content) {
    final patterns = [
      RegExp(r'```json\s*\n?([\s\S]*?)\n?```', multiLine: true),
      RegExp(r'```\s*\n?([\s\S]*?)\n?```', multiLine: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        final extracted = match.group(1)?.trim() ?? '';
        if (extracted.isNotEmpty) {
          debugPrint('📦 [JsonParser] Extracted from code fence (${extracted.length} chars)');
          return extracted;
        }
      }
    }

    return content.trim();
  }

  /// Extract JSON from first { to last }
  static String _extractFromBraces(String content) {
    final firstBrace = content.indexOf('{');
    final lastBrace = content.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      final extracted = content.substring(firstBrace, lastBrace + 1);
      debugPrint('📦 [JsonParser] Extracted from braces (${extracted.length} chars)');
      return extracted;
    }

    return content;
  }

  /// Attempt to repair malformed JSON
  static JsonParseResult _attemptRepair(String json, FormatException error) {
    debugPrint('🔧 [JsonParser] Attempting repair...');

    for (int attempt = 1; attempt <= maxRepairAttempts; attempt++) {
      final repaired = _applyRepairStrategy(json, attempt);

      if (repaired == json) {
        continue; // No change, try next strategy
      }

      try {
        final parsed = jsonDecode(repaired);
        debugPrint('✅ [JsonParser] Repaired successfully (attempt $attempt)');
        return JsonParseResult.success(parsed, wasRepaired: true);
      } catch (e) {
        debugPrint('⚠️ [JsonParser] Repair attempt $attempt failed');
        continue;
      }
    }

    return JsonParseResult.failure('Repair failed after $maxRepairAttempts attempts: ${error.message}');
  }

  /// Apply repair strategy based on attempt number
  static String _applyRepairStrategy(String json, int attempt) {
    switch (attempt) {
      case 1:
        // Strategy 1: Fix truncated arrays/objects
        return _fixTruncation(json);
      case 2:
        // Strategy 2: Fix common escape issues
        return _fixEscaping(json);
      default:
        return json;
    }
  }

  /// Fix truncated JSON (missing closing brackets)
  static String _fixTruncation(String json) {
    final trimmed = json.trim();

    // Count opening and closing braces/brackets
    int openBraces = '{'.allMatches(trimmed).length;
    int closeBraces = '}'.allMatches(trimmed).length;
    int openBrackets = '['.allMatches(trimmed).length;
    int closeBrackets = ']'.allMatches(trimmed).length;

    final buffer = StringBuffer(trimmed);

    // Add missing closing brackets
    while (openBrackets > closeBrackets) {
      buffer.write(']');
      closeBrackets++;
    }

    // Add missing closing braces
    while (openBraces > closeBraces) {
      buffer.write('}');
      closeBraces++;
    }

    final repaired = buffer.toString();
    if (repaired != json) {
      debugPrint('🔧 [JsonParser] Fixed truncation (added ${repaired.length - json.length} chars)');
    }

    return repaired;
  }

  /// Fix common escaping issues
  static String _fixEscaping(String json) {
    // Fix unescaped quotes in string values (basic heuristic)
    // This is conservative to avoid breaking valid JSON
    String repaired = json;

    // Remove control characters that break JSON
    repaired = repaired.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F]'), '');

    // Normalize line breaks
    repaired = repaired.replaceAll('\r\n', '\n');
    repaired = repaired.replaceAll('\r', '\n');

    if (repaired != json) {
      debugPrint('🔧 [JsonParser] Fixed escaping issues');
    }

    return repaired;
  }

  /// Validate parsed JSON structure against expected schema
  static bool validateStructure(dynamic parsed, Map<String, dynamic> schema) {
    if (parsed is! Map<String, dynamic>) {
      return false;
    }

    for (final key in schema.keys) {
      final expectedType = schema[key];

      if (!parsed.containsKey(key)) {
        if (expectedType.toString().endsWith('?')) {
          continue; // Optional field
        }
        return false; // Required field missing
      }

      final value = parsed[key];

      // Type checking (basic)
      if (expectedType == String && value is! String) return false;
      if (expectedType == int && value is! int) return false;
      if (expectedType == bool && value is! bool) return false;
      if (expectedType == List && value is! List) return false;
      if (expectedType == Map && value is! Map) return false;
    }

    return true;
  }

  /// Extract safe diagnostic information from parse error
  static String getDiagnostic(String content, FormatException error) {
    final position = error.offset ?? 0;
    final start = (position - 50).clamp(0, content.length);
    final end = (position + 50).clamp(0, content.length);
    final snippet = content.substring(start, end);

    return '''
Parse Error at position $position:
${error.message}

Context:
...${snippet.replaceAll('\n', '\\n')}...

Total length: ${content.length} chars
''';
  }
}
