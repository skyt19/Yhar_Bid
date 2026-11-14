/// lib/models/prepared_plan_model.dart
/// Data model for interactive preparation plans with per-step completion tracking
import 'package:cloud_firestore/cloud_firestore.dart';

/// Individual preparation step with completion state
class PreparationStep {
  final String id; // Stable unique ID: step_1, step_2, etc.
  final int order; // 1-based ordering for display
  final String text; // Step description in Thai
  final bool isCompleted;
  final DateTime? completedAt;

  const PreparationStep({
    required this.id,
    required this.order,
    required this.text,
    required this.isCompleted,
    this.completedAt,
  });

  PreparationStep copyWith({
    String? id,
    int? order,
    String? text,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PreparationStep(
      id: id ?? this.id,
      order: order ?? this.order,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'text': text,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PreparationStep.fromMap(Map<String, dynamic> map) {
    return PreparationStep(
      id: map['id'] as String? ?? '',
      order: map['order'] as int? ?? 1,
      text: map['text'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
        ? DateTime.parse(map['completedAt'] as String)
        : null,
    );
  }
}

/// Prepared plan with structured AI analysis and interactive checklist
class PreparedPlanModel {
  final String id;
  final String userId;
  final String proposalId; // Links back to PreparationProposal
  final String eventId; // Google Calendar Event ID
  final String eventTitle;
  final DateTime eventDateTime;
  final String eventLocation;
  final String objective; // Parsed from AI content
  final List<PreparationStep> steps; // Parsed from AI content
  final List<String> resources; // Parsed from AI content
  final String timeline; // Parsed from AI content
  final String rawAiContent; // Original AI response as fallback
  final DateTime createdAt;
  final DateTime? completedAt; // null until all steps complete

  const PreparedPlanModel({
    required this.id,
    required this.userId,
    required this.proposalId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDateTime,
    required this.eventLocation,
    required this.objective,
    required this.steps,
    required this.resources,
    required this.timeline,
    required this.rawAiContent,
    required this.createdAt,
    this.completedAt,
  });

  // Computed properties
  int get completedStepCount => steps.where((s) => s.isCompleted).length;
  int get totalSteps => steps.length;
  double get progressPercentage => totalSteps > 0 ? completedStepCount / totalSteps : 0.0;
  int get progressPercent => (progressPercentage * 100).round();
  bool get isCompleted => totalSteps > 0 && completedStepCount == totalSteps;
  bool get isInProgress => completedStepCount > 0 && !isCompleted;
  bool get hasEventPassed => eventDateTime.isBefore(DateTime.now());

  PreparedPlanModel copyWith({
    String? id,
    String? userId,
    String? proposalId,
    String? eventId,
    String? eventTitle,
    DateTime? eventDateTime,
    String? eventLocation,
    String? objective,
    List<PreparationStep>? steps,
    List<String>? resources,
    String? timeline,
    String? rawAiContent,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return PreparedPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      proposalId: proposalId ?? this.proposalId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      eventLocation: eventLocation ?? this.eventLocation,
      objective: objective ?? this.objective,
      steps: steps ?? this.steps,
      resources: resources ?? this.resources,
      timeline: timeline ?? this.timeline,
      rawAiContent: rawAiContent ?? this.rawAiContent,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'proposalId': proposalId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'eventLocation': eventLocation,
      'objective': objective,
      'steps': steps.map((s) => s.toMap()).toList(),
      'resources': resources,
      'timeline': timeline,
      'rawAiContent': rawAiContent,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory PreparedPlanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final stepsData = data['steps'] as List<dynamic>? ?? [];

    return PreparedPlanModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      proposalId: data['proposalId'] as String? ?? '',
      eventId: data['eventId'] as String? ?? '',
      eventTitle: data['eventTitle'] as String? ?? '',
      eventDateTime: (data['eventDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventLocation: data['eventLocation'] as String? ?? '',
      objective: data['objective'] as String? ?? '',
      steps: stepsData.map((s) => PreparationStep.fromMap(s as Map<String, dynamic>)).toList(),
      resources: (data['resources'] as List<dynamic>?)?.cast<String>() ?? [],
      timeline: data['timeline'] as String? ?? '',
      rawAiContent: data['rawAiContent'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
