import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_agent_assistant/data/datasources/ollama_service.dart';
import 'package:ai_agent_assistant/data/datasources/storage_service.dart';
import 'package:ai_agent_assistant/data/repositories/conversation_repository.dart';
import 'package:ai_agent_assistant/data/repositories/ollama_repository.dart';
import 'package:ai_agent_assistant/data/repositories/storage_repository.dart';
import 'package:ai_agent_assistant/data/repositories/task_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final dio = Dio();
  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Data sources
  getIt.registerSingleton<OllamaService>(
    OllamaService(dio: dio),
  );

  getIt.registerSingleton<StorageService>(
    StorageService(),
  );

  // Repositories
  getIt.registerSingleton<StorageRepository>(
    StorageRepository(storageService: getIt<StorageService>()),
  );

  getIt.registerSingleton<OllamaRepository>(
    OllamaRepository(ollamaService: getIt<OllamaService>()),
  );

  getIt.registerSingleton<ConversationRepository>(
    ConversationRepository(
      ollamaRepository: getIt<OllamaRepository>(),
      storageRepository: getIt<StorageRepository>(),
    ),
  );

  getIt.registerSingleton<TaskRepository>(
    TaskRepository(
      storageRepository: getIt<StorageRepository>(),
    ),
  );

  // Initialize storage layer eagerly so directories exist
  await getIt<StorageRepository>().initialize();
}
