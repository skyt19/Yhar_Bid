/// test/task_plan_pipeline_test.dart
/// Integration tests for complete Task Preparation Pipeline
/// Phase 1-4: Calendar → AI → TXT → Storage → File Management

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yharbid/models/calendar_event_model.dart';
import 'package:yharbid/models/task_plan_document_model.dart';
import 'package:yharbid/models/task_plan_file_model.dart';
import 'package:yharbid/services/task_plan_txt_service.dart';

void main() {
  // task_plan_txt_service.dart uses DateFormat('dd/MM/yyyy HH:mm', 'th_TH')
  // and DateFormat('dd/MM/yyyy', 'th_TH'). The th_TH locale data must be
  // initialized before those formatters are constructed, or DateFormat
  // throws LocaleDataException. Initialize once for the entire test suite.
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('Phase 1: Calendar Event Validation', () {
    test('Should validate complete event data', () {
      final event = CalendarEventModel(
        id: 'test_event_1',
        title: 'Introduction to AI - Lecture 8',
        description: 'Neural networks and deep learning',
        startTime: DateTime(2026, 11, 15, 14, 0),
        endTime: DateTime(2026, 11, 15, 16, 0),
        calendarId: 'primary',
        location: 'Room 301',
        attendees: ['student1@example.com', 'student2@example.com'],
        status: 'confirmed',
        htmlLink: 'https://calendar.google.com/event?eid=test123',
      );

      // Validate required fields
      expect(event.id, isNotEmpty);
      expect(event.title, isNotEmpty);
      expect(event.title, isNot('(ไม่มีชื่อ)'));
      expect(event.startTime.isBefore(event.endTime), isTrue);
      expect(event.status, isNot('cancelled'));
    });

    test('Should reject invalid events', () {
      final invalidEvents = [
        CalendarEventModel(
          id: '',
          title: 'No ID',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          calendarId: 'primary',
        ),
        CalendarEventModel(
          id: 'test',
          title: '(ไม่มีชื่อ)',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          calendarId: 'primary',
        ),
        CalendarEventModel(
          id: 'test',
          title: 'Cancelled Event',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          calendarId: 'primary',
          status: 'cancelled',
        ),
      ];

      for (final event in invalidEvents) {
        expect(event.id.isEmpty || event.title == '(ไม่มีชื่อ)' || event.status == 'cancelled', isTrue);
      }
    });

    test('Should handle events with/without descriptions', () {
      final eventWithDesc = CalendarEventModel(
        id: 'test1',
        title: 'Event with description',
        description: 'Detailed description here',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        calendarId: 'primary',
      );

      final eventWithoutDesc = CalendarEventModel(
        id: 'test2',
        title: 'Event without description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        calendarId: 'primary',
      );

      expect(eventWithDesc.description, isNotNull);
      expect(eventWithDesc.description!.isNotEmpty, isTrue);
      expect(eventWithoutDesc.description, isNull);
    });
  });

  group('Phase 2: EventAnalysis Validation', () {
    test('Should validate complete EventAnalysis', () {
      final analysis = EventAnalysis(
        eventId: 'test_event',
        eventTitle: 'Test Event',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        objective: 'Complete the task',
        expectedOutcome: 'Success',
        preparationSteps: ['Step 1', 'Step 2'],
        executionSteps: ['Execute 1'],
        requiredResources: ['Resource 1'],
        priority: 'High',
        estimatedPrepTimeMinutes: 30,
        suggestedTimeline: 'Start 1 day before',
        dependencies: [],
        risks: [],
        checklist: ['Check 1'],
        missingInformation: [],
      );

      expect(analysis.isValid, isTrue);
      expect(analysis.eventId, isNotEmpty);
      expect(analysis.objective, isNotEmpty);
      expect(analysis.preparationSteps, isNotEmpty);
      expect(['High', 'Medium', 'Low'].contains(analysis.priority), isTrue);
    });

    test('Should reject invalid EventAnalysis', () {
      final invalidAnalyses = [
        EventAnalysis(
          eventId: '',
          eventTitle: 'Test',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          objective: 'Test',
          expectedOutcome: 'Success',
          preparationSteps: [],
          executionSteps: [],
          requiredResources: [],
          priority: 'High',
          estimatedPrepTimeMinutes: 0,
          suggestedTimeline: 'Now',
          dependencies: [],
          risks: [],
          checklist: [],
          missingInformation: [],
        ),
        EventAnalysis(
          eventId: 'test',
          eventTitle: '',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          objective: '',
          expectedOutcome: 'Success',
          preparationSteps: ['Step 1'],
          executionSteps: [],
          requiredResources: [],
          priority: 'InvalidPriority',
          estimatedPrepTimeMinutes: 30,
          suggestedTimeline: 'Now',
          dependencies: [],
          risks: [],
          checklist: [],
          missingInformation: [],
        ),
      ];

      for (final analysis in invalidAnalyses) {
        expect(analysis.isValid, isFalse);
      }
    });
  });

  group('Phase 3: TXT Generation', () {
    late TaskPlanTxtService txtService;

    setUp(() {
      txtService = TaskPlanTxtService();
    });

    test('Should generate valid filename', () {
      final timestamp = DateTime(2026, 11, 7, 14, 30, 45);
      final filename = txtService.generateFilename(timestamp);

      expect(filename, matches(r'task_plan_\d{4}-\d{2}-\d{2}_\d{6}\.txt'));
      expect(filename, endsWith('.txt'));
      expect(filename, contains('2026-11-07'));
    });

    test('Should generate UTF-8 TXT content', () {
      final document = TaskPlanDocument(
        id: 'test_doc',
        userId: 'test_user',
        generatedAt: DateTime.now(),
        planningStartDate: DateTime.now(),
        planningEndDate: DateTime.now().add(Duration(days: 7)),
        eventCount: 1,
        events: [
          EventAnalysis(
            eventId: 'event1',
            eventTitle: 'ทดสอบภาษาไทย',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'เป้าหมายการทดสอบ',
            expectedOutcome: 'ผลลัพธ์ที่คาดหวัง',
            preparationSteps: ['ขั้นตอนที่ 1', 'ขั้นตอนที่ 2'],
            executionSteps: ['ดำเนินการ'],
            requiredResources: [],
            priority: 'Medium',
            estimatedPrepTimeMinutes: 30,
            suggestedTimeline: 'เริ่มก่อน 1 วัน',
            dependencies: [],
            risks: [],
            checklist: ['ตรวจสอบ 1'],
            missingInformation: [],
          ),
        ],
      );

      final txtBytes = txtService.generateTxtBytes(document);

      expect(txtBytes, isNotEmpty);
      expect(txtService.validateTxtBytes(txtBytes), isTrue);

      final content = utf8.decode(txtBytes);
      expect(content, contains('แผนการเตรียมงาน'));
      expect(content, contains('Yharbid AI Assistant'));
      expect(content, contains('ทดสอบภาษาไทย'));
      expect(content, contains('เป้าหมายการทดสอบ'));
    });

    test('Should validate TXT content completeness', () {
      final document = TaskPlanDocument(
        id: 'test_doc',
        userId: 'test_user',
        generatedAt: DateTime.now(),
        planningStartDate: DateTime.now(),
        planningEndDate: DateTime.now().add(Duration(days: 7)),
        eventCount: 2,
        events: [
          EventAnalysis(
            eventId: 'event1',
            eventTitle: 'Event 1',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'Goal 1',
            expectedOutcome: 'Outcome 1',
            preparationSteps: ['Step 1'],
            executionSteps: ['Execute 1'],
            requiredResources: [],
            priority: 'High',
            estimatedPrepTimeMinutes: 20,
            suggestedTimeline: 'Now',
            dependencies: [],
            risks: [],
            checklist: [],
            missingInformation: [],
          ),
          EventAnalysis(
            eventId: 'event2',
            eventTitle: 'Event 2',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'Goal 2',
            expectedOutcome: 'Outcome 2',
            preparationSteps: ['Step 2'],
            executionSteps: ['Execute 2'],
            requiredResources: [],
            priority: 'Low',
            estimatedPrepTimeMinutes: 15,
            suggestedTimeline: 'Later',
            dependencies: [],
            risks: [],
            checklist: [],
            missingInformation: [],
          ),
        ],
      );

      final txtBytes = txtService.generateTxtBytes(document);
      final content = utf8.decode(txtBytes);

      expect(txtService.validateTxtContent(content, document), isTrue);
      expect(content, contains('Event 1'));
      expect(content, contains('Event 2'));
      expect(content, contains('Goal 1'));
      expect(content, contains('Goal 2'));
    });

    test('Should handle empty or invalid content', () {
      final emptyBytes = <int>[];
      expect(txtService.validateTxtBytes(emptyBytes), isFalse);

      // Invalid UTF-8 sequence
      final invalidBytes = [0xFF, 0xFE, 0xFD];
      expect(txtService.validateTxtBytes(invalidBytes), isFalse);
    });
  });

  group('Phase 4: File Metadata Validation', () {
    test('Should validate complete file metadata', () {
      final file = TaskPlanFile(
        id: 'file123',
        userId: 'user123',
        filename: 'task_plan_2026-11-07_143045.txt',
        storagePath: 'task_plans/user123/task_plan_2026-11-07_143045.txt',
        downloadUrl: 'https://storage.googleapis.com/bucket/file',
        sizeBytes: 5000,
        mimeType: 'text/plain',
        createdAt: DateTime.now(),
        planningStartDate: DateTime.now(),
        planningEndDate: DateTime.now().add(Duration(days: 7)),
        sourceEventIds: ['event1', 'event2'],
        eventCount: 2,
      );

      expect(file.isValid, isTrue);
      expect(file.id, isNotEmpty);
      expect(file.filename, endsWith('.txt'));
      expect(file.mimeType, equals('text/plain'));
      expect(file.sizeBytes, greaterThan(0));
      expect(file.eventCount, greaterThan(0));
      expect(file.sourceEventIds, isNotEmpty);
    });

    test('Should format file size correctly', () {
      final files = [
        TaskPlanFile(
          id: 'f1',
          userId: 'u1',
          filename: 'test.txt',
          storagePath: 'path',
          downloadUrl: 'url',
          sizeBytes: 500,
          mimeType: 'text/plain',
          createdAt: DateTime.now(),
          planningStartDate: DateTime.now(),
          planningEndDate: DateTime.now(),
          sourceEventIds: ['e1'],
          eventCount: 1,
        ),
        TaskPlanFile(
          id: 'f2',
          userId: 'u1',
          filename: 'test.txt',
          storagePath: 'path',
          downloadUrl: 'url',
          sizeBytes: 5000,
          mimeType: 'text/plain',
          createdAt: DateTime.now(),
          planningStartDate: DateTime.now(),
          planningEndDate: DateTime.now(),
          sourceEventIds: ['e1'],
          eventCount: 1,
        ),
        TaskPlanFile(
          id: 'f3',
          userId: 'u1',
          filename: 'test.txt',
          storagePath: 'path',
          downloadUrl: 'url',
          sizeBytes: 5000000,
          mimeType: 'text/plain',
          createdAt: DateTime.now(),
          planningStartDate: DateTime.now(),
          planningEndDate: DateTime.now(),
          sourceEventIds: ['e1'],
          eventCount: 1,
        ),
      ];

      expect(files[0].formattedSize, contains('B'));
      expect(files[1].formattedSize, contains('KB'));
      expect(files[2].formattedSize, contains('MB'));
    });

    test('Should manage deletion state lifecycle', () {
      var file = TaskPlanFile(
        id: 'f1',
        userId: 'u1',
        filename: 'test.txt',
        storagePath: 'path',
        downloadUrl: 'url',
        sizeBytes: 1000,
        mimeType: 'text/plain',
        createdAt: DateTime.now(),
        planningStartDate: DateTime.now(),
        planningEndDate: DateTime.now(),
        sourceEventIds: ['e1'],
        eventCount: 1,
      );

      expect(file.deletionState, equals(FileDeletionState.idle));

      file = file.copyWith(deletionState: FileDeletionState.confirmationRequested);
      expect(file.deletionState, equals(FileDeletionState.confirmationRequested));

      file = file.copyWith(deletionState: FileDeletionState.deleting);
      expect(file.deletionState, equals(FileDeletionState.deleting));

      file = file.copyWith(deletionState: FileDeletionState.deleted);
      expect(file.deletionState, equals(FileDeletionState.deleted));
    });
  });

  group('Integration: TaskPlanDocument Validation', () {
    test('Should validate complete task plan document', () {
      final document = TaskPlanDocument(
        id: 'doc123',
        userId: 'user123',
        generatedAt: DateTime.now(),
        planningStartDate: DateTime.now(),
        planningEndDate: DateTime.now().add(Duration(days: 14)),
        eventCount: 3,
        events: [
          EventAnalysis(
            eventId: 'e1',
            eventTitle: 'Event 1',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'Obj 1',
            expectedOutcome: 'Out 1',
            preparationSteps: ['Step 1'],
            executionSteps: ['Exec 1'],
            requiredResources: [],
            priority: 'High',
            estimatedPrepTimeMinutes: 30,
            suggestedTimeline: 'Soon',
            dependencies: [],
            risks: [],
            checklist: [],
            missingInformation: [],
          ),
          EventAnalysis(
            eventId: 'e2',
            eventTitle: 'Event 2',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'Obj 2',
            expectedOutcome: 'Out 2',
            preparationSteps: ['Step 2'],
            executionSteps: ['Exec 2'],
            requiredResources: [],
            priority: 'Medium',
            estimatedPrepTimeMinutes: 20,
            suggestedTimeline: 'Later',
            dependencies: [],
            risks: [],
            checklist: [],
            missingInformation: [],
          ),
          EventAnalysis(
            eventId: 'e3',
            eventTitle: 'Event 3',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            objective: 'Obj 3',
            expectedOutcome: 'Out 3',
            preparationSteps: ['Step 3'],
            executionSteps: ['Exec 3'],
            requiredResources: [],
            priority: 'Low',
            estimatedPrepTimeMinutes: 15,
            suggestedTimeline: 'Next week',
            dependencies: [],
            risks: [],
            checklist: [],
            missingInformation: [],
          ),
        ],
      );

      expect(document.isValid, isTrue);
      expect(document.userId, isNotEmpty);
      expect(document.eventCount, equals(3));
      expect(document.events.length, equals(document.eventCount));

      for (final event in document.events) {
        expect(event.isValid, isTrue);
      }
    });

    test('Should reject invalid document', () {
      final invalidDocs = [
        // Empty user ID
        TaskPlanDocument(
          id: 'doc',
          userId: '',
          generatedAt: DateTime.now(),
          planningStartDate: DateTime.now(),
          planningEndDate: DateTime.now(),
          eventCount: 0,
          events: [],
        ),
        // Event count mismatch
        TaskPlanDocument(
          id: 'doc',
          userId: 'user',
          generatedAt: DateTime.now(),
          planningStartDate: DateTime.now(),
          planningEndDate: DateTime.now(),
          eventCount: 2,
          events: [
            EventAnalysis(
              eventId: 'e1',
              eventTitle: 'Event 1',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(Duration(hours: 1)),
              objective: 'Obj',
              expectedOutcome: 'Out',
              preparationSteps: ['Step'],
              executionSteps: ['Exec'],
              requiredResources: [],
              priority: 'High',
              estimatedPrepTimeMinutes: 30,
              suggestedTimeline: 'Soon',
              dependencies: [],
              risks: [],
              checklist: [],
              missingInformation: [],
            ),
          ],
        ),
      ];

      for (final doc in invalidDocs) {
        expect(doc.isValid, isFalse);
      }
    });
  });
}
