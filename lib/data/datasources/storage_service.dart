import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final Logger _logger = Logger();
  late Directory _appDirectory;
  late Directory _conversationsDir;
  late Directory _tasksDir;
  late Directory _imagesDir;
  late Directory _documentsDir;

  StorageService();

  Future<void> initialize() async {
    try {
      _appDirectory = await getApplicationDocumentsDirectory();
      
      // Create subdirectories
      _conversationsDir = Directory('${_appDirectory.path}/conversations');
      _tasksDir = Directory('${_appDirectory.path}/tasks');
      _imagesDir = Directory('${_appDirectory.path}/images');
      _documentsDir = Directory('${_appDirectory.path}/documents');

      // Ensure directories exist
      await Future.wait([
        _conversationsDir.create(recursive: true),
        _tasksDir.create(recursive: true),
        _imagesDir.create(recursive: true),
        _documentsDir.create(recursive: true),
      ]);

      _logger.i('Storage initialized at: ${_appDirectory.path}');
    } catch (e) {
      _logger.e('Storage initialization error: $e');
      rethrow;
    }
  }

  // Get app directory
  Directory get appDirectory => _appDirectory;
  Directory get conversationsDirectory => _conversationsDir;
  Directory get tasksDirectory => _tasksDir;
  Directory get imagesDirectory => _imagesDir;
  Directory get documentsDirectory => _documentsDir;

  // Save image
  Future<String> saveImage(File imageFile, String taskId) async {
    try {
      final fileName = '${taskId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${_imagesDir.path}/$fileName';
      
      // Compress image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        // Resize if too large (max 1920 width)
        final resized = image.width > 1920
            ? img.copyResize(image, width: 1920)
            : image;
        
        final compressed = File(savedPath)..writeAsBytesSync(
          img.encodeJpg(resized, quality: 85),
        );
        
        _logger.i('Image saved: $savedPath');
        return savedPath;
      }
      
      // Fallback: copy original
      final saved = await imageFile.copy(savedPath);
      _logger.i('Image saved (uncompressed): $savedPath');
      return saved.path;
    } catch (e) {
      _logger.e('Failed to save image: $e');
      rethrow;
    }
  }

  // Save document
  Future<String> saveDocument(File docFile, String taskId) async {
    try {
      final fileName = '${taskId}_${DateTime.now().millisecondsSinceEpoch}_${docFile.path.split('/').last}';
      final savedPath = '${_documentsDir.path}/$fileName';
      
      final saved = await docFile.copy(savedPath);
      _logger.i('Document saved: $savedPath');
      return saved.path;
    } catch (e) {
      _logger.e('Failed to save document: $e');
      rethrow;
    }
  }

  // Save conversation
  Future<void> saveConversation(String conversationId, String jsonData) async {
    try {
      final file = File('${_conversationsDir.path}/$conversationId.json');
      await file.writeAsString(jsonData);
      _logger.i('Conversation saved: ${file.path}');
    } catch (e) {
      _logger.e('Failed to save conversation: $e');
      rethrow;
    }
  }

  // Load conversation
  Future<String?> loadConversation(String conversationId) async {
    try {
      final file = File('${_conversationsDir.path}/$conversationId.json');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      _logger.e('Failed to load conversation: $e');
      return null;
    }
  }

  // Save task
  Future<void> saveTask(String taskId, String jsonData) async {
    try {
      final file = File('${_tasksDir.path}/$taskId.json');
      await file.writeAsString(jsonData);
      _logger.i('Task saved: ${file.path}');
    } catch (e) {
      _logger.e('Failed to save task: $e');
      rethrow;
    }
  }

  // Load task
  Future<String?> loadTask(String taskId) async {
    try {
      final file = File('${_tasksDir.path}/$taskId.json');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      _logger.e('Failed to load task: $e');
      return null;
    }
  }

  // List files in directory
  Future<List<File>> listFiles(Directory directory) async {
    try {
      if (await directory.exists()) {
        return directory
            .listSync(recursive: false)
            .whereType<File>()
            .toList();
      }
      return [];
    } catch (e) {
      _logger.e('Failed to list files: $e');
      return [];
    }
  }

  // Delete file
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('File deleted: $path');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to delete file: $e');
      return false;
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      _logger.e('Failed to get file size: $e');
      return 0;
    }
  }

  // Export conversation
  Future<File?> exportConversation(String conversationId, String title) async {
    try {
      final fileName = '${title}_$conversationId.json';
      final savedFile = File('${_appDirectory.path}/exports/$fileName');
      await savedFile.parent.create(recursive: true);
      
      final conversationData = await loadConversation(conversationId);
      if (conversationData != null) {
        await savedFile.writeAsString(conversationData);
        _logger.i('Conversation exported: ${savedFile.path}');
        return savedFile;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to export conversation: $e');
      return null;
    }
  }

  // Clear all data (with caution)
  Future<void> clearAllData() async {
    try {
      await Future.wait([
        _conversationsDir.delete(recursive: true),
        _tasksDir.delete(recursive: true),
      ]);
      
      // Recreate directories
      await Future.wait([
        _conversationsDir.create(recursive: true),
        _tasksDir.create(recursive: true),
      ]);
      
      _logger.w('All data cleared');
    } catch (e) {
      _logger.e('Failed to clear data: $e');
      rethrow;
    }
  }

  // Get storage stats
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final conversations = await listFiles(_conversationsDir);
      final tasks = await listFiles(_tasksDir);
      final images = await listFiles(_imagesDir);
      final documents = await listFiles(_documentsDir);

      int totalSize = 0;
      for (var file in [...conversations, ...tasks, ...images, ...documents]) {
        totalSize += await getFileSize(file.path);
      }

      return {
        'totalFiles': conversations.length + tasks.length + images.length + documents.length,
        'conversationFiles': conversations.length,
        'taskFiles': tasks.length,
        'imageFiles': images.length,
        'documentFiles': documents.length,
        'totalSizeBytes': totalSize,
        'totalSizeMB': totalSize / (1024 * 1024),
      };
    } catch (e) {
      _logger.e('Failed to get storage stats: $e');
      return {};
    }
  }
}
