import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';

import 'core/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/ollama_service.dart';
import 'data/datasources/storage_service.dart';
import 'data/models/conversation_model.dart';
import 'data/models/task_model.dart';
import 'data/repositories/conversation_repository.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/providers/ai_agent_provider.dart';
import 'presentation/providers/conversation_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());

  // Setup Service Locator
  await setupServiceLocator();

  // Request permissions
  await _requestPermissions();

  runApp(const AIAgentApp());
}

Future<void> _requestPermissions() async {
  final permissions = [
    Permission.camera,
    Permission.photos,
    Permission.storage,
    Permission.microphone,
  ];

  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }
}

class AIAgentApp extends StatelessWidget {
  const AIAgentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.I;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConversationProvider>(
          create: (_) => ConversationProvider(getIt<ConversationRepository>()),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(getIt<TaskRepository>()),
        ),
        ChangeNotifierProvider<AIAgentProvider>(
          create: (_) => AIAgentProvider(
            getIt<OllamaService>(),
            getIt<StorageService>(),
            getIt<ConversationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Agent Assistant',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
