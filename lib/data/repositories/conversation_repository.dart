import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/conversation_model.dart';
import 'ollama_repository.dart';
import 'storage_repository.dart';

class ConversationRepository {
  final OllamaRepository ollamaRepository;
  final StorageRepository storageRepository;
  final Logger _logger = Logger();
  late Box<ConversationModel> _conversationBox;

  ConversationRepository({
    required this.ollamaRepository,
    required this.storageRepository,
  });

  Future<void> initialize() async {
    try {
      _conversationBox = await Hive.openBox<ConversationModel>('conversations');
      _logger.i('Conversation repository initialized');
    } catch (e) {
      _logger.e('Initialize conversation repository error: $e');
      rethrow;
    }
  }

  // Create conversation
  Future<ConversationModel> createConversation({
    required String title,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final conversation = ConversationModel(
        title: title,
        messages: [],
        category: category,
        metadata: metadata ?? {},
      );
      
      await _conversationBox.put(conversation.id, conversation);
      _logger.i('Conversation created: ${conversation.id}');
      return conversation;
    } catch (e) {
      _logger.e('Create conversation error: $e');
      rethrow;
    }
  }

  // Get conversation
  Future<ConversationModel?> getConversation(String id) async {
    try {
      return _conversationBox.get(id);
    } catch (e) {
      _logger.e('Get conversation error: $e');
      return null;
    }
  }

  // Get all conversations
  Future<List<ConversationModel>> getAllConversations() async {
    try {
      return _conversationBox.values.toList().reversed.toList();
    } catch (e) {
      _logger.e('Get all conversations error: $e');
      return [];
    }
  }

  // Get conversations by category
  Future<List<ConversationModel>> getConversationsByCategory(String category) async {
    try {
      final all = await getAllConversations();
      return all.where((c) => c.category == category).toList();
    } catch (e) {
      _logger.e('Get conversations by category error: $e');
      return [];
    }
  }

  // Add message to conversation
  Future<ConversationModel> addMessage({
    required String conversationId,
    required String content,
    required MessageRole role,
    List<String>? attachments,
  }) async {
    try {
      final conversation = await getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found');
      }

      final message = MessageModel(
        content: content,
        role: role,
        attachments: attachments,
      );

      final updatedMessages = [...conversation.messages, message];
      final updated = conversation.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      await _conversationBox.put(conversationId, updated);
      _logger.i('Message added to conversation: $conversationId');
      return updated;
    } catch (e) {
      _logger.e('Add message error: $e');
      rethrow;
    }
  }

  // Generate AI response
  Future<String> generateAIResponse({
    required String conversationId,
    required String userMessage,
    String? model,
  }) async {
    try {
      final conversation = await getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found');
      }

      // Build context from previous messages
      final context = conversation.messages
          .map((m) => '${m.role.toString().split('.').last}: ${m.content}')
          .join('\n');

      final fullPrompt = '$context\nuser: $userMessage';

      // Generate response
      final response = await ollamaRepository.generateResponse(
        prompt: fullPrompt,
        model: model,
      );

      return response;
    } catch (e) {
      _logger.e('Generate AI response error: $e');
      rethrow;
    }
  }

  // Generate AI response with streaming
  Stream<String> generateAIResponseStream({
    required String conversationId,
    required String userMessage,
    String? model,
  }) async* {
    try {
      final conversation = await getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found');
      }

      // Build context
      final context = conversation.messages
          .map((m) => '${m.role.toString().split('.').last}: ${m.content}')
          .join('\n');

      final fullPrompt = '$context\nuser: $userMessage';

      // Generate stream
      await for (final response in ollamaRepository.generateResponseStream(
        prompt: fullPrompt,
        model: model,
      )) {
        yield response;
      }
    } catch (e) {
      _logger.e('Generate stream error: $e');
      rethrow;
    }
  }

  // Update conversation
  Future<void> updateConversation(ConversationModel conversation) async {
    try {
      await _conversationBox.put(conversation.id, conversation);
      _logger.i('Conversation updated: ${conversation.id}');
    } catch (e) {
      _logger.e('Update conversation error: $e');
      rethrow;
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String id) async {
    try {
      await _conversationBox.delete(id);
      await storageRepository.deleteFile('${storageRepository.appDirectory.path}/$id.json');
      _logger.i('Conversation deleted: $id');
    } catch (e) {
      _logger.e('Delete conversation error: $e');
      rethrow;
    }
  }

  // Search conversations
  Future<List<ConversationModel>> searchConversations(String query) async {
    try {
      final all = await getAllConversations();
      final lowerQuery = query.toLowerCase();
      return all
          .where((c) => c.title.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      _logger.e('Search conversations error: $e');
      return [];
    }
  }

  // Export conversation
  Future<String?> exportConversation(String conversationId, String title) async {
    try {
      final conversation = await getConversation(conversationId);
      if (conversation == null) return null;

      final jsonString = jsonEncode({
        'id': conversation.id,
        'title': conversation.title,
        'category': conversation.category,
        'createdAt': conversation.createdAt.toIso8601String(),
        'messages': conversation.messages.map((m) => {
          'id': m.id,
          'role': m.role.toString().split('.').last,
          'content': m.content,
          'timestamp': m.timestamp.toIso8601String(),
        }).toList(),
      });

      final file = await storageRepository.exportConversation(conversationId, title);
      return file?.path;
    } catch (e) {
      _logger.e('Export conversation error: $e');
      return null;
    }
  }

  // Clear old conversations (keep only recent N)
  Future<void> clearOldConversations({int keepCount = 20}) async {
    try {
      final all = await getAllConversations();
      if (all.length > keepCount) {
        final toDelete = all.skip(keepCount).toList();
        for (final conv in toDelete) {
          await deleteConversation(conv.id);
        }
        _logger.i('Cleared ${toDelete.length} old conversations');
      }
    } catch (e) {
      _logger.e('Clear old conversations error: $e');
      rethrow;
    }
  }
}
