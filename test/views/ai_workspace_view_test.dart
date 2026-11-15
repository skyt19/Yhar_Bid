/// test/views/ai_workspace_view_test.dart
/// Regression tests for AI Workspace restoration and chat history integration

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:yharbid/controllers/ai_controller.dart';
import 'package:yharbid/controllers/auth_controller.dart';
import 'package:yharbid/views/ai/ai_workspace_view.dart';
import 'package:yharbid/views/theme/app_theme.dart';

void main() {
  group('AI Workspace Regression Tests', () {
    late AiController aiCtrl;
    late AuthController authCtrl;

    setUp(() {
      Get.testMode = true;
      aiCtrl = AiController();
      authCtrl = AuthController();
      Get.put<AiController>(aiCtrl);
      Get.put<AuthController>(authCtrl);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('AIWorkspaceView renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify workspace renders
      expect(find.byType(AIWorkspaceView), findsOneWidget);
      expect(find.text('Yharbid AI'), findsOneWidget);
    });

    testWidgets('Desktop layout shows persistent sidebar at wide screen', (WidgetTester tester) async {
      // Set wide screen size (1200px+)
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sidebar exists
      expect(find.text('Chat History'), findsOneWidget);
    });

    testWidgets('Mobile layout uses drawer for history', (WidgetTester tester) async {
      // Set mobile screen size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify history toggle button exists
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('AI Context Analysis button is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Context Analysis button
      expect(find.text('Context'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('New conversation button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify new conversation button
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('Message input field renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Ask about your upcoming events...'), findsOneWidget);
    });

    testWidgets('Send button is functional', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify send button
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('Empty state shows welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.byIcon(Icons.psychology), findsWidgets);
      expect(find.text('Ask me anything about your upcoming events'), findsOneWidget);
    });

    testWidgets('Quick prompt chips are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify quick prompts
      expect(find.text('What\'s coming up this week?'), findsOneWidget);
      expect(find.text('Help me prepare for tomorrow'), findsOneWidget);
      expect(find.text('Show my urgent tasks'), findsOneWidget);
    });
  });

  group('AI Message Rendering Tests', () {
    late AiController aiCtrl;
    late AuthController authCtrl;

    setUp(() {
      Get.testMode = true;
      aiCtrl = AiController();
      authCtrl = AuthController();
      Get.put<AiController>(aiCtrl);
      Get.put<AuthController>(authCtrl);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('User messages render with proper containers', (WidgetTester tester) async {
      aiCtrl.chatMessages.add({'role': 'user', 'content': 'Test message'});

      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify user message container exists
      expect(find.text('Test message'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('AI messages render with proper containers', (WidgetTester tester) async {
      aiCtrl.chatMessages.add({'role': 'assistant', 'content': 'AI response'});

      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AI message container exists
      expect(find.text('AI response'), findsOneWidget);
    });

    testWidgets('Regenerate button appears for last assistant message', (WidgetTester tester) async {
      aiCtrl.chatMessages.add({'role': 'user', 'content': 'Question'});
      aiCtrl.chatMessages.add({'role': 'assistant', 'content': 'Answer'});

      await tester.pumpWidget(
        GetMaterialApp(
          home: const AIWorkspaceView(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify regenerate button
      expect(find.text('Regenerate'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('AI Controller Tests', () {
    late AiController aiCtrl;

    setUp(() {
      Get.testMode = true;
      aiCtrl = AiController();
    });

    tearDown(() {
      Get.reset();
    });

    test('clearChat removes all messages', () {
      aiCtrl.chatMessages.add({'role': 'user', 'content': 'Test'});
      aiCtrl.chatMessages.add({'role': 'assistant', 'content': 'Response'});

      expect(aiCtrl.chatMessages.length, 2);

      aiCtrl.clearChat();

      expect(aiCtrl.chatMessages.length, 0);
      expect(aiCtrl.errorMessage.value, '');
    });

    test('Conversation history state initializes correctly', () {
      expect(aiCtrl.conversations, isA<List>());
      expect(aiCtrl.conversations.length, 0);
      expect(aiCtrl.currentConversation.value, isNull);
      expect(aiCtrl.isLoadingConversations.value, false);
    });
  });
}
