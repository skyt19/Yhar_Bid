/// lib/models/chat_conversation_model.dart
/// Chat conversation and message models for persistent history

class ChatConversation {
  final String id;
  final String userId;
  final String? title;
  final String personalityLevel; // 'standard', 'advanced', 'executive'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessagePreview;

  const ChatConversation({
    required this.id,
    required this.userId,
    this.title,
    required this.personalityLevel,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      personalityLevel: json['personality_level'] as String? ?? 'standard',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessagePreview: json['last_message_preview'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (title != null) 'title': title,
      'personality_level': personalityLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
