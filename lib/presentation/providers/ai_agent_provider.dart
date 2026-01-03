import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/datasources/ollama_service.dart';
import '../../data/datasources/storage_service.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/ollama_response_model.dart';
import '../../data/repositories/conversation_repository.dart';

class AIAgentProvider extends ChangeNotifier {
  final OllamaService ollamaService;
  final StorageService storageService;
  final ConversationRepository conversationRepository;
  final Logger _logger = Logger();

  List<OllamaModelInfo> availableModels = [];
  bool isLoading = false;
  bool isConnected = false;
  String? errorMessage;
  String currentModel = 'mistral';

  String get baseUrl => ollamaService.baseUrl;

  AIAgentProvider(
    this.ollamaService,
    this.storageService,
    this.conversationRepository,
  );

  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();

      // Initialize storage
      await storageService.initialize();

      // Initialize conversation repository
      await conversationRepository.initialize();

      // Check connection
      isConnected = await ollamaService.healthCheck();

      if (isConnected) {
        availableModels = await ollamaService.getAvailableModels();
        if (availableModels.isNotEmpty) {
          currentModel = availableModels.first.name;
          ollamaService.setModel(currentModel);
        }
      } else {
        errorMessage = 'Failed to connect to Ollama';
      }

      _logger.i('AI Agent initialized. Connected: $isConnected');
    } catch (e) {
      errorMessage = 'Initialization error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkConnection() async {
    try {
      isConnected = await ollamaService.healthCheck();
      if (!isConnected) {
        errorMessage = 'Connection to Ollama lost';
      }
      notifyListeners();
      return isConnected;
    } catch (e) {
      errorMessage = 'Connection check error: $e';
      _logger.e(errorMessage);
      isConnected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshModels() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      availableModels = await ollamaService.getAvailableModels();
      _logger.i('Models refreshed: ${availableModels.length} available');
    } catch (e) {
      errorMessage = 'Failed to refresh models: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setModel(String model) {
    try {
      currentModel = model;
      ollamaService.setModel(model);
      errorMessage = null;
      _logger.i('Model set to: $model');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to set model: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  void setOllamaUrl(String url) {
    try {
      ollamaService.setBaseUrl(url);
      errorMessage = null;
      _logger.i('Ollama URL set to: $url');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to set Ollama URL: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> pullModel(String modelName) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final success = await ollamaService.pullModel(modelName);
      if (success) {
        await refreshModels();
        _logger.i('Model pulled: $modelName');
      } else {
        errorMessage = 'Failed to pull model';
      }
    } catch (e) {
      errorMessage = 'Pull model error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteModel(String modelName) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final success = await ollamaService.deleteModel(modelName);
      if (success) {
        await refreshModels();
        _logger.i('Model deleted: $modelName');
      } else {
        errorMessage = 'Failed to delete model';
      }
    } catch (e) {
      errorMessage = 'Delete model error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<List<double>>> generateEmbeddings(String text) async {
    try {
      final response = await ollamaService.generateEmbeddings(text: text);
      return response.embeddings;
    } catch (e) {
      errorMessage = 'Embedding generation error: $e';
      _logger.e(errorMessage);
      return [];
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
