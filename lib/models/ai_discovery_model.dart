/// lib/models/ai_discovery_model.dart
/// AI Discovery Models — Phase 3: Dynamic Discovery Engine
/// Represents AI-generated proposals and analysis results

/// AI-Generated Task Proposal
/// Created by AI based on context analysis, not predefined templates
class TaskProposal {
  final String id;
  final String title;
  final String description;
  final String reason;
  final String priority; // 'high', 'medium', 'low'
  final List<String> subtasks;
  final List<String> relatedTaskIds;
  final List<String> relatedEventIds;
  final List<String> evidence;
  final List<String> assumptions;
  final String? suggestedTiming;

  const TaskProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.subtasks,
    required this.relatedTaskIds,
    required this.relatedEventIds,
    required this.evidence,
    required this.assumptions,
    this.suggestedTiming,
  });

  factory TaskProposal.fromJson(Map<String, dynamic> json) {
    return TaskProposal(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      subtasks: (json['subtasks'] as List<dynamic>?)?.cast<String>() ?? [],
      relatedTaskIds: (json['related_task_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      relatedEventIds: (json['related_event_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      evidence: (json['evidence'] as List<dynamic>?)?.cast<String>() ?? [],
      assumptions: (json['assumptions'] as List<dynamic>?)?.cast<String>() ?? [],
      suggestedTiming: json['suggested_timing'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reason': reason,
      'priority': priority,
      'subtasks': subtasks,
      'related_task_ids': relatedTaskIds,
      'related_event_ids': relatedEventIds,
      'evidence': evidence,
      'assumptions': assumptions,
      if (suggestedTiming != null) 'suggested_timing': suggestedTiming,
    };
  }
}

/// AI Analysis Result
/// Complete analysis of user's situation with discovered proposals
class AnalysisResult {
  final String summary;
  final List<String> identifiedIssues;
  final List<String> priorities;
  final List<TaskProposal> proposals;
  final bool requiresClarification;
  final List<String> clarificationQuestions;

  const AnalysisResult({
    required this.summary,
    required this.identifiedIssues,
    required this.priorities,
    required this.proposals,
    required this.requiresClarification,
    required this.clarificationQuestions,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    // Parse nested analysis object if present
    final analysisJson = json['analysis'] as Map<String, dynamic>? ?? json;

    return AnalysisResult(
      summary: analysisJson['summary'] as String? ?? '',
      identifiedIssues: (analysisJson['identified_issues'] as List<dynamic>?)?.cast<String>() ?? [],
      priorities: (analysisJson['priorities'] as List<dynamic>?)?.cast<String>() ?? [],
      proposals: ((json['proposals'] as List<dynamic>?) ?? [])
          .map((p) => TaskProposal.fromJson(p as Map<String, dynamic>))
          .toList(),
      requiresClarification: json['requires_clarification'] as bool? ?? false,
      clarificationQuestions: (json['clarification_questions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': {
        'summary': summary,
        'identified_issues': identifiedIssues,
        'priorities': priorities,
      },
      'proposals': proposals.map((p) => p.toJson()).toList(),
      'requires_clarification': requiresClarification,
      'clarification_questions': clarificationQuestions,
    };
  }

  /// Check if analysis has actionable proposals
  bool get hasProposals => proposals.isNotEmpty;

  /// Get high priority proposals
  List<TaskProposal> get highPriorityProposals =>
      proposals.where((p) => p.priority.toLowerCase() == 'high').toList();

  /// Get proposals with evidence
  List<TaskProposal> get evidencedProposals =>
      proposals.where((p) => p.evidence.isNotEmpty).toList();
}

/// Empty Analysis Result (for error cases or no recommendations)
AnalysisResult emptyAnalysisResult({String? message}) {
  return AnalysisResult(
    summary: message ?? 'ไม่พบข้อมูลที่ต้องดำเนินการในขณะนี้',
    identifiedIssues: [],
    priorities: [],
    proposals: [],
    requiresClarification: false,
    clarificationQuestions: [],
  );
}
