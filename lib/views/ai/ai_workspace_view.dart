/// lib/views/ai/ai_workspace_view.dart
/// Redesigned AI Workspace — Intelligent preparation workflow interface
/// Emphasizes AI-powered conversation with personality-matched responses
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../theme/app_theme.dart';
import 'ai_context_analysis_view.dart';

class AIWorkspaceView extends StatefulWidget {
  const AIWorkspaceView({super.key});

  @override
  State<AIWorkspaceView> createState() => _AIWorkspaceViewState();
}

class _AIWorkspaceViewState extends State<AIWorkspaceView> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && _scrollCtrl.position.maxScrollExtent > 0) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _send(AiController aiCtrl) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    aiCtrl.sendMessage(text);
    _scrollToBottom();
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final aiCtrl = Get.put(AiController());
    final authCtrl = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with AI personality indicator
            _buildHeader(authCtrl, aiCtrl, isWide),

            // Chat conversation area
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Column(
                  children: [
                    // Conversation messages
                    Expanded(
                      child: Obx(() {
                        final msgs = aiCtrl.chatMessages;
                        final loading = aiCtrl.isTyping.value;

                        if (msgs.isEmpty && !loading) {
                          return _buildEmptyState(authCtrl);
                        }

                        _scrollToBottom();
                        return ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(24),
                          itemCount: msgs.length + (loading ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == msgs.length) {
                              return _buildTypingIndicator();
                            }
                            final msg = msgs[i];
                            return _buildMessageBubble(
                              isUser: msg['role'] == 'user',
                              content: msg['content'] ?? '',
                              personality: authCtrl.currentUser.value?.personality ?? AiPersonality.politeJarvis,
                            );
                          },
                        );
                      }),
                    ),

                    // Input bar
                    _buildInputBar(aiCtrl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authCtrl, AiController aiCtrl, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 16,
      ),
      child: Row(
        children: [
          // AI personality avatar
          Obx(() {
            final user = authCtrl.currentUser.value;
            final personality = user?.personality ?? AiPersonality.politeJarvis;

            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPersonalityColor(personality),
                    _getPersonalityColor(personality).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: _getPersonalityColor(personality).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getPersonalityIcon(personality),
                color: Colors.white,
                size: 24,
              ),
            );
          }),
          const SizedBox(width: 16),

          // AI name and personality mode
          Expanded(
            child: Obx(() {
              final user = authCtrl.currentUser.value;
              final personalityLabel = user != null
                  ? _getPersonalityLabel(user.personality)
                  : 'AI Assistant';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yharbid AI',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    personalityLabel,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),

          // Context analysis button
          TextButton.icon(
            onPressed: () {
              Get.to(() => const AIContextAnalysisView());
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Context'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          // Clear conversation button
          IconButton(
            onPressed: () => _showClearDialog(aiCtrl),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppTheme.textSecondary,
            tooltip: 'Clear conversation',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AuthController authCtrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI preparation illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen.withOpacity(0.2),
                    AppTheme.accentGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 64,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: 32),

            Obx(() {
              final user = authCtrl.currentUser.value;
              final greeting = user != null
                  ? _getWelcomeMessage(user.personality, user.displayName)
                  : 'Ask me anything about your upcoming events';

              return Column(
                children: [
                  Text(
                    greeting,
                    style: AppTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'I can help you prepare for lectures, meetings,\nexams, and everything on your calendar',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Example prompts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip('What\'s coming up this week?'),
                _buildPromptChip('Help me prepare for tomorrow'),
                _buildPromptChip('Show my urgent tasks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    final aiCtrl = Get.find<AiController>();

    return ActionChip(
      label: Text(text),
      onPressed: () {
        _textCtrl.text = text;
        _send(aiCtrl);
      },
      backgroundColor: AppTheme.surfaceGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        side: BorderSide(color: AppTheme.borderStrong.withOpacity(0.3)),
      ),
      labelStyle: AppTheme.bodyMedium,
    );
  }

  Widget _buildMessageBubble({
    required bool isUser,
    required String content,
    required AiPersonality personality,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPersonalityColor(personality).withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _getPersonalityIcon(personality),
                size: 18,
                color: _getPersonalityColor(personality),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.accentGreen
                    : AppTheme.surfaceGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge).copyWith(
                  topLeft: isUser ? null : const Radius.circular(4),
                  topRight: isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                content,
                style: AppTheme.bodyMedium.copyWith(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppTheme.accentGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.psychology,
              size: 18,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge).copyWith(
                topLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(150),
                const SizedBox(width: 4),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildInputBar(AiController aiCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              focusNode: _inputFocus,
              decoration: InputDecoration(
                hintText: 'Ask about your upcoming events...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textTertiary,
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(aiCtrl),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => IconButton(
            onPressed: aiCtrl.isTyping.value ? null : () => _send(aiCtrl),
            icon: Icon(
              Icons.send_rounded,
              color: aiCtrl.isTyping.value
                  ? AppTheme.textTertiary
                  : AppTheme.accentGreen,
            ),
            style: IconButton.styleFrom(
              backgroundColor: aiCtrl.isTyping.value
                  ? AppTheme.surfaceGray
                  : AppTheme.accentGreen.withOpacity(0.12),
              padding: const EdgeInsets.all(14),
            ),
          )),
        ],
      ),
    );
  }

  void _showClearDialog(AiController aiCtrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text('This will remove all messages from this chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              aiCtrl.clearChat();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getPersonalityLabel(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'Polite & Professional';
      case AiPersonality.friendly:
        return 'Friendly & Supportive';
      case AiPersonality.aggressiveMotivator:
        return 'Direct & Motivating';
    }
  }

  IconData _getPersonalityIcon(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return Icons.psychology_outlined;
      case AiPersonality.friendly:
        return Icons.emoji_emotions_outlined;
      case AiPersonality.aggressiveMotivator:
        return Icons.flash_on_outlined;
    }
  }

  Color _getPersonalityColor(AiPersonality personality) {
    switch (personality) {
      case AiPersonality.politeJarvis:
        return AppTheme.accentGreen;
      case AiPersonality.friendly:
        return AppTheme.accentGreen;
      case AiPersonality.aggressiveMotivator:
        return AppTheme.accentOrange;
    }
  }

  String _getWelcomeMessage(AiPersonality personality, String displayName) {
    final firstName = displayName.split(' ').first;
    switch (personality) {
      case AiPersonality.politeJarvis:
        return 'Hello $firstName, how may I assist with your preparations today?';
      case AiPersonality.friendly:
        return 'Hey $firstName! Ready to tackle what is ahead?';
      case AiPersonality.aggressiveMotivator:
        return '$firstName! Let us prepare and crush those tasks!';
    }
  }
}
