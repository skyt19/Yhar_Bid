/// test/context_retrieval_test.dart
/// Unit Tests for Phase 1: Context Retrieval Service

import 'package:flutter_test/flutter_test.dart';
import 'package:yharbid/models/context_snapshot_model.dart';
import 'package:yharbid/models/user_model.dart';
import 'package:yharbid/models/task_model.dart';

void main() {
  group('Phase 1: Context Snapshot Model', () {
    test('should correctly identify pending tasks', () {
      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: [],
        calendarEvents: [],
        retrievedAt: DateTime.now(),
      );

      expect(snapshot.hasData, false);
      expect(snapshot.pendingTasks, isEmpty);
    });

    test('should generate context summary correctly', () {
      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: [],
        calendarEvents: [],
        retrievedAt: DateTime.now(),
      );

      final summary = snapshot.toContextSummary();
      expect(summary, contains('USER CONTEXT SNAPSHOT'));
      expect(summary, contains('Role: student'));
    });

    test('should track pending and completed tasks separately', () {
      final now = DateTime.now();
      final tasks = [
        TaskModel(
          id: 'task1',
          title: 'Complete Assignment',
          description: 'Assignment details',
          isDone: false,
          priority: 'high',
          category: 'Academic',
          createdAt: now,
        ),
        TaskModel(
          id: 'task2',
          title: 'Submit Report',
          description: 'Report submission',
          isDone: true,
          priority: 'medium',
          category: 'Academic',
          createdAt: now,
        ),
      ];

      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: tasks,
        calendarEvents: [],
        retrievedAt: now,
      );

      expect(snapshot.pendingTasks.length, 1);
      expect(snapshot.completedTasks.length, 1);
      expect(snapshot.hasData, true);
    });

    test('should identify overdue tasks', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final tasks = [
        TaskModel(
          id: 'task1',
          title: 'Overdue Task',
          description: 'Task description',
          isDone: false,
          priority: 'high',
          category: 'Academic',
          createdAt: yesterday,
          dueDate: yesterday,
        ),
      ];

      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: tasks,
        calendarEvents: [],
        retrievedAt: now,
      );

      expect(snapshot.overdueTasks.length, 1);
    });
  });

  group('Phase 1: Context Retrieval Safety', () {
    test('should handle empty context gracefully', () {
      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: [],
        calendarEvents: [],
        retrievedAt: DateTime.now(),
      );

      expect(snapshot.hasData, false);
      expect(() => snapshot.toContextJson(), returnsNormally);
      expect(() => snapshot.toContextSummary(), returnsNormally);
    });

    test('should track retrieval errors without failing', () {
      final snapshot = ContextSnapshot(
        userId: 'test123',
        userRole: UserRole.student,
        personality: AiPersonality.politeJarvis,
        languageCode: 'th',
        tasks: [],
        calendarEvents: [],
        retrievedAt: DateTime.now(),
        isComplete: false,
        retrievalErrors: ['Failed to fetch calendar', 'Network timeout'],
      );

      expect(snapshot.isComplete, false);
      expect(snapshot.retrievalErrors.length, 2);
    });
  });
}
