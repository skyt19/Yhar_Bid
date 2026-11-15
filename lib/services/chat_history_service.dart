/// lib/services/chat_history_service.dart
/// Chat History Service - Persistent storage via Supabase
/// Phase 4: Conversation and message management

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_conversation_model.dart';
import '../core/config/app_config.dart';

class ChatHistoryService {
  static const String _supabaseUrl = 'https://aanochhlejpbhdhkgjpx.supabase.co';
  static const String _conversationsEndpoint = '/rest/v1/conversations';
  static const String _messagesEndpoint = '/rest/v1/messages';

  /// Get authenticated headers with Firebase ID token
  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null) {
      throw Exception('Failed to get ID token');
    }

    return {
      'Content-Type': 'application/json',
      'apikey': AppConfig.supabasePublishableKey,
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Create a new conversation
  Future<ChatConversation> createConversation({
    String? title,
    String personalityLevel = 'standard',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_supabaseUrl$_conversationsEndpoint'),
      headers: headers,
      body: jsonEncode({
        'user_id': user.uid,
        'title': title,
        'personality_level': personalityLevel,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return ChatConversation.fromJson(json[0] as Map<String, dynamic>);
    }

    throw Exception('Failed to create conversation: ${response.statusCode}');
  }

  /// Get all conversations for current user
  Future<List<ChatConversation>> getConversations({
    int limit = 50,
  }) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_supabaseUrl$_conversationsEndpoint?order=updated_at.desc&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => ChatConversation.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to get conversations: ${response.statusCode}');
  }

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_supabaseUrl$_messagesEndpoint?conversation_id=eq.$conversationId&order=created_at.asc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to get messages: ${response.statusCode}');
  }

  /// Add a message to a conversation
  Future<ChatMessage> addMessage({
    required String conversationId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_supabaseUrl$_messagesEndpoint'),
      headers: headers,
      body: jsonEncode({
        'conversation_id': conversationId,
        'role': role,
        'content': content,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as List<dynamic>;

      // Update conversation updated_at
      await _updateConversationTimestamp(conversationId);

      return ChatMessage.fromJson(json[0] as Map<String, dynamic>);
    }

    throw Exception('Failed to add message: ${response.statusCode}');
  }

  /// Update conversation updated_at timestamp
  Future<void> _updateConversationTimestamp(String conversationId) async {
    final headers = await _getHeaders();

    await http.patch(
      Uri.parse('$_supabaseUrl$_conversationsEndpoint?id=eq.$conversationId'),
      headers: headers,
      body: jsonEncode({
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  /// Update conversation title
  Future<void> updateConversationTitle(String conversationId, String title) async {
    final headers = await _getHeaders();

    final response = await http.patch(
      Uri.parse('$_supabaseUrl$_conversationsEndpoint?id=eq.$conversationId'),
      headers: headers,
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to update conversation: ${response.statusCode}');
    }
  }

  /// Delete a conversation and its messages
  Future<void> deleteConversation(String conversationId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$_supabaseUrl$_conversationsEndpoint?id=eq.$conversationId'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete conversation: ${response.statusCode}');
    }
  }

  /// Generate conversation title from first message
  String generateTitle(String firstMessage, {int maxLength = 50}) {
    final cleaned = firstMessage.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= maxLength) {
      return cleaned;
    }
    return '${cleaned.substring(0, maxLength)}...';
  }
}
