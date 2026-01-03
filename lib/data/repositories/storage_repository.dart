import 'dart:io';
import 'package:logger/logger.dart';
import '../datasources/storage_service.dart';
import '../models/task_model.dart';

class StorageRepository {
  final StorageService storageService;
  final Logger _logger = Logger();

  StorageRepository({required this.storageService});

  Future<void> initialize() async {
    try {
      await storageService.initialize();
    } catch (e) {
      _logger.e('Initialize storage error: $e');
      rethrow;
    }
  }

  Future<String> saveImage(File imageFile, String taskId) async {
    try {
      return await storageService.saveImage(imageFile, taskId);
    } catch (e) {
      _logger.e('Save image error: $e');
      rethrow;
    }
  }

  Future<String> saveDocument(File docFile, String taskId) async {
    try {
      return await storageService.saveDocument(docFile, taskId);
    } catch (e) {
      _logger.e('Save document error: $e');
      rethrow;
    }
  }

  Future<void> saveConversation(String conversationId, String jsonData) async {
    try {
      await storageService.saveConversation(conversationId, jsonData);
    } catch (e) {
      _logger.e('Save conversation error: $e');
      rethrow;
    }
  }

  Future<String?> loadConversation(String conversationId) async {
    try {
      return await storageService.loadConversation(conversationId);
    } catch (e) {
      _logger.e('Load conversation error: $e');
      return null;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await storageService.deleteFile(path);
    } catch (e) {
      _logger.e('Delete file error: $e');
      rethrow;
    }
  }

  Future<File?> exportConversation(String conversationId, String title) async {
    try {
      return await storageService.exportConversation(conversationId, title);
    } catch (e) {
      _logger.e('Export conversation error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      return await storageService.getStorageStats();
    } catch (e) {
      _logger.e('Get storage stats error: $e');
      return {};
    }
  }

  Directory get appDirectory => storageService.appDirectory;
  Directory get imagesDirectory => storageService.imagesDirectory;
  Directory get documentsDirectory => storageService.documentsDirectory;
}
