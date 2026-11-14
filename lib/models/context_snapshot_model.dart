/// lib/models/context_snapshot_model.dart
/// Context Snapshot Model — Unified data context for AI reasoning
/// Phase 1: Context Retrieval Layer

import 'user_model.dart';
import 'task_model.dart';
import 'calendar_event_model.dart';

/// Represents a complete snapshot of user's current context
/// Used by AI to reason about user's situation before generating recommendations
class ContextSnapshot {
  final String userId;
  final UserRole userRole;
  final AiPersonality personality;
  final String languageCode;

  final List<TaskModel> tasks;
  final List<CalendarEventModel> calendarEvents;

  final DateTime retrievedAt;
  final bool isComplete;
  final List<String> retrievalErrors;

  const ContextSnapshot({
    required this.userId,
    required this.userRole,
    required this.personality,
    required this.languageCode,
    required this.tasks,
    required this.calendarEvents,
    required this.retrievedAt,
    this.isComplete = true,
    this.retrievalErrors = const [],
  });

  /// Check if context has any actionable data
  bool get hasData => tasks.isNotEmpty || calendarEvents.isNotEmpty;

  /// Get pending (incomplete) tasks
  List<TaskModel> get pendingTasks =>
      tasks.where((t) => !t.isDone).toList();

  /// Get completed tasks
  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.isDone).toList();

  /// Get high priority tasks
  List<TaskModel> get highPriorityTasks =>
      tasks.where((t) => t.priority.toLowerCase() == 'high').toList();

  /// Get tasks with deadlines
  List<TaskModel> get tasksWithDeadlines =>
      tasks.where((t) => t.dueDate != null).toList();

  /// Get overdue tasks
  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return tasks.where((t) =>
      !t.isDone &&
      t.dueDate != null &&
      t.dueDate!.isBefore(now)
    ).toList();
  }

  /// Get upcoming events (next 7 days)
  List<CalendarEventModel> get upcomingEvents {
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    return calendarEvents.where((e) =>
      e.startTime.isAfter(now) &&
      e.startTime.isBefore(weekLater)
    ).toList();
  }

  /// Get events within next 3 days
  List<CalendarEventModel> get urgentEvents {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    return calendarEvents.where((e) =>
      e.startTime.isAfter(now) &&
      e.startTime.isBefore(threeDaysLater)
    ).toList();
  }

  /// Get events today
  List<CalendarEventModel> get todayEvents {
    final now = DateTime.now();
    return calendarEvents.where((e) =>
      e.startTime.year == now.year &&
      e.startTime.month == now.month &&
      e.startTime.day == now.day
    ).toList();
  }

  /// Convert to JSON for AI prompt
  Map<String, dynamic> toContextJson() {
    return {
      'user': {
        'id': userId,
        'role': userRole.name,
        'personality': personality.name,
        'language': languageCode,
      },
      'tasks': {
        'total': tasks.length,
        'pending': pendingTasks.length,
        'completed': completedTasks.length,
        'high_priority': highPriorityTasks.length,
        'overdue': overdueTasks.length,
        'items': tasks.map((t) => {
          'id': t.id,
          'title': t.title,
          'description': t.description,
          'is_done': t.isDone,
          'priority': t.priority,
          'due_date': t.dueDate?.toIso8601String(),
          'category': t.category,
        }).toList(),
      },
      'calendar': {
        'total_events': calendarEvents.length,
        'today': todayEvents.length,
        'next_3_days': urgentEvents.length,
        'next_7_days': upcomingEvents.length,
        'items': calendarEvents.map((e) => {
          'id': e.id,
          'title': e.title,
          'description': e.description,
          'start_time': e.startTime.toIso8601String(),
          'end_time': e.endTime.toIso8601String(),
          'location': e.location,
          'attendees': e.attendees,
          'is_all_day': e.isAllDay,
        }).toList(),
      },
      'retrieval': {
        'retrieved_at': retrievedAt.toIso8601String(),
        'is_complete': isComplete,
        'errors': retrievalErrors,
      },
    };
  }

  /// Create context summary text for AI
  String toContextSummary() {
    final buffer = StringBuffer();
    buffer.writeln('USER CONTEXT SNAPSHOT');
    buffer.writeln('=====================');
    buffer.writeln('Role: ${userRole.name}');
    buffer.writeln('Retrieved: ${retrievedAt.toIso8601String()}');
    buffer.writeln();

    buffer.writeln('TASKS:');
    buffer.writeln('  Total: ${tasks.length}');
    buffer.writeln('  Pending: ${pendingTasks.length}');
    buffer.writeln('  Completed: ${completedTasks.length}');
    buffer.writeln('  High Priority: ${highPriorityTasks.length}');
    buffer.writeln('  Overdue: ${overdueTasks.length}');

    if (pendingTasks.isNotEmpty) {
      buffer.writeln('\n  Pending Tasks:');
      for (final task in pendingTasks.take(10)) {
        buffer.writeln('    - [${task.priority}] ${task.title}');
        if (task.dueDate != null) {
          buffer.writeln('      Due: ${task.dueDate}');
        }
      }
    }

    buffer.writeln('\nCALENDAR:');
    buffer.writeln('  Total Events: ${calendarEvents.length}');
    buffer.writeln('  Today: ${todayEvents.length}');
    buffer.writeln('  Next 3 Days: ${urgentEvents.length}');
    buffer.writeln('  Next 7 Days: ${upcomingEvents.length}');

    if (urgentEvents.isNotEmpty) {
      buffer.writeln('\n  Urgent Events (Next 3 Days):');
      for (final event in urgentEvents) {
        buffer.writeln('    - ${event.title}');
        buffer.writeln('      Time: ${event.startTime}');
        if (event.location != null) {
          buffer.writeln('      Location: ${event.location}');
        }
      }
    }

    if (!isComplete && retrievalErrors.isNotEmpty) {
      buffer.writeln('\nRETRIEVAL WARNINGS:');
      for (final error in retrievalErrors) {
        buffer.writeln('  - $error');
      }
    }

    return buffer.toString();
  }

  ContextSnapshot copyWith({
    String? userId,
    UserRole? userRole,
    AiPersonality? personality,
    String? languageCode,
    List<TaskModel>? tasks,
    List<CalendarEventModel>? calendarEvents,
    DateTime? retrievedAt,
    bool? isComplete,
    List<String>? retrievalErrors,
  }) {
    return ContextSnapshot(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      personality: personality ?? this.personality,
      languageCode: languageCode ?? this.languageCode,
      tasks: tasks ?? this.tasks,
      calendarEvents: calendarEvents ?? this.calendarEvents,
      retrievedAt: retrievedAt ?? this.retrievedAt,
      isComplete: isComplete ?? this.isComplete,
      retrievalErrors: retrievalErrors ?? this.retrievalErrors,
    );
  }
}
