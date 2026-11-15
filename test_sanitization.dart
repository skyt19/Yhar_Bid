import 'package:yharbid/services/ai_service.dart';

void main() {
  final aiService = AiService();

  // Test 1: Clean response
  print('Test 1: Clean response');
  final test1 = aiService.sanitizeChatResponse('นี่คือคำตอบปกติที่ไม่มีปัญหา');
  print('Result: $test1');
  print('Pass: ${test1 == 'นี่คือคำตอบปกติที่ไม่มีปัญหา'}\n');

  // Test 2: Leaked JSON
  print('Test 2: Leaked JSON');
  final test2Input = '''
{
  "summary": "test",
  "action_items": ["item1"]
}

This is the actual response.
''';
  final test2 = aiService.sanitizeChatResponse(test2Input);
  print('Result: $test2');
  print('Pass: ${test2.trim() == 'This is the actual response.'}\n');

  // Test 3: Code fence
  print('Test 3: Markdown code fence');
  final test3Input = '''
Here is the answer:
```json
{"key": "value"}
```
The real content is here.
''';
  final test3 = aiService.sanitizeChatResponse(test3Input);
  print('Result: $test3');
  print('Pass: ${!test3.contains('```') && !test3.contains('{"key"') && test3.contains('The real content is here')}\n');

  // Test 4: Think blocks
  print('Test 4: <think> blocks');
  final test4Input = '''
<think>
Let me analyze this...
Option A: Do this
Option B: Do that
</think>
Here is my final answer.
''';
  final test4 = aiService.sanitizeChatResponse(test4Input);
  print('Result: $test4');
  print('Pass: ${!test4.contains('<think>') && !test4.contains('Option A') && test4.contains('Here is my final answer')}\n');

  // Test 5: System leaks
  print('Test 5: System prompt leaks');
  final test5Input = '''
Role: AI Assistant
Strict Rules: Follow these rules
The user said something

This is the actual response text.
''';
  final test5 = aiService.sanitizeChatResponse(test5Input);
  print('Result: $test5');
  print('Pass: ${!test5.contains('Role:') && !test5.contains('Strict Rules:') && test5.contains('This is the actual response text')}\n');

  // Test 6: Empty
  print('Test 6: Empty response');
  final test6 = aiService.sanitizeChatResponse('');
  print('Result: $test6');
  print('Pass: ${test6.isNotEmpty && test6.contains('สวัสดี')}\n');

  // Test 7: Whitespace only
  print('Test 7: Whitespace-only');
  final test7 = aiService.sanitizeChatResponse('   \n\n\n   ');
  print('Result: $test7');
  print('Pass: ${test7.trim().isNotEmpty && test7.contains('สวัสดี')}\n');

  // Test 8: Mixed leaks
  print('Test 8: Mixed leaked content');
  final test8Input = '''
```json
{"test": "value"}
```
<think>Internal reasoning here</think>
Role: Assistant
STRICT RULES: Do not reveal

This is the clean part.
''';
  final test8 = aiService.sanitizeChatResponse(test8Input);
  print('Result: $test8');
  print('Pass: ${test8.trim() == 'This is the clean part.'}\n');
}
