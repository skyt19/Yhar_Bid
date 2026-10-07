/// lib/views/ai_chatbot_view.dart
/// [Mockup 4] — AI Chatbot
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_controller.dart';
import 'theme/app_theme.dart';

class AiChatbotView extends StatefulWidget {
  const AiChatbotView({super.key});
  @override
  State<AiChatbotView> createState() => _AiChatbotViewState();
}

class _AiChatbotViewState extends State<AiChatbotView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AiController aiCtrl = Get.find<AiController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('AI จสวีส', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusMedium), topRight: Radius.circular(AppTheme.radiusMedium)),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Obx(() {
                  final List<Map<String, String>> messages = aiCtrl.chatMessages;
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('เอไอจะถือและสร้างหัวข้อที่คุณต้องการหรือสิ่งทำในเวลา\n\nเริ่มสนทนาเพื่อรับคำแนะนำจาก AI',
                          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary), textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      final bool isUser = messages[i]['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.accentPrimary.withOpacity(0.12) : AppTheme.cardLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Text(messages[i]['content']!, style: const TextStyle(fontSize: 15, height: 1.4)),
                        ),
                      );
                    },
                  );
                }),
              ),
              Obx(() => aiCtrl.isTyping.value
                  ? const Padding(padding: EdgeInsets.all(12), child: Text('AI กำลังพิมพ์...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)))
                  : const SizedBox.shrink()),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: AppTheme.backgroundLight),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'คุยกับ เอไอ...',
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        if (_textController.text.trim().isEmpty) return;
                        final String msg = _textController.text;
                        _textController.clear();
                        await aiCtrl.sendMessage(msg);
                        Future<void>.delayed(const Duration(milliseconds: 300), () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(color: AppTheme.accentPrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.send, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
