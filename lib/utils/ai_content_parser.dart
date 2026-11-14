/// lib/utils/ai_content_parser.dart
/// Parses AI-generated preparation content into structured sections
/// Handles malformed responses gracefully with fallback behavior

import '../models/prepared_plan_model.dart';

class AiContentParser {
  /// Parse AI content string into structured preparation components
  ///
  /// Expected format:
  /// ```
  /// วัตถุประสงค์: <objective text>
  ///
  /// ขั้นตอนเตรียมงาน:
  /// 1. <step 1>
  /// 2. <step 2>
  /// ...
  ///
  /// ทรัพยากร: <resource1>, <resource2>, ...
  ///
  /// ไทม์ไลน์: <timeline text>
  /// ```
  ///
  /// Falls back gracefully:
  /// - Missing sections get default values
  /// - Malformed steps become single-step plan with full content
  /// - Empty content becomes placeholder step
  static Map<String, dynamic> parse(String aiContent) {
    if (aiContent.trim().isEmpty) {
      return _createFallbackPlan('เตรียมความพร้อมสำหรับงาน');
    }

    // Remove offline template warning if present
    final cleanContent = aiContent
        .replaceFirst(RegExp(r'^⚠️\s*\[Offline Template\]\s*\n+'), '')
        .trim();

    final lines = cleanContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String objective = '';
    List<PreparationStep> steps = [];
    List<String> resources = [];
    String timeline = '';

    String currentSection = '';
    int stepOrder = 1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Section headers
      if (line.startsWith('วัตถุประสงค์:')) {
        currentSection = 'objective';
        final objectiveText = line.replaceFirst('วัตถุประสงค์:', '').trim();
        if (objectiveText.isNotEmpty) {
          objective = objectiveText;
        }
        continue;
      }

      if (line.contains('ขั้นตอนเตรียมงาน') || line.contains('การเตรียมงาน')) {
        currentSection = 'steps';
        continue;
      }

      if (line.startsWith('ทรัพยากร:')) {
        currentSection = 'resources';
        final resourceText = line.replaceFirst('ทรัพยากร:', '').trim();
        if (resourceText.isNotEmpty) {
          resources = resourceText
              .split(',')
              .map((r) => r.trim())
              .where((r) => r.isNotEmpty)
              .toList();
        }
        continue;
      }

      if (line.startsWith('ไทม์ไลน์:')) {
        currentSection = 'timeline';
        final timelineText = line.replaceFirst('ไทม์ไลน์:', '').trim();
        if (timelineText.isNotEmpty) {
          timeline = timelineText;
        }
        continue;
      }

      // Content parsing
      if (currentSection == 'objective' && objective.isEmpty) {
        objective = line;
      } else if (currentSection == 'steps') {
        // Match numbered steps: "1. ", "2.", "1)", etc.
        final numberMatch = RegExp(r'^(\d+)[.)\s]+').firstMatch(line);
        if (numberMatch != null) {
          final stepText = line.substring(numberMatch.end).trim();
          if (stepText.isNotEmpty) {
            steps.add(PreparationStep(
              id: 'step_$stepOrder',
              order: stepOrder,
              text: stepText,
              isCompleted: false,
              completedAt: null,
            ));
            stepOrder++;
          }
        } else if (line.startsWith('-') || line.startsWith('•')) {
          // Bullet list format
          final stepText = line.substring(1).trim();
          if (stepText.isNotEmpty) {
            steps.add(PreparationStep(
              id: 'step_$stepOrder',
              order: stepOrder,
              text: stepText,
              isCompleted: false,
              completedAt: null,
            ));
            stepOrder++;
          }
        }
      } else if (currentSection == 'resources' && resources.isEmpty) {
        // Multi-line resources
        resources = line
            .split(',')
            .map((r) => r.trim())
            .where((r) => r.isNotEmpty)
            .toList();
      } else if (currentSection == 'timeline' && timeline.isEmpty) {
        timeline = line;
      }
    }

    // Fallback: if no structured steps found, treat entire content as steps
    if (steps.isEmpty) {
      // Try to extract any numbered/bulleted items from the content
      final allStepLines = lines.where((line) {
        return RegExp(r'^(\d+[.)\s]+|-|•)').hasMatch(line);
      }).toList();

      if (allStepLines.isNotEmpty) {
        stepOrder = 1;
        for (final line in allStepLines) {
          final cleanedStep = line
              .replaceFirst(RegExp(r'^(\d+[.)\s]+|-|•)\s*'), '')
              .trim();
          if (cleanedStep.isNotEmpty) {
            steps.add(PreparationStep(
              id: 'step_$stepOrder',
              order: stepOrder,
              text: cleanedStep,
              isCompleted: false,
              completedAt: null,
            ));
            stepOrder++;
          }
        }
      }
    }

    // Final fallback: create single step with cleaned content
    if (steps.isEmpty) {
      steps.add(PreparationStep(
        id: 'step_1',
        order: 1,
        text: cleanContent.length > 200
            ? '${cleanContent.substring(0, 197)}...'
            : cleanContent,
        isCompleted: false,
        completedAt: null,
      ));
    }

    // Default values for missing sections
    if (objective.isEmpty) {
      objective = 'เตรียมความพร้อมสำหรับงาน';
    }

    if (timeline.isEmpty) {
      timeline = 'ควรเตรียมล่วงหน้าก่อนงาน';
    }

    return {
      'objective': objective,
      'steps': steps,
      'resources': resources,
      'timeline': timeline,
    };
  }

  static Map<String, dynamic> _createFallbackPlan(String defaultText) {
    return {
      'objective': 'เตรียมความพร้อมสำหรับงาน',
      'steps': [
        PreparationStep(
          id: 'step_1',
          order: 1,
          text: defaultText,
          isCompleted: false,
          completedAt: null,
        ),
      ],
      'resources': <String>[],
      'timeline': 'ควรเตรียมล่วงหน้าก่อนงาน',
    };
  }
}
