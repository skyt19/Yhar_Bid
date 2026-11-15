/// lib/views/ai/ai_chat_with_history_view.dart
/// Enhanced AI Chat with Persistent History Sidebar
/// Phase 4: Conversation history UI implementation

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';
import '../../models/chat_conversation_model.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AiChatWithHistoryView extends StatefulWidget {
  const AiChatWithHistoryView({super.key});

  @override
  State<AiChatWithHistoryView> createState() => _AiChatWithHistoryViewState();
}

class _AiChatWithHistoryViewState extends State<AiChatWithHistoryView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    final aiCtrl = Get.find<AiController>();
    aiCtrl.loadConversations();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AiController aiCtrl = Get.find<AiController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('AI Assistance', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        actions: [
          if (!showSidebar)
            IconButton(
              icon: Icon(_showHistory ? Icons.close : Icons.history),
              onPressed: () => setState(() => _showHistory = !_showHistory),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => aiCtrl.startNewConversation(),
            tooltip: 'New Conversation',
          ),
        ],
      ),
      body: Row(
        children: [
          // Conversation History Sidebar
          if (showSidebar || _showHistory)
            _buildHistorySidebar(aiCtrl, showSidebar),

          // Main Chat Area
          Expanded(
            child: _buildChatArea(aiCtrl),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySidebar(AiController aiCtrl, bool permanent) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(
          right: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.textSecondary.withOpacity(0.1)),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'Conversations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (aiCtrl.isLoadingConversations.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final conversations = aiCtrl.conversations;

              if (conversations.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No conversations yet.\nStart chatting to create one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final isSelected = aiCtrl.currentConversation.value?.id == conv.id;

                  return _buildConversationTile(aiCtrl, conv, isSelected);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    AiController aiCtrl,
    ChatConversation conversation,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        aiCtrl.loadConversation(conversation.id);
        if (!mounted) return;
        setState(() => _showHistory = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen.withOpacity(0.1) : null,
          border: Border(
            bottom: BorderSide(color: AppTheme.textSecondary.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(conversation.updatedAt),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(aiCtrl, conversation);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(AiController aiCtrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusMedium),
            topRight: Radius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: Column(
          children: [
            // Quick Prompt Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickPromptChip(aiCtrl, Icons.summarize, 'สรุปงานสัปดาห์นี้', () => aiCtrl.askWeeklySummary()),
                  _buildQuickPromptChip(aiCtrl, Icons.priority_high, 'วิเคราะห์งานด่วน', () => aiCtrl.askUrgentTasks()),
                  _buildQuickPromptChip(aiCtrl, Icons.meeting_room, 'เตรียมประชุม', () => aiCtrl.askMeetingPrep()),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: Obx(() {
                if (aiCtrl.isLoadingMessages.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = aiCtrl.chatMessages;
                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'AI จะช่วยวิเคราะห์งานและให้คำแนะนำ\n\nเริ่มสนทนาเพื่อรับความช่วยเหลือจาก AI',
                        style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final isUser = messages[i]['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppTheme.accentGreen.withOpacity(0.12)
                              : AppTheme.cardLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Text(
                          messages[i]['content']!,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Typing indicator
            Obx(() => aiCtrl.isTyping.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'AI กำลังพิมพ์...',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  )
                : const SizedBox.shrink()),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppTheme.backgroundLight),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'ถามอะไรก็ได้...',
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      if (_textController.text.trim().isEmpty) return;
                      final msg = _textController.text;
                      _textController.clear();
                      await aiCtrl.sendMessage(msg);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPromptChip(
    AiController aiCtrl,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.accentGreen),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  void _confirmDelete(AiController aiCtrl, ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              aiCtrl.deleteConversation(conversation.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
