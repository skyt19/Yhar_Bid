/// lib/models/task_plan_document_model.dart
/// Complete task plan document model for TXT generation and storage
/// Phase 1-3 Integration: Calendar → AI → TXT File

import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_event_model.dart';

/// Represents a complete task preparation plan for one or more events
class TaskPlanDocument {
  final String id;
  final String userId;
  final DateTime generatedAt;
  final DateTime planningStartDate;
  final DateTime planningEndDate;
  final int eventCount;
  final List<EventAnalysis> events;

  const TaskPlanDocument({
    required this.id,
    required this.userId,
    required this.generatedAt,
    required this.planningStartDate,
    required this.planningEndDate,
    required this.eventCount,
    required this.events,
  });

  /// Validate that all required fields are present
  bool get isValid {
    if (userId.isEmpty) return false;
    if (eventCount == 0) return false;
    if (events.isEmpty) return false;
    if (events.length != eventCount) return false;

    // Validate each event analysis
    for (final event in events) {
      if (!event.isValid) return false;
    }

    return true;
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'planningStartDate': Timestamp.fromDate(planningStartDate),
      'planningEndDate': Timestamp.fromDate(planningEndDate),
      'eventCount': eventCount,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory TaskPlanDocument.fromJson(Map<String, dynamic> json) {
    return TaskPlanDocument(
      id: json['id'] as String,
      userId: json['userId'] as String,
      generatedAt: (json['generatedAt'] as Timestamp).toDate(),
      planningStartDate: (json['planningStartDate'] as Timestamp).toDate(),
      planningEndDate: (json['planningEndDate'] as Timestamp).toDate(),
      eventCount: json['eventCount'] as int,
      events: (json['events'] as List<dynamic>)
          .map((e) => EventAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// AI analysis result for a single calendar event
class EventAnalysis {
  final String eventId;
  final String eventTitle;
  final String? eventDescription;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String>? attendees;
  final String objective;
  final String expectedOutcome;
  final List<String> preparationSteps;
  final List<String> executionSteps;
  final List<String> requiredResources;
  final String priority; // High, Medium, Low
  final int estimatedPrepTimeMinutes;
  final String suggestedTimeline;
  final List<String> dependencies;
  final List<String> risks;
  final List<String> checklist;
  final List<String> missingInformation;
  final bool isFallback; // True if using offline template

  const EventAnalysis({
    required this.eventId,
    required this.eventTitle,
    this.eventDescription,
    required this.startTime,
    required this.endTime,
    this.location,
    this.attendees,
    required this.objective,
    required this.expectedOutcome,
    required this.preparationSteps,
    required this.executionSteps,
    required this.requiredResources,
    required this.priority,
    required this.estimatedPrepTimeMinutes,
    required this.suggestedTimeline,
    required this.dependencies,
    required this.risks,
    required this.checklist,
    required this.missingInformation,
    this.isFallback = false,
  });

  /// Validate analysis completeness
  bool get isValid {
    if (eventId.isEmpty) return false;
    if (eventTitle.isEmpty) return false;
    if (objective.isEmpty) return false;
    if (preparationSteps.isEmpty) return false;
    if (priority.isEmpty) return false;
    if (!['High', 'Medium', 'Low'].contains(priority)) return false;

    return true;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'attendees': attendees,
      'objective': objective,
      'expectedOutcome': expectedOutcome,
      'preparationSteps': preparationSteps,
      'executionSteps': executionSteps,
      'requiredResources': requiredResources,
      'priority': priority,
      'estimatedPrepTimeMinutes': estimatedPrepTimeMinutes,
      'suggestedTimeline': suggestedTimeline,
      'dependencies': dependencies,
      'risks': risks,
      'checklist': checklist,
      'missingInformation': missingInformation,
      'isFallback': isFallback,
    };
  }

  /// Create from JSON
  factory EventAnalysis.fromJson(Map<String, dynamic> json) {
    return EventAnalysis(
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      eventDescription: json['eventDescription'] as String?,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      location: json['location'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)?.cast<String>(),
      objective: json['objective'] as String,
      expectedOutcome: json['expectedOutcome'] as String,
      preparationSteps: (json['preparationSteps'] as List<dynamic>).cast<String>(),
      executionSteps: (json['executionSteps'] as List<dynamic>).cast<String>(),
      requiredResources: (json['requiredResources'] as List<dynamic>).cast<String>(),
      priority: json['priority'] as String,
      estimatedPrepTimeMinutes: json['estimatedPrepTimeMinutes'] as int,
      suggestedTimeline: json['suggestedTimeline'] as String,
      dependencies: (json['dependencies'] as List<dynamic>).cast<String>(),
      risks: (json['risks'] as List<dynamic>).cast<String>(),
      checklist: (json['checklist'] as List<dynamic>).cast<String>(),
      missingInformation: (json['missingInformation'] as List<dynamic>).cast<String>(),
      isFallback: json['isFallback'] as bool? ?? false,
    );
  }

  /// Create from CalendarEventModel and basic AI response
  factory EventAnalysis.fromCalendarAndAI({
    required CalendarEventModel event,
    required Map<String, dynamic> aiResponse,
  }) {
    final actionItems = (aiResponse['action_items'] as List<dynamic>?)?.cast<String>() ?? [];
    final summary = aiResponse['summary'] as String? ?? event.title;
    final isFallback = aiResponse['_fallback'] == true;

    return EventAnalysis(
      eventId: event.id,
      eventTitle: event.title,
      eventDescription: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      attendees: event.attendees,
      objective: summary,
      expectedOutcome: 'งานเสร็จสมบูรณ์ตามกำหนด',
      preparationSteps: actionItems,
      executionSteps: ['ดำเนินการตามแผนที่วางไว้'],
      requiredResources: [],
      priority: 'Medium',
      estimatedPrepTimeMinutes: 30,
      suggestedTimeline: 'เริ่มเตรียมก่อนงาน 1-2 วัน',
      dependencies: [],
      risks: [],
      checklist: actionItems,
      missingInformation: event.description == null || event.description!.isEmpty
          ? ['ไม่มีรายละเอียดเพิ่มเติมในปฏิทิน']
          : [],
      isFallback: isFallback,
    );
  }
}
