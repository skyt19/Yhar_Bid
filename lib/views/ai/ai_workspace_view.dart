import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';

class AIWorkspaceView extends StatelessWidget {
  const AIWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    final aiCtrl = Get.put(AiController());
    final messageCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFCFD8DC),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
          'เริ่มสนทนา...',
          style: TextStyle(
            color: Color(0xFF757575),
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
            _buildAvatar('AI'),
            const SizedBox(width: 8),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(Get.context!).size.width * 0.7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.black,
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
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label == 'User' ? 'User' : 'AI จริ้วส',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInputBar(TextEditingController ctrl, AiController aiCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32), // มุมโค้งมน 32px ตาม Mockup
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'คุยกับ เอไอ....',
                hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  aiCtrl.sendMessage(v.trim());
                  ctrl.clear();
                }
              },
            ),
          ),
          // ซ่อนปุ่ม Send Icon ตาม Mockup (รูปไม่มีไอคอนส่ง)
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
