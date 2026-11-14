/// test/services/ai_service_json_parsing_test.dart
/// Tests for AI Discovery JSON extraction and validation
/// Phase D: Comprehensive parsing tests

import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/ai_service.dart';
import '../../lib/services/ai_service_types.dart';
import '../../lib/models/ai_discovery_model.dart';

void main() {
  group('AI Discovery JSON Parsing', () {
    late AiService aiService;

    setUp(() {
      aiService = AiService();
    });

    group('JSON Extraction', () {
      test('Plain JSON response', () {
        const String response = '''
{
  "analysis": {
    "summary": "Test summary",
    "identified_issues": ["issue1"],
    "priorities": ["priority1"]
  },
  "proposals": [],
  "requires_clarification": false,
  "clarification_questions": []
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result, isNotNull);
        expect(result.result!.summary, 'Test summary');
        expect(result.result!.identifiedIssues, ['issue1']);
        expect(result.result!.priorities, ['priority1']);
        expect(result.result!.proposals, isEmpty);
      });

      test('Markdown ```json fenced response', () {
        const String response = '''
```json
{
  "analysis": {
    "summary": "Fenced response",
    "identified_issues": [],
    "priorities": []
  },
  "proposals": [],
  "requires_clarification": false,
  "clarification_questions": []
}
```
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'Fenced response');
      });

      test('Markdown ``` fenced response without language', () {
        const String response = '''
```
{
  "analysis": {
    "summary": "Plain fence",
    "identified_issues": [],
    "priorities": []
  },
  "proposals": []
}
```
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'Plain fence');
      });

      test('JSON surrounded by explanatory text', () {
        const String response = '''
Here's the analysis you requested:

{
  "analysis": {
    "summary": "Embedded JSON",
    "identified_issues": ["issue1"],
    "priorities": []
  },
  "proposals": []
}

Hope this helps!
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'Embedded JSON');
        expect(result.result!.identifiedIssues, ['issue1']);
      });

      test('Leading and trailing whitespace', () {
        const String response = '''


  {
    "analysis": {
      "summary": "Whitespace test",
      "identified_issues": [],
      "priorities": []
    },
    "proposals": []
  }


''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'Whitespace test');
      });

      test('JSON containing escaped quotes and newlines', () {
        const String response = '''
{
  "analysis": {
    "summary": "Test with \\"escaped quotes\\" and\\nnewlines",
    "identified_issues": ["Issue: \\"critical\\""],
    "priorities": []
  },
  "proposals": []
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, contains('escaped quotes'));
        expect(result.result!.identifiedIssues[0], contains('critical'));
      });
    });

    group('Optional Fields Handling', () {
      test('Valid response with optional fields missing', () {
        const String response = '''
{
  "analysis": {
    "summary": "Minimal valid response"
  },
  "proposals": [
    {
      "title": "Task 1",
      "description": "Description 1",
      "reason": "Reason 1",
      "priority": "high"
    }
  ]
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'Minimal valid response');
        expect(result.result!.identifiedIssues, isEmpty);
        expect(result.result!.priorities, isEmpty);
        expect(result.result!.proposals.length, 1);
        expect(result.result!.proposals[0].title, 'Task 1');
        expect(result.result!.proposals[0].subtasks, isEmpty);
        expect(result.result!.proposals[0].evidence, isEmpty);
        expect(result.result!.proposals[0].assumptions, isEmpty);
        expect(result.result!.requiresClarification, false);
      });

      test('Valid response with zero proposals', () {
        const String response = '''
{
  "analysis": {
    "summary": "No recommendations needed",
    "identified_issues": [],
    "priorities": []
  },
  "proposals": []
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.summary, 'No recommendations needed');
        expect(result.result!.proposals, isEmpty);
        expect(result.result!.hasProposals, false);
      });

      test('Proposal with all optional fields present', () {
        const String response = '''
{
  "analysis": {
    "summary": "Complete proposal",
    "identified_issues": [],
    "priorities": []
  },
  "proposals": [
    {
      "id": "prop_001",
      "title": "Complete Task",
      "description": "Full description",
      "reason": "Clear reason",
      "priority": "medium",
      "subtasks": ["sub1", "sub2"],
      "related_task_ids": ["task1"],
      "related_event_ids": ["event1"],
      "evidence": ["evidence1"],
      "assumptions": ["assumption1"],
      "suggested_timing": "tomorrow"
    }
  ]
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.proposals.length, 1);
        final proposal = result.result!.proposals[0];
        expect(proposal.id, 'prop_001');
        expect(proposal.subtasks, ['sub1', 'sub2']);
        expect(proposal.relatedTaskIds, ['task1']);
        expect(proposal.relatedEventIds, ['event1']);
        expect(proposal.evidence, ['evidence1']);
        expect(proposal.assumptions, ['assumption1']);
        expect(proposal.suggestedTiming, 'tomorrow');
      });
    });

    group('Error Handling', () {
      test('Malformed JSON - unclosed brace', () {
        const String response = '''
{
  "analysis": {
    "summary": "Incomplete",
    "identified_issues": []
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('Invalid JSON format'));
      });

      test('Malformed JSON - unexpected token', () {
        const String response = '''
{
  "analysis": {
    "summary": "Bad syntax",
    "identified_issues": [invalid token]
  }
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('Invalid JSON format'));
      });

      test('Invalid response schema - missing analysis', () {
        const String response = '''
{
  "proposals": [],
  "requires_clarification": false
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('Invalid response schema'));
        expect(result.error, contains('Missing "analysis" object'));
      });

      test('Invalid response schema - analysis not an object', () {
        const String response = '''
{
  "analysis": "should be object",
  "proposals": []
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('analysis" must be an object'));
      });

      test('Invalid response schema - missing summary', () {
        const String response = '''
{
  "analysis": {
    "identified_issues": [],
    "priorities": []
  },
  "proposals": []
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('summary must be a string'));
      });

      test('Invalid response schema - proposals not array', () {
        const String response = '''
{
  "analysis": {
    "summary": "Valid summary"
  },
  "proposals": "should be array"
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('proposals" must be an array'));
      });

      test('Invalid response schema - proposal missing required fields', () {
        const String response = '''
{
  "analysis": {
    "summary": "Valid summary"
  },
  "proposals": [
    {
      "title": "Task without description"
    }
  ]
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('description is required'));
      });

      test('Empty response', () {
        const String response = '';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('Empty response'));
      });

      test('Non-JSON response', () {
        const String response = 'This is not JSON at all';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, false);
        expect(result.error, contains('Invalid JSON format'));
      });
    });

    group('Real-World Scenarios', () {
      test('Response matching actual Groq output format', () {
        const String response = '''
```json
{
  "analysis": {
    "summary": "The student has six pending tasks, five of which are overdue.",
    "identified_issues": [
      "Multiple overdue tasks (5) requiring urgent action.",
      "Upcoming final project deadline today at 13:00:52."
    ],
    "priorities": [
      "Urgently complete the Software Engineering final project submission.",
      "Address the overdue Q4 strategy meeting agenda."
    ]
  },
  "proposals": [
    {
      "id": "proposal_001",
      "title": "Finalize and Submit Software Engineering Final Project",
      "description": "Complete all remaining code, run tests, write documentation.",
      "reason": "The project deadline is today and the task is overdue.",
      "priority": "high",
      "subtasks": [
        "Review code for remaining bugs",
        "Run all unit tests and fix failures",
        "Write or update README and project documentation"
      ],
      "related_task_ids": [],
      "related_event_ids": [],
      "evidence": [
        "Task: Software Engineering - Final Project Deadline due 2026-11-13 13:00:52.000"
      ],
      "assumptions": ["The project repository is accessible and up to date"],
      "suggested_timing": "Immediately, before the 13:00:52 deadline"
    }
  ],
  "requires_clarification": false,
  "clarification_questions": []
}
```
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result, isNotNull);
        expect(result.result!.summary, contains('six pending tasks'));
        expect(result.result!.identifiedIssues.length, 2);
        expect(result.result!.priorities.length, 2);
        expect(result.result!.proposals.length, 1);

        final proposal = result.result!.proposals[0];
        expect(proposal.id, 'proposal_001');
        expect(proposal.title, contains('Software Engineering'));
        expect(proposal.priority, 'high');
        expect(proposal.subtasks.length, 3);
        expect(proposal.evidence.length, 1);
        expect(proposal.assumptions.length, 1);
      });

      test('Multiple proposals with varying completeness', () {
        const String response = '''
{
  "analysis": {
    "summary": "Mixed analysis"
  },
  "proposals": [
    {
      "title": "Task 1",
      "description": "Full task",
      "reason": "Reason 1",
      "priority": "high",
      "subtasks": ["a", "b"],
      "evidence": ["e1"]
    },
    {
      "title": "Task 2",
      "description": "Minimal task",
      "reason": "Reason 2",
      "priority": "low"
    }
  ]
}
''';

        final result = aiService.parseDiscoveryResponse(response);

        expect(result.success, true);
        expect(result.result!.proposals.length, 2);
        expect(result.result!.proposals[0].subtasks.length, 2);
        expect(result.result!.proposals[1].subtasks, isEmpty);
      });
    });
  });
}
