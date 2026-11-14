# Task 1: Model Switch and Tool-Calling HTTP Method

## Context
This is Task 1 of 9 in the Yharbid AI Work Assistant implementation.
It is a small, focused change to two files: switching the locked Groq model string
and adding a new HTTP method that sends tool definitions to the Groq API.

## Files
- **Modify:** `lib/services/ai_service.dart`
- **Modify:** `lib/core/config/app_config.dart`
- **Test:** `test/agent_service_test.dart` (create this file)

## Requirements (verbatim)

### Step 1: Write failing test that asserts model string
```dart
// test/agent_service_test.dart
test('locked model is openai/gpt-oss-120b', () {
  expect(AiService.lockedModel, equals('openai/gpt-oss-120b'));
});
```

### Step 2: Run test — expect FAIL
Run: `flutter test test/agent_service_test.dart --plain-name "locked model"`
Expected: FAIL — `Expected: openai/gpt-oss-120b  Actual: openai/gpt-oss-20b`

### Step 3: Change `_LOCKED_GROQ_MODEL` in `ai_service.dart:31`
Replace `'openai/gpt-oss-20b'` with `'openai/gpt-oss-120b'`.

### Step 4: Change `_FALLBACK_AI_MODEL` in `app_config.dart:33`
Replace `'openai/gpt-oss-20b'` with `'openai/gpt-oss-120b'`.

### Step 5: Run test — expect PASS
Run: `flutter test test/agent_service_test.dart --plain-name "locked model"`
Expected: PASS

### Step 6: Add `callWithTools()` method to `AiService`
Signature:
```dart
Future<Map<String, dynamic>> callWithTools(
  List<Map<String, dynamic>> messages,
  List<Map<String, dynamic>> tools, {
  int maxTokens = 1500,
  double temperature = 0.3,
})
```

Implementation: POST to `_groqBaseUrl` with same auth pattern as existing `_callGroqApi`.
Add `'tools': tools, 'tool_choice': 'auto'` to the JSON body.
Call `_verifyAuth()` first (same as existing methods).
Return the full decoded JSON response (do NOT extract `choices[0]`).
Throw `Exception` on non-200 responses (same pattern as existing error handling).

### Step 7: Write test for `callWithTools` HTTP shape
```dart
test('callWithTools includes tools in request body', () async {
  final service = AiService();
  final body = service.buildToolCallBody(
    messages: [{'role': 'user', 'content': 'hi'}],
    tools: [{'type': 'function', 'function': {'name': 'get_existing_tasks', 'parameters': {}}}],
  );
  expect(body['tools'], isNotNull);
  expect(body['model'], equals('openai/gpt-oss-120b'));
  expect(body['tool_choice'], equals('auto'));
});
```

Add a `@visibleForTesting` method `buildToolCallBody` to `AiService`:
```dart
@visibleForTesting
Map<String, dynamic> buildToolCallBody({
  required List<Map<String, dynamic>> messages,
  required List<Map<String, dynamic>> tools,
  int maxTokens = 1500,
  double temperature = 0.3,
})
```
This method returns the map that `callWithTools` would encode. `callWithTools` should
call this method internally to build its body.

Use `package:flutter/foundation.dart` for `@visibleForTesting` (already imported or add it).

### Step 8: Run test — expect PASS
Run: `flutter test test/agent_service_test.dart --plain-name "callWithTools"`
Expected: PASS

### Step 9: Run flutter analyze to verify no new errors
Run: `flutter analyze --no-pub 2>&1 | grep "^  error"`
Expected: 0 errors

### Step 10: Commit
```bash
git add lib/services/ai_service.dart lib/core/config/app_config.dart test/agent_service_test.dart
git commit -m "feat: upgrade model to openai/gpt-oss-120b and add callWithTools"
```

## Global Constraints (binding for this task)
- Model MUST be exactly `openai/gpt-oss-120b` — never substituted
- Groq API key sourced from `AppConfig.groqApiKey` — never hardcoded
- No deployment, no push
- Do not delete or weaken existing tests
- `@visibleForTesting` from `package:flutter/foundation.dart`

## Existing Code Context

`lib/services/ai_service.dart` currently has:
- `static const String _LOCKED_GROQ_MODEL = 'openai/gpt-oss-20b';` at line 31
- `Future<Map<String, dynamic>> _callGroqApi(...)` as the existing HTTP method pattern
- `_verifyAuth()` method pattern to reuse

`lib/core/config/app_config.dart` has:
- `static const String _FALLBACK_AI_MODEL = 'openai/gpt-oss-20b';` at line 33

## Report File
Write your complete report to: `.superpowers/sdd/ai-work-assistant/task-1-report.md`

Return (in your final message only): status (DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED),
the commit hash, test results one-liner, and any concerns.

## IMPORTANT
Do NOT dispatch any subagents or reviewers. Implement, test, and commit yourself.
