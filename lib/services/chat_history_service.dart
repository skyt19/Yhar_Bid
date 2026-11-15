/// lib/services/chat_history_service.dart
/// Chat History Service - Persistent storage via Supabase
/// SECURITY: Routes all operations through chat-db Edge Function with RS256 JWT verification

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_conversation_model.dart';

class ChatHistoryService {
  static const String _supabaseUrl = 'https://aanochhlejpbhdhkgjpx.supabase.co';
  static const String _chatDbEndpoint = '/functions/v1/chat-db';
  static const Duration _timeout = Duration(seconds: 30);

  /// Get authenticated headers with Firebase ID token
  /// Token is verified server-side by chat-db Edge Function using RS256
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
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Create a new conversation via secure Edge Function
  Future<ChatConversation> createConversation({
    String? title,
    String personalityLevel = 'standard',
  }) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'create_conversation',
            'title': title,
            'personalityLevel': personalityLevel,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      return ChatConversation.fromJson(data);
    }

    throw Exception('Failed to create conversation: ${response.statusCode} - ${response.body}');
  }

  /// Get all conversations for current user via secure Edge Function
  Future<List<ChatConversation>> getConversations({
    int limit = 50,
  }) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'list_conversations',
            'limit': limit,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> conversations = json['data'] as List<dynamic>;
      return conversations.map((item) => ChatConversation.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to get conversations: ${response.statusCode} - ${response.body}');
  }

  /// Get messages for a conversation via secure Edge Function
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'get_messages',
            'conversationId': conversationId,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> messages = json['data'] as List<dynamic>;
      return messages.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to get messages: ${response.statusCode} - ${response.body}');
  }

  /// Add message to conversation via secure Edge Function
  Future<ChatMessage> addMessage({
    required String conversationId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'add_message',
            'conversationId': conversationId,
            'role': role,
            'content': content,
            if (metadata != null) 'metadata': metadata,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    }

    throw Exception('Failed to add message: ${response.statusCode} - ${response.body}');
  }

  /// Delete conversation via secure Edge Function
  Future<void> deleteConversation(String conversationId) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'delete_conversation',
            'conversationId': conversationId,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation: ${response.statusCode} - ${response.body}');
    }
  }

  /// Update conversation title via secure Edge Function
  Future<void> updateConversationTitle(String conversationId, String title) async {
    final headers = await _getHeaders();

    final response = await http
        .post(
          Uri.parse('$_supabaseUrl$_chatDbEndpoint'),
          headers: headers,
          body: jsonEncode({
            'operation': 'update_conversation',
            'conversationId': conversationId,
            'title': title,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update conversation: ${response.statusCode} - ${response.body}');
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
