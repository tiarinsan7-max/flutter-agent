import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TaskCategory category;

  @HiveField(4)
  final TaskStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? dueDate;

  @HiveField(7)
  final List<String> attachments; // File paths

  @HiveField(8)
  final Map<String, dynamic> metadata;

  @HiveField(9)
  final String? result;

  @HiveField(10)
  final String? conversationId; // Link to conversation if needed

  TaskModel({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    TaskStatus? status,
    DateTime? createdAt,
    this.dueDate,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    this.result,
    this.conversationId,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? TaskStatus.pending,
        createdAt = createdAt ?? DateTime.now(),
        attachments = attachments ?? [],
        metadata = metadata ?? {};

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? result,
    String? conversationId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      result: result ?? this.result,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

@HiveType(typeId: 4)
enum TaskCategory {
  @HiveField(0)
  photography,
  @HiveField(1)
  documentation,
  @HiveField(2)
  prompting,
  @HiveField(3)
  analysis,
  @HiveField(4)
  writing,
  @HiveField(5)
  translation,
  @HiveField(6)
  research,
}

@HiveType(typeId: 5)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,
  @HiveField(4)
  cancelled,
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    return toString().split('.').last.toUpperCase();
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    return toString().split('.').last;
  }

  bool get isTerminal => this == TaskStatus.completed || 
                         this == TaskStatus.failed || 
                         this == TaskStatus.cancelled;
}
