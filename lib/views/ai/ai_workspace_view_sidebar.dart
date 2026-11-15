/// lib/views/ai/ai_workspace_view_sidebar.dart
/// Chat History Sidebar Components for AI Workspace
/// Phase 4: Persistent conversation history UI integration

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/ai_controller.dart';
import '../../models/chat_conversation_model.dart';
import '../theme/app_theme.dart';

class AIWorkspaceSidebarBuilder {
  /// Desktop: Persistent sidebar
  static Widget buildSidebar(AiController aiCtrl) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (aiCtrl.isLoadingConversations.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final conversations = aiCtrl.conversations;

              if (conversations.isEmpty) {
                return _buildEmptyState();
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

  /// Mobile: Drawer
  static Widget buildDrawer(AiController aiCtrl) {
    return Drawer(
      child: Container(
        color: AppTheme.surfaceLight,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (aiCtrl.isLoadingConversations.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final conversations = aiCtrl.conversations;

                if (conversations.isEmpty) {
                  return _buildEmptyState();
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
      ),
    );
  }

  static Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.chat_bubble_outline, size: 20, color: AppTheme.accentGreen),
          SizedBox(width: 12),
          Text(
            'Chat History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState() {
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

  static Widget _buildConversationTile(
    AiController aiCtrl,
    ChatConversation conversation,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        aiCtrl.selectConversation(conversation.id);
        // Close drawer on mobile
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen.withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.accentGreen : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title ?? 'New Conversation',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (conversation.lastMessagePreview != null && conversation.lastMessagePreview!.isNotEmpty)
                    Text(
                      conversation.lastMessagePreview!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(conversation.updatedAt),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showDeleteDialog(aiCtrl, conversation),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  static void _showDeleteDialog(AiController aiCtrl, ChatConversation conversation) {
    if (Get.context == null) return;

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text('This will permanently delete this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              aiCtrl.deleteConversation(conversation.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
