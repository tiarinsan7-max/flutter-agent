import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/conversation_repository.dart';

class ConversationProvider extends ChangeNotifier {
  final ConversationRepository conversationRepository;
  final Logger _logger = Logger();

  ConversationModel? activeConversation;
  List<ConversationModel> conversations = [];
  String? currentGeneratingMessage;
  bool isGenerating = false;
  String? errorMessage;

  ConversationProvider(this.conversationRepository);

  Future<void> initialize() async {
    try {
      await conversationRepository.initialize();
      await loadConversations();
      _logger.i('Conversation provider initialized');
    } catch (e) {
      errorMessage = 'Initialization error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> loadConversations() async {
    try {
      conversations = await conversationRepository.getAllConversations();
      _logger.i('Loaded ${conversations.length} conversations');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Load conversations error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> selectConversation(String conversationId) async {
    try {
      activeConversation = await conversationRepository.getConversation(conversationId);
      errorMessage = null;
      _logger.i('Selected conversation: $conversationId');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Select conversation error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<ConversationModel?> createNewConversation({
    required String title,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      errorMessage = null;
      final newConversation = await conversationRepository.createConversation(
        title: title,
        category: category,
        metadata: metadata,
      );
      
      conversations.insert(0, newConversation);
      activeConversation = newConversation;
      
      _logger.i('New conversation created: ${newConversation.id}');
      notifyListeners();
      return newConversation;
    } catch (e) {
      errorMessage = 'Create conversation error: $e';
      _logger.e(errorMessage);
      notifyListeners();
      return null;
    }
  }

  Future<void> sendMessage({
    required String content,
    List<String>? attachments,
  }) async {
    if (activeConversation == null) {
      errorMessage = 'No active conversation';
      _logger.e(errorMessage);
      notifyListeners();
      return;
    }

    try {
      errorMessage = null;
      
      // Add user message
      activeConversation = await conversationRepository.addMessage(
        conversationId: activeConversation!.id,
        content: content,
        role: MessageRole.user,
        attachments: attachments,
      );
      notifyListeners();

      // Generate AI response
      await generateAIResponse(userMessage: content);
    } catch (e) {
      errorMessage = 'Send message error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> generateAIResponse({required String userMessage}) async {
    if (activeConversation == null) {
      errorMessage = 'No active conversation';
      _logger.e(errorMessage);
      notifyListeners();
      return;
    }

    try {
      isGenerating = true;
      currentGeneratingMessage = '';
      errorMessage = null;
      notifyListeners();

      // Stream response
      await for (final chunk in conversationRepository.generateAIResponseStream(
        conversationId: activeConversation!.id,
        userMessage: userMessage,
      )) {
        currentGeneratingMessage = (currentGeneratingMessage ?? '') + chunk;
        notifyListeners();
      }

      // Add complete message
      if (currentGeneratingMessage != null && currentGeneratingMessage!.isNotEmpty) {
        activeConversation = await conversationRepository.addMessage(
          conversationId: activeConversation!.id,
          content: currentGeneratingMessage!,
          role: MessageRole.assistant,
        );
      }

      _logger.i('AI response generated');
    } catch (e) {
      errorMessage = 'Generate response error: $e';
      _logger.e(errorMessage);
    } finally {
      isGenerating = false;
      currentGeneratingMessage = null;
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await conversationRepository.deleteConversation(conversationId);
      conversations.removeWhere((c) => c.id == conversationId);
      
      if (activeConversation?.id == conversationId) {
        activeConversation = null;
      }
      
      _logger.i('Conversation deleted: $conversationId');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Delete conversation error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<List<ConversationModel>> searchConversations(String query) async {
    try {
      return await conversationRepository.searchConversations(query);
    } catch (e) {
      errorMessage = 'Search error: $e';
      _logger.e(errorMessage);
      return [];
    }
  }

  Future<void> updateConversationTitle(String conversationId, String newTitle) async {
    try {
      final conv = await conversationRepository.getConversation(conversationId);
      if (conv != null) {
        final updated = conv.copyWith(title: newTitle);
        await conversationRepository.updateConversation(updated);
        
        final index = conversations.indexWhere((c) => c.id == conversationId);
        if (index >= 0) {
          conversations[index] = updated;
        }
        
        if (activeConversation?.id == conversationId) {
          activeConversation = updated;
        }
        
        _logger.i('Conversation title updated: $conversationId');
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Update title error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<String?> exportConversation(String conversationId, String title) async {
    try {
      return await conversationRepository.exportConversation(conversationId, title);
    } catch (e) {
      errorMessage = 'Export error: $e';
      _logger.e(errorMessage);
      return null;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
