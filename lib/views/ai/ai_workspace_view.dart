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
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF4FD1C5)]), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text('AI Workspace', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
                const Spacer(),
                IconButton(onPressed: () => aiCtrl.clearChat(), icon: const Icon(Icons.delete_sweep, color: Color(0xFF94A3B8)), tooltip: 'Clear Chat'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _buildQuickChip('สรุปกำหนดการวันนี้', aiCtrl, messageCtrl),
              _buildQuickChip('ช่วยจัดตารางอ่านหนังสือสอบ', aiCtrl, messageCtrl),
              _buildQuickChip('วิเคราะห์งานด่วนสัปดาห์นี้', aiCtrl, messageCtrl),
              _buildQuickChip('สร้าง Checklist ด่วน', aiCtrl, messageCtrl),
            ]),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))),
                child: Obx(() => _buildChatHistory(aiCtrl)),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputBar(messageCtrl, aiCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, AiController aiCtrl, TextEditingController ctrl) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      backgroundColor: const Color(0xFF334155),
      labelStyle: const TextStyle(color: Color(0xFFF8FAFC)),
      onPressed: () { ctrl.text = label; aiCtrl.sendMessage(label); },
    );
  }

  Widget _buildChatHistory(AiController aiCtrl) {
    if (aiCtrl.chatMessages.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, color: Color(0xFF64748B), size: 64), SizedBox(height: 16), Text('Start a conversation with AI', style: TextStyle(color: Color(0xFF64748B), fontSize: 16))]));
    }
    return ListView.builder(itemCount: aiCtrl.chatMessages.length, itemBuilder: (context, index) {
      final msg = aiCtrl.chatMessages[index];
      return _buildMessageBubble(msg['role'] == 'user', msg['content'] ?? '', aiCtrl);
    });
  }



  Widget _buildMessageBubble(bool isUser, String content, AiController aiCtrl) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(color: isUser ? const Color(0xFF38BDF8) : const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(color: Colors.white, fontSize: 14)),
            if (!isUser && _containsDateInfo(content)) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _saveToCalendar(content),
                icon: const Icon(Icons.event, size: 16),
                label: const Text('Save to Calendar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FD1C5), foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _containsDateInfo(String content) => content.contains(RegExp(r'\d{1,2}/\d{1,2}')) || content.contains('tomorrow') || content.contains('today') || content.contains('วันนี้') || content.contains('พรุ่งนี้');

  void _saveToCalendar(String aiResponse) => Get.snackbar('Calendar Action', 'Parsing AI response...', snackPosition: SnackPosition.BOTTOM);

  Widget _buildInputBar(TextEditingController ctrl, AiController aiCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Row(
        children: [
          Expanded(child: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Ask me anything...', hintStyle: TextStyle(color: Color(0xFF64748B)), border: InputBorder.none), onSubmitted: (v) { if (v.trim().isNotEmpty) { aiCtrl.sendMessage(v.trim()); ctrl.clear(); } })),
          IconButton(onPressed: () { if (ctrl.text.trim().isNotEmpty) { aiCtrl.sendMessage(ctrl.text.trim()); ctrl.clear(); } }, icon: const Icon(Icons.send, color: Color(0xFF38BDF8))),
        ],
      ),
    );
  }
}
