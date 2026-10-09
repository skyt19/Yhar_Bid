import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';
import '../theme/app_theme.dart';

class AIWorkspaceView extends StatelessWidget {
  const AIWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    final aiCtrl = Get.put(AiController());
    final messageCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() => _buildChatHistory(aiCtrl)),
            ),
            const SizedBox(height: 16),
            _buildInputBar(messageCtrl, aiCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistory(AiController aiCtrl) {
    if (aiCtrl.chatMessages.isEmpty) {
      return const Center(
        child: Text(
          'Start conversation...',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: aiCtrl.chatMessages.length,
      itemBuilder: (context, index) {
        final msg = aiCtrl.chatMessages[index];
        return _buildMessageBubble(msg['role'] == 'user', msg['content'] ?? '');
      },
    );
  }

  Widget _buildMessageBubble(bool isUser, String content) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar('AI จาร์วิส'),
            const SizedBox(width: 8),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(Get.context!).size.width * 0.7),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar('User'),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String label) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.surfaceLight,
      child: Text(
        label.substring(0, 2).toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputBar(TextEditingController ctrl, AiController aiCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'คุยกับ เอไอ....',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  aiCtrl.sendMessage(v.trim());
                  ctrl.clear();
                }
              },
            ),
          ),
          IconButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                aiCtrl.sendMessage(ctrl.text.trim());
                ctrl.clear();
              }
            },
            icon: const Icon(Icons.send, color: AppTheme.accentPrimary),
          ),
        ],
      ),
    );
  }
}

