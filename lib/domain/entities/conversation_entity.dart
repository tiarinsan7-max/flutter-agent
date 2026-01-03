/// Conversation entity representing a single conversation
class ConversationEntity {
  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Message entity representing a single message
class MessageEntity {
  final String id;
  final String content;
  final String role; // user, assistant, system
  final DateTime timestamp;

  MessageEntity({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });
}
