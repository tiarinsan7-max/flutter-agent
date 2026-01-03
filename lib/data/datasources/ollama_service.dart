import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/ollama_response_model.dart';
import '../../core/constants/app_constants.dart';

class OllamaService {
  final Dio dio;
  final Logger _logger = Logger();

  String _baseUrl = AppConstants.ollamaBaseUrl;
  String _selectedModel = AppConstants.defaultOllamaModel;

  OllamaService({required this.dio}) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: AppConstants.ollamaTimeout,
      receiveTimeout: AppConstants.ollamaTimeout,
      contentType: 'application/json',
    );
  }

  // Set custom Ollama server URL
  void setBaseUrl(String url) {
    _baseUrl = url;
    _configureDio();
    _logger.i('Ollama base URL set to: $_baseUrl');
  }

  // Set active model
  void setModel(String model) {
    _selectedModel = model;
    _logger.i('Active model set to: $_selectedModel');
  }

  String get activeModel => _selectedModel;
  String get baseUrl => _baseUrl;

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await dio.get('/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }

  // Get available models
  Future<List<OllamaModelInfo>> getAvailableModels() async {
    try {
      final response = await dio.get('/api/tags');
      if (response.statusCode == 200) {
        final models = (response.data['models'] as List<dynamic>)
            .map((m) => OllamaModelInfo.fromJson(m))
            .toList();
        _logger.i('Available models: ${models.map((m) => m.name).join(", ")}');
        return models;
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get available models: $e');
      return [];
    }
  }

  // Generate response with streaming
  Stream<OllamaResponseModel> generateWithStreaming({
    required String prompt,
    String? model,
    bool stream = true,
  }) async* {
    try {
      final modelToUse = model ?? _selectedModel;
      _logger.i('Generating response with model: $modelToUse');

      final response = await dio.post(
        '/api/generate',
        data: {
          'model': modelToUse,
          'prompt': prompt,
          'stream': stream,
          'temperature': AppConstants.temperature,
          'top_p': AppConstants.topP,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        await for (final line
            in response.data.stream.transform(StreamTransformer.fromHandlers(
          handleData: (dynamic data, EventSink<String> sink) {
            final chunk = data as List<int>;
            sink.add(String.fromCharCodes(chunk));
          },
        ))) {
          if (line.isNotEmpty && line.trim().isNotEmpty) {
            try {
              final Map<String, dynamic> json = _parseJsonStream(line);
              yield OllamaResponseModel.fromJson(json);
            } catch (e) {
              _logger.d('Failed to parse JSON line: $line');
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Stream generation error: $e');
      rethrow;
    }
  }

  // Generate response without streaming
  Future<OllamaResponseModel> generate({
    required String prompt,
    String? model,
  }) async {
    try {
      final modelToUse = model ?? _selectedModel;
      _logger.i('Generating response with model: $modelToUse');

      final response = await dio.post(
        '/api/generate',
        data: {
          'model': modelToUse,
          'prompt': prompt,
          'stream': false,
          'temperature': AppConstants.temperature,
          'top_p': AppConstants.topP,
        },
      );

      if (response.statusCode == 200) {
        return OllamaResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to generate response');
      }
    } catch (e) {
      _logger.e('Generation error: $e');
      rethrow;
    }
  }

  // Generate embeddings
  Future<OllamaEmbeddingResponse> generateEmbeddings({
    required String text,
    String? model,
  }) async {
    try {
      final modelToUse = model ?? _selectedModel;
      _logger.i('Generating embeddings with model: $modelToUse');

      final response = await dio.post(
        '/api/embeddings',
        data: {
          'model': modelToUse,
          'prompt': text,
        },
      );

      if (response.statusCode == 200) {
        return OllamaEmbeddingResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to generate embeddings');
      }
    } catch (e) {
      _logger.e('Embedding generation error: $e');
      rethrow;
    }
  }

  // Pull model
  Future<bool> pullModel(String modelName) async {
    try {
      _logger.i('Pulling model: $modelName');
      final response = await dio.post(
        '/api/pull',
        data: {'name': modelName},
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to pull model: $e');
      return false;
    }
  }

  // Delete model
  Future<bool> deleteModel(String modelName) async {
    try {
      _logger.i('Deleting model: $modelName');
      final response = await dio.delete(
        '/api/delete',
        data: {'name': modelName},
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to delete model: $e');
      return false;
    }
  }

  // Helper method to parse JSON from streaming response
  Map<String, dynamic> _parseJsonStream(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Invalid JSON format: $trimmed');
    }
    final decoded = jsonDecode(trimmed);
    return Map<String, dynamic>.from(decoded as Map);
  }
}
