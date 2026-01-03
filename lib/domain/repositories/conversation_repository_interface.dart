import '../entities/conversation_entity.dart';

/// Abstract repository interface for conversations
abstract class IConversationRepository {
  /// Create a new conversation
  Future<ConversationEntity> createConversation(
    String title,
    String category,
  );

  /// Get conversation by ID
  Future<ConversationEntity?> getConversation(String id);

  /// Get all conversations
  Future<List<ConversationEntity>> getAllConversations();

  /// Update conversation
  Future<void> updateConversation(ConversationEntity conversation);

  /// Delete conversation
  Future<void> deleteConversation(String id);

  /// Search conversations
  Future<List<ConversationEntity>> searchConversations(String query);
}
