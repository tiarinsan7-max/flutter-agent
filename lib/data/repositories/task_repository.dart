import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/task_model.dart';
import 'storage_repository.dart';

class TaskRepository {
  final StorageRepository storageRepository;
  final Logger _logger = Logger();
  late Box<TaskModel> _taskBox;

  TaskRepository({required this.storageRepository});

  Future<void> initialize() async {
    try {
      _taskBox = await Hive.openBox<TaskModel>('tasks');
      _logger.i('Task repository initialized');
    } catch (e) {
      _logger.e('Initialize task repository error: $e');
      rethrow;
    }
  }

  // Create task
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskCategory category,
    DateTime? dueDate,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? conversationId,
  }) async {
    try {
      final task = TaskModel(
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        attachments: attachments ?? [],
        metadata: metadata ?? {},
        conversationId: conversationId,
      );

      await _taskBox.put(task.id, task);
      _logger.i('Task created: ${task.id}');
      return task;
    } catch (e) {
      _logger.e('Create task error: $e');
      rethrow;
    }
  }

  // Get task
  Future<TaskModel?> getTask(String id) async {
    try {
      return _taskBox.get(id);
    } catch (e) {
      _logger.e('Get task error: $e');
      return null;
    }
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    try {
      return _taskBox.values.toList().reversed.toList();
    } catch (e) {
      _logger.e('Get all tasks error: $e');
      return [];
    }
  }

  // Get tasks by category
  Future<List<TaskModel>> getTasksByCategory(TaskCategory category) async {
    try {
      final all = await getAllTasks();
      return all.where((t) => t.category == category).toList();
    } catch (e) {
      _logger.e('Get tasks by category error: $e');
      return [];
    }
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      final all = await getAllTasks();
      return all.where((t) => t.status == status).toList();
    } catch (e) {
      _logger.e('Get tasks by status error: $e');
      return [];
    }
  }

  // Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      await _taskBox.put(task.id, task);
      _logger.i('Task updated: ${task.id}');
      return task;
    } catch (e) {
      _logger.e('Update task error: $e');
      rethrow;
    }
  }

  // Update task status
  Future<TaskModel> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final task = await getTask(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }

      final updated = task.copyWith(status: status);
      return await updateTask(updated);
    } catch (e) {
      _logger.e('Update task status error: $e');
      rethrow;
    }
  }

  // Add result to task
  Future<TaskModel> addTaskResult(String taskId, String result) async {
    try {
      final task = await getTask(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }

      final updated = task.copyWith(
        result: result,
        status: TaskStatus.completed,
      );
      return await updateTask(updated);
    } catch (e) {
      _logger.e('Add task result error: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      final task = await getTask(id);
      if (task != null) {
        for (final attachment in task.attachments) {
          await storageRepository.deleteFile(attachment);
        }
      }
      await _taskBox.delete(id);
      _logger.i('Task deleted: $id');
    } catch (e) {
      _logger.e('Delete task error: $e');
      rethrow;
    }
  }

  // Search tasks
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final all = await getAllTasks();
      final lowerQuery = query.toLowerCase();
      return all
          .where((t) => t.title.toLowerCase().contains(lowerQuery) ||
              t.description.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      _logger.e('Search tasks error: $e');
      return [];
    }
  }

  // Get pending tasks
  Future<List<TaskModel>> getPendingTasks() async {
    try {
      return await getTasksByStatus(TaskStatus.pending);
    } catch (e) {
      _logger.e('Get pending tasks error: $e');
      return [];
    }
  }

  // Get in-progress tasks
  Future<List<TaskModel>> getInProgressTasks() async {
    try {
      return await getTasksByStatus(TaskStatus.inProgress);
    } catch (e) {
      _logger.e('Get in-progress tasks error: $e');
      return [];
    }
  }

  // Get completed tasks
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      return await getTasksByStatus(TaskStatus.completed);
    } catch (e) {
      _logger.e('Get completed tasks error: $e');
      return [];
    }
  }

  // Get tasks due today
  Future<List<TaskModel>> getTasksDueToday() async {
    try {
      final all = await getAllTasks();
      final today = DateTime.now();
      return all
          .where((t) => t.dueDate != null &&
              t.dueDate!.year == today.year &&
              t.dueDate!.month == today.month &&
              t.dueDate!.day == today.day)
          .toList();
    } catch (e) {
      _logger.e('Get tasks due today error: $e');
      return [];
    }
  }

  // Clear completed tasks
  Future<void> clearCompletedTasks() async {
    try {
      final completed = await getCompletedTasks();
      for (final task in completed) {
        await deleteTask(task.id);
      }
      _logger.i('Cleared ${completed.length} completed tasks');
    } catch (e) {
      _logger.e('Clear completed tasks error: $e');
      rethrow;
    }
  }
}
