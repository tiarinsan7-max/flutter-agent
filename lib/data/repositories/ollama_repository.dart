import 'package:logger/logger.dart';
import '../datasources/ollama_service.dart';
import '../models/ollama_response_model.dart';

class OllamaRepository {
  final OllamaService ollamaService;
  final Logger _logger = Logger();

  OllamaRepository({required this.ollamaService});

  Future<bool> checkHealth() async {
    try {
      return await ollamaService.healthCheck();
    } catch (e) {
      _logger.e('Health check error: $e');
      return false;
    }
  }

  Future<List<OllamaModelInfo>> fetchAvailableModels() async {
    try {
      return await ollamaService.getAvailableModels();
    } catch (e) {
      _logger.e('Fetch models error: $e');
      return [];
    }
  }

  Stream<String> generateResponseStream({
    required String prompt,
    String? model,
  }) async* {
    try {
      await for (final response in ollamaService.generateWithStreaming(
        prompt: prompt,
        model: model,
      )) {
        yield response.response;
      }
    } catch (e) {
      _logger.e('Generate stream error: $e');
      rethrow;
    }
  }

  Future<String> generateResponse({
    required String prompt,
    String? model,
  }) async {
    try {
      final response = await ollamaService.generate(prompt: prompt, model: model);
      return response.response;
    } catch (e) {
      _logger.e('Generate response error: $e');
      rethrow;
    }
  }

  Future<List<List<double>>> generateEmbeddings({
    required String text,
    String? model,
  }) async {
    try {
      final response = await ollamaService.generateEmbeddings(text: text, model: model);
      return response.embeddings;
    } catch (e) {
      _logger.e('Generate embeddings error: $e');
      return [];
    }
  }

  Future<bool> pullModel(String modelName) async {
    try {
      return await ollamaService.pullModel(modelName);
    } catch (e) {
      _logger.e('Pull model error: $e');
      return false;
    }
  }

  Future<bool> deleteModel(String modelName) async {
    try {
      return await ollamaService.deleteModel(modelName);
    } catch (e) {
      _logger.e('Delete model error: $e');
      return false;
    }
  }

  void setModel(String model) {
    ollamaService.setModel(model);
  }

  void setBaseUrl(String url) {
    ollamaService.setBaseUrl(url);
  }

  String get activeModel => ollamaService.activeModel;
  String get baseUrl => ollamaService.baseUrl;
}
