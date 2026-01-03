# AI Agent Assistant - Flutter Mobile App

A comprehensive fullstack Flutter mobile application featuring an AI Agent/Assistant integrated with **Ollama** for local AI inference. The app supports multi-tasking capabilities across photography, documentation, prompting, and more, with full storage read/write access.

## 🎯 Features

### Core Features

- **Local AI Integration**: Seamless integration with Ollama for on-device AI inference
- **Multi-Task Support**: Handle multiple concurrent tasks efficiently
- **Rich Conversations**: Maintain context-aware conversations with AI models
- **Storage Management**: Full read/write access to device storage with organized file management

### Task Categories

1. **Photography**
  - Image recognition and analysis
  - Object detection
  - Scene analysis
  - OCR (Optical Character Recognition)
  - Quality assessment
2. **Documentation**
  - Text summarization
  - Document generation
  - Translation
  - Code documentation
  - PDF processing
3. **Prompting**
  - Custom AI prompts
  - Creative writing
  - Problem-solving
  - Code generation
  - Content creation
4. **Additional Categories**
  - Analysis
  - Writing
  - Translation
  - Research

### Advanced Features

- **Streaming Responses**: Real-time AI response streaming for better UX
- **Model Management**: Switch between different Ollama models on-the-fly
- **Conversation History**: Persistent storage of all conversations
- **Task Management**: Create, track, and manage multiple tasks with status updates
- **File Management**: Secure storage of images, documents, and task results
- **Export Functionality**: Export conversations and tasks as JSON
- **Advanced Settings**: Configure Ollama URL, model parameters, and more

## 📱 Architecture

### Technology Stack

```
Frontend:
- Flutter 3.10+
- Provider (State Management)
- GetIt (Service Locator)
- Hive (Local Database)
- Dio (HTTP Client)

Backend Integration:
- Ollama (Local AI)
- SharedPreferences (Configuration)
- File System (Storage)

Additional Libraries:
- image_picker: Camera & gallery access
- file_picker: Document selection
- camera: Real-time camera access
- permission_handler: Permission management
- logger: Advanced logging
```

### Project Structure

```
lib/
├── core/
│   ├── service_locator.dart       # Dependency injection setup
│   ├── theme/
│   │   └── app_theme.dart         # App theming
│   └── constants/
│       └── app_constants.dart     # App constants
│
├── data/
│   ├── datasources/
│   │   ├── ollama_service.dart    # Ollama API client
│   │   └── storage_service.dart   # Local storage operations
│   ├── models/
│   │   ├── conversation_model.dart
│   │   ├── task_model.dart
│   │   └── ollama_response_model.dart
│   └── repositories/
│       ├── ollama_repository.dart
│       ├── storage_repository.dart
│       ├── conversation_repository.dart
│       └── task_repository.dart
│
├── domain/
│   ├── entities/                  # Business logic entities
│   ├── repositories/              # Repository interfaces
│   └── usecases/                  # Business logic
│
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── chat/
│   │   │   └── chat_screen.dart
│   │   ├── tasks/
│   │   │   └── tasks_screen.dart
│   │   ├── photography/
│   │   │   └── photography_screen.dart
│   │   ├── documentation/
│   │   │   └── documentation_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── widgets/
│   │   ├── chat/
│   │   │   └── message_bubble.dart
│   │   └── task/
│   │       └── task_card.dart
│   └── providers/
│       ├── ai_agent_provider.dart
│       ├── conversation_provider.dart
│       └── task_provider.dart
│
└── main.dart
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.10.0 or higher)
2. **Ollama** (installed and running)
3. **Android Studio** or **Xcode** for mobile emulation
4. **At least one Ollama model** downloaded (e.g., `mistral`)

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd flutter_ai_agent_app
```

1. **Install dependencies**

```bash
flutter pub get
```

1. **Generate Hive adapters** (for local database)

```bash
flutter pub run build_runner build
```

1. **Run the app**

For Android:

```bash
flutter run
```

For iOS:

```bash
flutter run -d ios
```

### Setting up Ollama

1. **Install Ollama** from [ollama.ai](https://ollama.ai)
2. **Start Ollama service**

```bash
ollama serve
```

1. **Pull a model**

```bash
ollama pull mistral
# or
ollama pull llama2
ollama pull neural-chat
```

1. **Verify connection**

- The app will automatically detect Ollama at `http://localhost:11434`
- You can configure a custom URL in Settings if needed

## 📖 Usage Guide

### Creating a Conversation

1. Navigate to the **Chat** tab
2. Click on "Start New Conversation"
3. Select a category (Prompting, Photography, Documentation, etc.)
4. Start chatting with the AI agent

### Creating a Task

1. Navigate to the **Tasks** tab
2. Click the "+" button
3. Fill in:
  - Task title
  - Description
  - Category
  - Optional due date
4. The task will be created and tracked

### Photography Analysis

1. Navigate to the **Photography** tab
2. Capture or select an image from gallery
3. Click "Analyze Image"
4. The app will create an analysis task and process the image

### Document Processing

1. Navigate to the **Documentation** tab
2. Enter your documentation requirements
3. Optionally attach a document
4. Click "Generate Documentation"

### Configuration

1. Navigate to **Settings**
2. View connection status
3. Select active AI model
4. Configure Ollama URL if using remote instance
5. Advanced settings for fine-tuning

## 🔧 API Reference

### AIAgentProvider

```dart
// Initialize the agent
await aiAgentProvider.initialize();

// Check Ollama connection
bool isConnected = await aiAgentProvider.checkConnection();

// Set active model
aiAgentProvider.setModel('mistral');

// Configure Ollama URL
aiAgentProvider.setOllamaUrl('http://192.168.1.100:11434');

// Pull/Download a model
await aiAgentProvider.pullModel('llama2');

// Delete a model
await aiAgentProvider.deleteModel('neural-chat');
```

### ConversationProvider

```dart
// Initialize conversations
await conversationProvider.initialize();

// Create new conversation
final conv = await conversationProvider.createNewConversation(
  title: 'My Chat',
  category: 'Prompting',
);

// Send message
await conversationProvider.sendMessage(
  content: 'Hello, AI!',
);

// Search conversations
final results = await conversationProvider.searchConversations('keyword');

// Export conversation
final filePath = await conversationProvider.exportConversation(
  conversationId,
  'My Conversation',
);

// Delete conversation
await conversationProvider.deleteConversation(conversationId);
```

### TaskProvider

```dart
// Initialize tasks
await taskProvider.initialize();

// Create task
final task = await taskProvider.createTask(
  title: 'Analyze Image',
  description: 'Analyze the uploaded photo',
  category: TaskCategory.photography,
  dueDate: DateTime.now().add(Duration(days: 1)),
);

// Update task status
await taskProvider.updateTaskStatus(taskId, TaskStatus.inProgress);

// Add result to task
await taskProvider.addTaskResult(taskId, 'Analysis complete...');

// Search tasks
final results = await taskProvider.searchTasks('image');

// Get tasks by status
List<TaskModel> pending = taskProvider.tasks
  .where((t) => t.status == TaskStatus.pending)
  .toList();
```

## 🗄️ Data Models

### ConversationModel

```dart
- id: String (UUID)
- title: String
- messages: List<MessageModel>
- category: String
- createdAt: DateTime
- updatedAt: DateTime
- metadata: Map<String, dynamic>
```

### MessageModel

```dart
- id: String (UUID)
- content: String
- role: MessageRole (user, assistant, system)
- timestamp: DateTime
- attachments: List<String> (file paths)
- metadata: Map<String, dynamic>
```

### TaskModel

```dart
- id: String (UUID)
- title: String
- description: String
- category: TaskCategory
- status: TaskStatus
- createdAt: DateTime
- dueDate: DateTime?
- attachments: List<String>
- metadata: Map<String, dynamic>
- result: String?
- conversationId: String?
```

## 🔐 Permissions

The app requests the following permissions:

```yaml
Android (AndroidManifest.xml):
- CAMERA
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- INTERNET
- RECORD_AUDIO

iOS (Info.plist):
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSMicrophoneUsageDescription
```

## 📁 Storage Structure

```
App Documents Directory/
├── conversations/
│   ├── conv_id_1.json
│   ├── conv_id_2.json
│   └── ...
├── tasks/
│   ├── task_id_1.json
│   ├── task_id_2.json
│   └── ...
├── images/
│   ├── task_id_timestamp.jpg
│   └── ...
├── documents/
│   ├── task_id_document.pdf
│   └── ...
└── exports/
    └── conversations/documents
```

## 🐛 Debugging

Enable logging to see detailed information:

```dart
import 'package:logger/logger.dart';

final logger = Logger();
logger.i('Info message');
logger.d('Debug message');
logger.w('Warning message');
logger.e('Error message');
```

Logs are printed to the console and help debug API calls, storage operations, and state changes.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Ollama for local AI inference
- Flutter team for the amazing framework
- Provider package for state management
- Hive for local database

## 📞 Support

For issues, questions, or suggestions:

- Open an GitHub issue
- Check existing documentation
- Review the code comments

## 🔄 Version History

### v1.0.0 (Initial Release)

- Core AI Agent functionality
- Ollama integration
- Multi-task support
- Conversation management
- Photography analysis
- Document processing
- Settings configuration

---

**Happy coding! 🚀**
