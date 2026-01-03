import 'package:dio/dio.dart';

/// Remote data source for Ollama API
class OllamaApi {
  final Dio dio;
  final String baseUrl;

  OllamaApi({required this.dio, required this.baseUrl});

  /// Get available models
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    try {
      final response = await dio.get('$baseUrl/api/tags');
      return List<Map<String, dynamic>>.from(response.data['models']);
    } catch (e) {
      rethrow;
    }
  }

  /// Generate text response
  Future<String> generateResponse(String prompt, String model) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/generate',
        data: {
          'model': model,
          'prompt': prompt,
          'stream': false,
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }
}
