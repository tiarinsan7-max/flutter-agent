import '../entities/conversation_entity.dart';
import '../repositories/conversation_repository_interface.dart';

/// Use case to create a new conversation
class CreateConversationUseCase {
  final IConversationRepository repository;

  CreateConversationUseCase(this.repository);

  Future<ConversationEntity> call(String title, String category) {
    return repository.createConversation(title, category);
  }
}
