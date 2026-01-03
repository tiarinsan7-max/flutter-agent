class AppConstants {
  // Ollama Configuration
  static const String ollamaBaseUrl = 'http://localhost:11434';
  static const String defaultOllamaModel = 'deepseek-v3.1:671b-cloud';
  static const Duration ollamaTimeout = Duration(minutes: 5);

  // Storage Configuration
  static const String appStorageName = 'ai_agent_storage';
  static const String conversationsBoxName = 'conversations';
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  // Task Categories
  static const List<String> taskCategories = [
    'Photography',
    'Documentation',
    'Prompting',
    'Analysis',
    'Writing',
    'Translation',
    'Research',
  ];

  // Photography Tasks
  static const List<String> photographyTasks = [
    'Image Recognition',
    'Object Detection',
    'Scene Analysis',
    'Text Recognition (OCR)',
    'Quality Assessment',
  ];

  // Documentation Tasks
  static const List<String> documentationTasks = [
    'Text Summarization',
    'Document Generation',
    'Translation',
    'Code Documentation',
    'PDF Processing',
  ];

  // Prompting Tasks
  static const List<String> promptingTasks = [
    'Custom Prompts',
    'Creative Writing',
    'Problem Solving',
    'Code Generation',
    'Content Creation',
  ];

  // AI Model Configuration
  static const int maxTokens = 2048;
  static const double temperature = 0.7;
  static const double topP = 0.95;

  // UI Configuration
  static const int maxRecentConversations = 20;
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // File Configuration
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> supportedDocumentFormats = ['pdf', 'txt', 'md', 'doc', 'docx'];
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
}
