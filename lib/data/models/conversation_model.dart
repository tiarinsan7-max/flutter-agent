import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 0)
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<MessageModel> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final String category; // Photography, Documentation, Prompting, etc.

  @HiveField(6)
  final Map<String, dynamic> metadata;

  ConversationModel({
    String? id,
    required this.title,
    required this.messages,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        metadata = metadata ?? {};

  ConversationModel copyWith({
    String? id,
    String? title,
    List<MessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}

@HiveType(typeId: 1)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final MessageRole role;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final List<String>? attachments; // File paths

  @HiveField(5)
  final Map<String, dynamic>? metadata;

  MessageModel({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.attachments,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

@HiveType(typeId: 2)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}
