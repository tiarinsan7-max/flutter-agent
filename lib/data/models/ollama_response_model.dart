class OllamaResponseModel {
  final String model;
  final String response;
  final bool done;
  final int totalDuration;
  final int loadDuration;
  final int promptEvalCount;
  final int promptEvalDuration;
  final int evalCount;
  final int evalDuration;

  OllamaResponseModel({
    required this.model,
    required this.response,
    required this.done,
    required this.totalDuration,
    required this.loadDuration,
    required this.promptEvalCount,
    required this.promptEvalDuration,
    required this.evalCount,
    required this.evalDuration,
  });

  factory OllamaResponseModel.fromJson(Map<String, dynamic> json) {
    return OllamaResponseModel(
      model: json['model'] ?? '',
      response: json['response'] ?? '',
      done: json['done'] ?? false,
      totalDuration: json['total_duration'] ?? 0,
      loadDuration: json['load_duration'] ?? 0,
      promptEvalCount: json['prompt_eval_count'] ?? 0,
      promptEvalDuration: json['prompt_eval_duration'] ?? 0,
      evalCount: json['eval_count'] ?? 0,
      evalDuration: json['eval_duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'response': response,
      'done': done,
      'total_duration': totalDuration,
      'load_duration': loadDuration,
      'prompt_eval_count': promptEvalCount,
      'prompt_eval_duration': promptEvalDuration,
      'eval_count': evalCount,
      'eval_duration': evalDuration,
    };
  }
}

class OllamaModelInfo {
  final String name;
  final String size;
  final String digest;
  final DateTime modifiedAt;

  OllamaModelInfo({
    required this.name,
    required this.size,
    required this.digest,
    required this.modifiedAt,
  });

  factory OllamaModelInfo.fromJson(Map<String, dynamic> json) {
    return OllamaModelInfo(
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      digest: json['digest'] ?? '',
      modifiedAt: DateTime.parse(json['modified_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'digest': digest,
      'modified_at': modifiedAt.toIso8601String(),
    };
  }
}

class OllamaEmbeddingResponse {
  final List<List<double>> embeddings;

  OllamaEmbeddingResponse({required this.embeddings});

  factory OllamaEmbeddingResponse.fromJson(Map<String, dynamic> json) {
    return OllamaEmbeddingResponse(
      embeddings: List<List<double>>.from(
        (json['embeddings'] as List<dynamic>).map(
          (e) => List<double>.from((e as List<dynamic>).map((v) => (v as num).toDouble())),
        ),
      ),
    );
  }
}
