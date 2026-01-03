import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository taskRepository;
  final Logger _logger = Logger();

  List<TaskModel> tasks = [];
  List<TaskModel> filteredTasks = [];
  TaskModel? activeTask;
  bool isLoading = false;
  String? errorMessage;
  TaskStatus? filterByStatus;
  TaskCategory? filterByCategory;

  TaskProvider(this.taskRepository);

  Future<void> initialize() async {
    try {
      await taskRepository.initialize();
      await loadTasks();
      _logger.i('Task provider initialized');
    } catch (e) {
      errorMessage = 'Initialization error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    try {
      isLoading = true;
      notifyListeners();

      tasks = await taskRepository.getAllTasks();
      _applyFilters();
      _logger.i('Loaded ${tasks.length} tasks');
    } catch (e) {
      errorMessage = 'Load tasks error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskModel?> createTask({
    required String title,
    required String description,
    required TaskCategory category,
    DateTime? dueDate,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? conversationId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final newTask = await taskRepository.createTask(
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        attachments: attachments,
        metadata: metadata,
        conversationId: conversationId,
      );

      tasks.insert(0, newTask);
      _applyFilters();
      _logger.i('Task created: ${newTask.id}');

      return newTask;
    } catch (e) {
      errorMessage = 'Create task error: $e';
      _logger.e(errorMessage);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTask(String taskId) async {
    try {
      activeTask = await taskRepository.getTask(taskId);
      errorMessage = null;
      _logger.i('Selected task: $taskId');
      notifyListeners();
    } catch (e) {
      errorMessage = 'Select task error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await taskRepository.updateTask(updatedTask);

      final index = tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index >= 0) {
        tasks[index] = updatedTask;
      }

      if (activeTask?.id == updatedTask.id) {
        activeTask = updatedTask;
      }

      _applyFilters();
      _logger.i('Task updated: ${updatedTask.id}');
    } catch (e) {
      errorMessage = 'Update task error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updatedTask = await taskRepository.updateTaskStatus(taskId, status);
      await updateTask(updatedTask);
    } catch (e) {
      errorMessage = 'Update status error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> addTaskResult(String taskId, String result) async {
    try {
      final updatedTask = await taskRepository.addTaskResult(taskId, result);
      await updateTask(updatedTask);
    } catch (e) {
      errorMessage = 'Add result error: $e';
      _logger.e(errorMessage);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await taskRepository.deleteTask(taskId);
      tasks.removeWhere((t) => t.id == taskId);

      if (activeTask?.id == taskId) {
        activeTask = null;
      }

      _applyFilters();
      _logger.i('Task deleted: $taskId');
    } catch (e) {
      errorMessage = 'Delete task error: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(TaskStatus? status) {
    filterByStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    filterByCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    filteredTasks = tasks.where((task) {
      bool statusMatch = filterByStatus == null || task.status == filterByStatus;
      bool categoryMatch = filterByCategory == null || task.category == filterByCategory;
      return statusMatch && categoryMatch;
    }).toList();
  }

  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      return await taskRepository.searchTasks(query);
    } catch (e) {
      errorMessage = 'Search error: $e';
      _logger.e(errorMessage);
      return [];
    }
  }

  int get pendingCount => tasks.where((t) => t.status == TaskStatus.pending).length;
  int get inProgressCount => tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get completedCount => tasks.where((t) => t.status == TaskStatus.completed).length;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
