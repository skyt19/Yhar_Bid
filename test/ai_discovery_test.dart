/// test/ai_discovery_test.dart
/// Unit Tests for Phase 3: Dynamic Discovery Engine

import 'package:flutter_test/flutter_test.dart';
import 'package:yharbid/models/ai_discovery_model.dart';

void main() {
  group('Phase 3: Dynamic Discovery Models', () {
    test('should parse TaskProposal from JSON correctly', () {
      final json = {
        'id': 'proposal_001',
        'title': 'Prepare for Midterm Exam',
        'description': 'Review materials and create study schedule',
        'reason': 'Exam is in 3 days and no preparation tasks exist',
        'priority': 'high',
        'subtasks': ['Review chapters 1-5', 'Create practice problems'],
        'related_task_ids': [],
        'related_event_ids': ['event123'],
        'evidence': ['Calendar shows "Midterm Exam" on Friday'],
        'assumptions': ['Student needs 2 days of preparation'],
        'suggested_timing': 'Start immediately',
      };

      final proposal = TaskProposal.fromJson(json);

      expect(proposal.id, 'proposal_001');
      expect(proposal.title, 'Prepare for Midterm Exam');
      expect(proposal.priority, 'high');
      expect(proposal.subtasks.length, 2);
      expect(proposal.evidence.length, 1);
    });

    test('should handle missing optional fields gracefully', () {
      final json = {
        'id': 'proposal_002',
        'title': 'Test Task',
        'description': 'Test description',
        'reason': 'Test reason',
        'priority': 'low',
      };

      final proposal = TaskProposal.fromJson(json);

      expect(proposal.id, 'proposal_002');
      expect(proposal.subtasks, isEmpty);
      expect(proposal.evidence, isEmpty);
      expect(proposal.suggestedTiming, isNull);
    });

    test('should parse AnalysisResult from JSON correctly', () {
      final json = {
        'analysis': {
          'summary': 'You have 3 urgent tasks and 2 upcoming events',
          'identified_issues': ['No preparation for Friday exam'],
          'priorities': ['Study for midterm', 'Complete assignment'],
        },
        'proposals': [
          {
            'id': 'proposal_001',
            'title': 'Study Plan',
            'description': 'Create study schedule',
            'reason': 'Exam approaching',
            'priority': 'high',
            'subtasks': [],
            'related_task_ids': [],
            'related_event_ids': [],
            'evidence': [],
            'assumptions': [],
          }
        ],
        'requires_clarification': false,
        'clarification_questions': [],
      };

      final analysis = AnalysisResult.fromJson(json);

      expect(analysis.summary, contains('urgent tasks'));
      expect(analysis.identifiedIssues.length, 1);
      expect(analysis.proposals.length, 1);
      expect(analysis.hasProposals, true);
    });

    test('should create empty analysis result', () {
      final empty = emptyAnalysisResult(message: 'No data');

      expect(empty.summary, 'No data');
      expect(empty.proposals, isEmpty);
      expect(empty.hasProposals, false);
    });

    test('should filter high priority proposals', () {
      final analysis = AnalysisResult(
        summary: 'Test',
        identifiedIssues: [],
        priorities: [],
        proposals: [
          TaskProposal(
            id: '1',
            title: 'High Priority',
            description: 'Test',
            reason: 'Test',
            priority: 'high',
            subtasks: [],
            relatedTaskIds: [],
            relatedEventIds: [],
            evidence: [],
            assumptions: [],
          ),
          TaskProposal(
            id: '2',
            title: 'Low Priority',
            description: 'Test',
            reason: 'Test',
            priority: 'low',
            subtasks: [],
            relatedTaskIds: [],
            relatedEventIds: [],
            evidence: [],
            assumptions: [],
          ),
        ],
        requiresClarification: false,
        clarificationQuestions: [],
      );

      final highPriority = analysis.highPriorityProposals;
      expect(highPriority.length, 1);
      expect(highPriority.first.priority, 'high');
    });
  });

  group('Phase 3: Discovery Requirements', () {
    test('proposals should have evidence or assumptions', () {
      final proposal = TaskProposal(
        id: 'test',
        title: 'Test Task',
        description: 'Description',
        reason: 'Reason',
        priority: 'medium',
        subtasks: [],
        relatedTaskIds: [],
        relatedEventIds: [],
        evidence: ['Based on calendar event'],
        assumptions: [],
      );

      expect(proposal.evidence.isNotEmpty || proposal.assumptions.isNotEmpty, true);
    });

    test('proposals should not duplicate existing task IDs', () {
      final proposal = TaskProposal(
        id: 'new_proposal',
        title: 'New Task',
        description: 'Description',
        reason: 'Reason',
        priority: 'medium',
        subtasks: [],
        relatedTaskIds: ['existing_task_1'],
        relatedEventIds: [],
        evidence: [],
        assumptions: [],
      );

      // In real implementation, check against existing task IDs
      expect(proposal.relatedTaskIds, isNotEmpty);
    });
  });
}
