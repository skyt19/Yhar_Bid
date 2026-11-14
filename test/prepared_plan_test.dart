/// test/prepared_plan_test.dart
/// Unit tests for Preparation Plan feature
/// Tests parser, model, and controller logic

import 'package:flutter_test/flutter_test.dart';
import 'package:yharbid/models/prepared_plan_model.dart';
import 'package:yharbid/utils/ai_content_parser.dart';

void main() {
  group('AiContentParser', () {
    test('parses well-formed AI content with all sections', () {
      const content = '''
วัตถุประสงค์: เตรียมความพร้อมสำหรับการนำเสนอโครงการให้ทีมผู้บริหารอนุมัติ

ขั้นตอนเตรียมงาน:
1. วิเคราะห์เนื้อหาโครงการและจุดเด่น
2. เตรียมสไลด์นำเสนอพร้อมข้อมูลสนับสนุน
3. ทบทวนงบประมาณและไทม์ไลน์โครงการ
4. เตรียมเอกสารประกอบการนำเสนอ
5. ซ้อมนำเสนอและเตรียมคำตอบคำถาม

ทรัพยากร: Google Slides, โครงการ PDF, งบประมาณ Excel

ไทม์ไลน์: เริ่มเตรียม 2 วันก่อนงาน, ซ้อมนำเสนอในเช้าวันงาน
''';

      final result = AiContentParser.parse(content);

      expect(result['objective'], contains('เตรียมความพร้อม'));
      expect(result['steps'], hasLength(5));
      expect((result['steps'] as List)[0].id, equals('step_1'));
      expect((result['steps'] as List)[0].text, contains('วิเคราะห์'));
      expect(result['resources'], hasLength(3));
      expect((result['resources'] as List).first, contains('Google Slides'));
      expect(result['timeline'], contains('2 วันก่อนงาน'));
    });

    test('handles bullet-format steps', () {
      const content = '''
ขั้นตอนเตรียมงาน:
- วิเคราะห์เนื้อหา
- เตรียมสไลด์
- ซ้อมนำเสนอ
''';

      final result = AiContentParser.parse(content);
      final steps = result['steps'] as List<PreparationStep>;

      expect(steps, hasLength(3));
      expect(steps[0].id, equals('step_1'));
      expect(steps[0].text, equals('วิเคราะห์เนื้อหา'));
      expect(steps[1].order, equals(2));
    });

    test('handles empty content with fallback', () {
      const content = '';

      final result = AiContentParser.parse(content);
      final steps = result['steps'] as List<PreparationStep>;

      expect(steps, hasLength(1));
      expect(steps.first.id, equals('step_1'));
      expect(result['objective'], isNotEmpty);
      expect(result['timeline'], isNotEmpty);
    });

    test('handles offline template prefix', () {
      const content = '''
⚠️ [Offline Template]

วัตถุประสงค์: ทดสอบ

ขั้นตอนเตรียมงาน:
1. ขั้นตอนที่ 1
''';

      final result = AiContentParser.parse(content);

      expect(result['objective'], equals('ทดสอบ'));
      expect((result['steps'] as List), hasLength(1));
    });

    test('handles malformed content without sections', () {
      const content = 'เตรียมงานนำเสนอ ทำสไลด์ ซ้อม ตรวจเอกสาร';

      final result = AiContentParser.parse(content);
      final steps = result['steps'] as List<PreparationStep>;

      expect(steps, hasLength(1));
      expect(steps.first.text, contains('เตรียมงานนำเสนอ'));
    });

    test('stable step IDs across multiple parses', () {
      const content = '''
ขั้นตอนเตรียมงาน:
1. ขั้นตอนที่ 1
2. ขั้นตอนที่ 2
3. ขั้นตอนที่ 3
''';

      final result1 = AiContentParser.parse(content);
      final result2 = AiContentParser.parse(content);
      final steps1 = result1['steps'] as List<PreparationStep>;
      final steps2 = result2['steps'] as List<PreparationStep>;

      expect(steps1[0].id, equals(steps2[0].id));
      expect(steps1[1].id, equals(steps2[1].id));
      expect(steps1[2].id, equals(steps2[2].id));
    });
  });

  group('PreparationStep', () {
    test('copyWith preserves ID and order', () {
      final step = PreparationStep(
        id: 'step_1',
        order: 1,
        text: 'ทดสอบ',
        isCompleted: false,
        completedAt: null,
      );

      final updated = step.copyWith(isCompleted: true);

      expect(updated.id, equals('step_1'));
      expect(updated.order, equals(1));
      expect(updated.isCompleted, isTrue);
    });

    test('toMap and fromMap roundtrip', () {
      final original = PreparationStep(
        id: 'step_2',
        order: 2,
        text: 'เตรียมสไลด์',
        isCompleted: true,
        completedAt: DateTime(2026, 11, 13, 10, 30),
      );

      final map = original.toMap();
      final restored = PreparationStep.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.order, equals(original.order));
      expect(restored.text, equals(original.text));
      expect(restored.isCompleted, equals(original.isCompleted));
      expect(restored.completedAt, equals(original.completedAt));
    });
  });

  group('PreparedPlanModel', () {
    test('computes progress correctly', () {
      final plan = PreparedPlanModel(
        id: 'plan_1',
        userId: 'user_1',
        proposalId: 'prop_1',
        eventId: 'event_1',
        eventTitle: 'นำเสนอโครงการ',
        eventDateTime: DateTime(2026, 11, 20, 14, 0),
        eventLocation: 'ห้องประชุม A',
        objective: 'ทดสอบ',
        steps: [
          PreparationStep(id: 'step_1', order: 1, text: 'ขั้นตอน 1', isCompleted: true),
          PreparationStep(id: 'step_2', order: 2, text: 'ขั้นตอน 2', isCompleted: true),
          PreparationStep(id: 'step_3', order: 3, text: 'ขั้นตอน 3', isCompleted: false),
          PreparationStep(id: 'step_4', order: 4, text: 'ขั้นตอน 4', isCompleted: false),
        ],
        resources: [],
        timeline: 'ทดสอบ',
        rawAiContent: 'ทดสอบ',
        createdAt: DateTime.now(),
      );

      expect(plan.totalSteps, equals(4));
      expect(plan.completedStepCount, equals(2));
      expect(plan.progressPercentage, equals(0.5));
      expect(plan.progressPercent, equals(50));
      expect(plan.isCompleted, isFalse);
      expect(plan.isInProgress, isTrue);
    });

    test('detects completion correctly', () {
      final plan = PreparedPlanModel(
        id: 'plan_2',
        userId: 'user_1',
        proposalId: 'prop_2',
        eventId: 'event_2',
        eventTitle: 'ทดสอบ',
        eventDateTime: DateTime(2026, 11, 20, 14, 0),
        eventLocation: 'ทดสอบ',
        objective: 'ทดสอบ',
        steps: [
          PreparationStep(id: 'step_1', order: 1, text: 'ขั้นตอน 1', isCompleted: true),
          PreparationStep(id: 'step_2', order: 2, text: 'ขั้นตอน 2', isCompleted: true),
        ],
        resources: [],
        timeline: 'ทดสอบ',
        rawAiContent: 'ทดสอบ',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      expect(plan.isCompleted, isTrue);
      expect(plan.progressPercent, equals(100));
    });

    test('detects event passed', () {
      final pastEvent = PreparedPlanModel(
        id: 'plan_3',
        userId: 'user_1',
        proposalId: 'prop_3',
        eventId: 'event_3',
        eventTitle: 'ทดสอบ',
        eventDateTime: DateTime(2020, 1, 1),
        eventLocation: 'ทดสอบ',
        objective: 'ทดสอบ',
        steps: [],
        resources: [],
        timeline: 'ทดสอบ',
        rawAiContent: 'ทดสอบ',
        createdAt: DateTime.now(),
      );

      expect(pastEvent.hasEventPassed, isTrue);
    });
  });
}
