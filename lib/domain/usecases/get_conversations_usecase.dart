import '../entities/conversation_entity.dart';
import '../repositories/conversation_repository_interface.dart';

/// Use case to get all conversations
class GetConversationsUseCase {
  final IConversationRepository repository;

  GetConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call() {
    return repository.getAllConversations();
  }
}
