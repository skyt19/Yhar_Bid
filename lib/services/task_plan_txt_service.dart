/// lib/services/task_plan_txt_service.dart
/// Phase 3: TXT File Generation Service
/// Converts TaskPlanDocument to downloadable UTF-8 TXT file

import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/task_plan_document_model.dart';

class TaskPlanTxtService {
  static const String _encoding = 'UTF-8';

  /// Generate TXT content from TaskPlanDocument
  /// Returns UTF-8 encoded bytes
  List<int> generateTxtBytes(TaskPlanDocument document) {
    final content = _generateTxtContent(document);
    return utf8.encode(content);
  }

  /// Generate TXT content as string
  String _generateTxtContent(TaskPlanDocument document) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'th_TH');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy', 'th_TH');

    // Document Header
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('         แผนการเตรียมงาน (Task Preparation Plan)');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('สร้างโดย: Yharbid AI Assistant');
    buffer.writeln('วันที่สร้าง: ${dateFormat.format(document.generatedAt)}');
    buffer.writeln('ช่วงเวลาการวางแผน: ${dateOnlyFormat.format(document.planningStartDate)} - ${dateOnlyFormat.format(document.planningEndDate)}');
    buffer.writeln('แหล่งข้อมูล: Google Calendar');
    buffer.writeln('จำนวนกิจกรรม: ${document.eventCount} รายการ');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln();

    // Process each event
    for (int i = 0; i < document.events.length; i++) {
      final event = document.events[i];
      final eventNumber = i + 1;

      buffer.writeln();
      buffer.writeln('───────────────────────────────────────────────────────────');
      buffer.writeln('กิจกรรมที่ $eventNumber: ${event.eventTitle}');
      buffer.writeln('───────────────────────────────────────────────────────────');
      buffer.writeln();

      // Event Details
      buffer.writeln('📅 รายละเอียดกิจกรรม');
      buffer.writeln('   วันที่: ${dateFormat.format(event.startTime)} - ${dateFormat.format(event.endTime)}');

      if (event.location != null && event.location!.isNotEmpty) {
        buffer.writeln('   สถานที่: ${event.location}');
      }

      if (event.attendees != null && event.attendees!.isNotEmpty) {
        buffer.writeln('   ผู้เข้าร่วม: ${event.attendees!.length} คน');
      }

      if (event.eventDescription != null && event.eventDescription!.isNotEmpty) {
        buffer.writeln('   คำอธิบาย: ${event.eventDescription}');
      }

      if (event.isFallback) {
        buffer.writeln('   ⚠️ หมายเหตุ: ใช้เทมเพลตออฟไลน์');
      }

      buffer.writeln();

      // Objective
      buffer.writeln('🎯 วัตถุประสงค์');
      buffer.writeln('   ${event.objective}');
      buffer.writeln();

      // Expected Outcome
      buffer.writeln('✅ ผลลัพธ์ที่คาดหวัง');
      buffer.writeln('   ${event.expectedOutcome}');
      buffer.writeln();

      // Preparation Steps
      if (event.preparationSteps.isNotEmpty) {
        buffer.writeln('📝 ขั้นตอนการเตรียมตัว');
        for (int j = 0; j < event.preparationSteps.length; j++) {
          buffer.writeln('   ${j + 1}. ${event.preparationSteps[j]}');
        }
        buffer.writeln();
      }

      // Execution Steps
      if (event.executionSteps.isNotEmpty) {
        buffer.writeln('⚙️ ขั้นตอนการดำเนินงาน');
        for (int j = 0; j < event.executionSteps.length; j++) {
          buffer.writeln('   ${j + 1}. ${event.executionSteps[j]}');
        }
        buffer.writeln();
      }

      // Required Resources
      if (event.requiredResources.isNotEmpty) {
        buffer.writeln('📦 ทรัพยากรที่จำเป็น');
        for (final resource in event.requiredResources) {
          buffer.writeln('   • $resource');
        }
        buffer.writeln();
      }

      // Priority & Timeline
      buffer.writeln('⚡ ระดับความสำคัญ: ${event.priority}');
      buffer.writeln('⏱️ เวลาเตรียมตัว (โดยประมาณ): ${event.estimatedPrepTimeMinutes} นาที');
      buffer.writeln('📆 กำหนดการเตรียมตัว: ${event.suggestedTimeline}');
      buffer.writeln();

      // Dependencies
      if (event.dependencies.isNotEmpty) {
        buffer.writeln('🔗 งานที่ต้องทำก่อน');
        for (final dep in event.dependencies) {
          buffer.writeln('   • $dep');
        }
        buffer.writeln();
      }

      // Risks
      if (event.risks.isNotEmpty) {
        buffer.writeln('⚠️ ความเสี่ยงและข้อควรระวัง');
        for (final risk in event.risks) {
          buffer.writeln('   • $risk');
        }
        buffer.writeln();
      }

      // Checklist
      if (event.checklist.isNotEmpty) {
        buffer.writeln('☑️ รายการตรวจสอบ');
        for (final item in event.checklist) {
          buffer.writeln('   ☐ $item');
        }
        buffer.writeln();
      }

      // Missing Information
      if (event.missingInformation.isNotEmpty) {
        buffer.writeln('❓ ข้อมูลที่ยังขาด');
        for (final missing in event.missingInformation) {
          buffer.writeln('   • $missing');
        }
        buffer.writeln();
      }
    }

    // Footer
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('สิ้นสุดแผนการเตรียมงาน');
    buffer.writeln('═══════════════════════════════════════════════════════════');

    return buffer.toString();
  }

  /// Generate safe filename
  /// Format: task_plan_YYYY-MM-DD_HHmmss.txt
  String generateFilename(DateTime timestamp) {
    final dateFormat = DateFormat('yyyy-MM-dd_HHmmss');
    return 'task_plan_${dateFormat.format(timestamp)}.txt';
  }

  /// Validate generated TXT content
  bool validateTxtContent(String content, TaskPlanDocument document) {
    if (content.isEmpty) return false;
    if (!content.contains('แผนการเตรียมงาน')) return false;
    if (!content.contains('Yharbid AI Assistant')) return false;

    // Verify all events are represented
    for (final event in document.events) {
      if (!content.contains(event.eventTitle)) return false;
    }

    return true;
  }

  /// Validate TXT bytes (UTF-8 encoding)
  bool validateTxtBytes(List<int> bytes) {
    if (bytes.isEmpty) return false;

    try {
      // Attempt to decode as UTF-8
      final decoded = utf8.decode(bytes);
      if (decoded.isEmpty) return false;

      // Verify BOM is not present (pure UTF-8)
      if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
        return false; // BOM not allowed
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
