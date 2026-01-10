# API Documentation - AI Agent Assistant

Complete API reference for integrating with the AI Agent Assistant.

## Overview

The app provides three main APIs through providers:

- **AIAgentProvider** - Ollama integration and model management
- **ConversationProvider** - Conversation and messaging
- **TaskProvider** - Task management

## AIAgentProvider

Manages Ollama connection and AI model operations.

### Initialization

```dart
final aiAgent = context.read<AIAgentProvider>();
await aiAgent.initialize();
```

### Properties

```dart
// Connection status
bool isConnected;              // Is Ollama connected
bool isLoading;                // Operation in progress
String? errorMessage;          // Last error message

// Model information
List<OllamaModelInfo> availableModels;  // Available models
String currentModel;           // Active model name
String baseUrl;                // Ollama server URL
```

### Methods

#### Health Check

```dart
Future<bool> checkConnection()
```

Check if Ollama server is reachable.

**Returns:** `true` if connected, `false` otherwise

**Example:**

```dart
if (!await aiAgent.checkConnection()) {
  // Handle connection error
  print('Ollama not available');
}
```

#### Refresh Models

```dart
Future<void> refreshModels()
```

Fetch latest available models from Ollama.

**Example:**

```dart
await aiAgent.refreshModels();
print('Models: ${aiAgent.availableModels.map((m) => m.name)}');
```

#### Set Model

```dart
void setModel(String model)
```

Change active AI model.

**Parameters:**

- `model` - Model name (e.g., 'mistral', 'llama2')

**Example:**

```dart
aiAgent.setModel('llama2');
```

#### Set Ollama URL

```dart
void setOllamaUrl(String url)
```

Configure Ollama server URL for remote connections.

**Parameters:**

- `url` - Ollama server URL (e.g., '[http://192.168.1.100:11434](http://192.168.1.100:11434)')

**Example:**

```dart
aiAgent.setOllamaUrl('http://192.168.1.100:11434');
```

#### Pull Model

```dart
Future<void> pullModel(String modelName)
```

Download and install a model from Ollama.

**Parameters:**

- `modelName` - Model name to download

**Example:**

```dart
await aiAgent.pullModel('mistral');
// Shows loading progress while downloading
```

#### Delete Model

```dart
Future<void> deleteModel(String modelName)
```

Remove a model from local storage.

**Parameters:**

- `modelName` - Model name to delete

**Example:**

```dart
await aiAgent.deleteModel('neural-chat');
```

#### Generate Embeddings

```dart
Future<List<List<double>>> generateEmbeddings(String text)
```

Generate vector embeddings for text similarity.

**Parameters:**

- `text` - Text to embed

**Returns:** List of embedding vectors

**Example:**

```dart
final embeddings = await aiAgent.generateEmbeddings('Hello world');
```

---

## ConversationProvider

Manages conversations and AI messaging.

### Initialization

```dart
final conversation = context.read<ConversationProvider>();
await conversation.initialize();
```

### Properties

```dart
// Conversation state
ConversationModel? activeConversation;     // Current conversation
List<ConversationModel> conversations;     // All conversations
bool isGenerating;                         // AI generating response
String? currentGeneratingMessage;          // Partial response
String? errorMessage;                      // Last error
```

### Methods

#### Create Conversation

```dart
Future<ConversationModel?> createNewConversation({
  required String title,
  required String category,
  Map<String, dynamic>? metadata,
})
```

Start a new conversation.

**Parameters:**

- `title` - Conversation title
- `category` - Category (Photography, Documentation, Prompting, etc.)
- `metadata` - Optional custom metadata

**Returns:** Created conversation or null if error

**Example:**

```dart
final conv = await conversation.createNewConversation(
  title: 'Image Analysis',
  category: 'Photography',
  metadata: {'theme': 'advanced'},
);
```

#### Send Message

```dart
Future<void> sendMessage({
  required String content,
  List<String>? attachments,
})
```

Send message and get AI response (with streaming).

**Parameters:**

- `content` - Message text
- `attachments` - Optional file paths

**Example:**

```dart
await conversation.sendMessage(
  content: 'Analyze this image',
  attachments: ['/path/to/image.jpg'],
);
```

#### Generate AI Response (Stream)

```dart
Stream<String> generateAIResponseStream({
  required String conversationId,
  required String userMessage,
  String? model,
})
```

Generate streaming AI response.

**Returns:** Stream of response chunks

**Example:**

```dart
await for (final chunk in conversation.generateAIResponseStream(
  conversationId: activeConv.id,
  userMessage: 'Hello!',
)) {
  print('Received: $chunk');
}
```

#### Select Conversation

```dart
Future<void> selectConversation(String conversationId)
```

Make conversation active.

**Parameters:**

- `conversationId` - Conversation ID

**Example:**

```dart
await conversation.selectConversation('conv_123');
```

#### Load Conversations

```dart
Future<void> loadConversations()
```

Refresh conversation list from database.

**Example:**

```dart
await conversation.loadConversations();
```

#### Search Conversations

```dart
Future<List<ConversationModel>> searchConversations(String query)
```

Search conversations by title.

**Parameters:**

- `query` - Search query

**Returns:** Matching conversations

**Example:**

```dart
final results = await conversation.searchConversations('analysis');
```

#### Update Title

```dart
Future<void> updateConversationTitle(
  String conversationId,
  String newTitle,
)
```

Rename conversation.

**Example:**

```dart
await conversation.updateConversationTitle('conv_123', 'New Title');
```

#### Export Conversation

```dart
Future<String?> exportConversation(
  String conversationId,
  String title,
)
```

Export conversation as JSON file.

**Returns:** File path or null if error

**Example:**

```dart
final path = await conversation.exportConversation(
  'conv_123',
  'Exported Chat',
);
```

#### Delete Conversation

```dart
Future<void> deleteConversation(String conversationId)
```

Remove conversation permanently.

**Example:**

```dart
await conversation.deleteConversation('conv_123');
```

#### Clear Error

```dart
void clearError()
```

Clear error message.

---

## TaskProvider

Manages task creation and tracking.

### Initialization

```dart
final task = context.read<TaskProvider>();
await task.initialize();
```

### Properties

```dart
// Task state
List<TaskModel> tasks;                // All tasks
List<TaskModel> filteredTasks;         // Filtered tasks
TaskModel? activeTask;                 // Selected task
bool isLoading;                        // Operation in progress
String? errorMessage;                  // Last error
TaskStatus? filterByStatus;            // Active status filter
TaskCategory? filterByCategory;        // Active category filter

// Statistics
int pendingCount;                      // Pending tasks
int inProgressCount;                   // In-progress tasks
int completedCount;                    // Completed tasks
```

### Methods

#### Create Task

```dart
Future<TaskModel?> createTask({
  required String title,
  required String description,
  required TaskCategory category,
  DateTime? dueDate,
  List<String>? attachments,
  Map<String, dynamic>? metadata,
  String? conversationId,
})
```

Create new task.

**Parameters:**

- `title` - Task title
- `description` - Task description
- `category` - Category (photography, documentation, etc.)
- `dueDate` - Optional due date
- `attachments` - Optional file paths
- `metadata` - Optional custom data
- `conversationId` - Link to conversation

**Returns:** Created task or null

**Example:**

```dart
final task = await task.createTask(
  title: 'Analyze Photo',
  description: 'Analyze uploaded photograph',
  category: TaskCategory.photography,
  dueDate: DateTime.now().add(Duration(days: 1)),
);
```

#### Select Task

```dart
Future<void> selectTask(String taskId)
```

Set active task.

**Example:**

```dart
await task.selectTask('task_123');
```

#### Update Task

```dart
Future<void> updateTask(TaskModel updatedTask)
```

Update task properties.

**Example:**

```dart
final updated = task.copyWith(title: 'New Title');
await task.updateTask(updated);
```

#### Update Status

```dart
Future<void> updateTaskStatus(String taskId, TaskStatus status)
```

Change task status.

**Parameters:**

- `taskId` - Task ID
- `status` - New status (pending, inProgress, completed, failed, cancelled)

**Example:**

```dart
await task.updateTaskStatus('task_123', TaskStatus.inProgress);
```

#### Add Result

```dart
Future<void> addTaskResult(String taskId, String result)
```

Set task result and mark complete.

**Example:**

```dart
await task.addTaskResult('task_123', 'Analysis complete: Objects detected...');
```

#### Delete Task

```dart
Future<void> deleteTask(String taskId)
```

Remove task permanently.

**Example:**

```dart
await task.deleteTask('task_123');
```

#### Load Tasks

```dart
Future<void> loadTasks()
```

Refresh task list from database.

**Example:**

```dart
await task.loadTasks();
```

#### Search Tasks

```dart
Future<List<TaskModel>> searchTasks(String query)
```

Search tasks by title or description.

**Example:**

```dart
final results = await task.searchTasks('analysis');
```

#### Set Filters

```dart
void setStatusFilter(TaskStatus? status)
void setCategoryFilter(TaskCategory? category)
```

Filter displayed tasks.

**Example:**

```dart
task.setStatusFilter(TaskStatus.pending);
task.setCategoryFilter(TaskCategory.photography);
```

---

## Models

### ConversationModel

```dart
class ConversationModel {
  final String id;                           // Unique ID (UUID)
  final String title;                        // Conversation title
  final List<MessageModel> messages;         // Message history
  final DateTime createdAt;                  // Creation timestamp
  final DateTime updatedAt;                  // Last update
  final String category;                     // Category
  final Map<String, dynamic> metadata;       // Custom data
}
```

### MessageModel

```dart
class MessageModel {
  final String id;                           // Unique ID
  final String content;                      // Message text
  final MessageRole role;                    // user/assistant/system
  final DateTime timestamp;                  // When sent
  final List<String>? attachments;           // File paths
  final Map<String, dynamic>? metadata;      // Custom data
}

enum MessageRole {
  user,
  assistant,
  system,
}
```

### TaskModel

```dart
class TaskModel {
  final String id;                           // Unique ID
  final String title;                        // Task title
  final String description;                  // Task description
  final TaskCategory category;               // Category
  final TaskStatus status;                   // Current status
  final DateTime createdAt;                  // Creation time
  final DateTime? dueDate;                   // Optional due date
  final List<String> attachments;            // Attached files
  final Map<String, dynamic> metadata;       // Custom data
  final String? result;                      // Task result
  final String? conversationId;              // Linked conversation
}

enum TaskCategory {
  photography,
  documentation,
  prompting,
  analysis,
  writing,
  translation,
  research,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}
```

### OllamaModelInfo

```dart
class OllamaModelInfo {
  final String name;                         // Model name
  final String size;                         // Model size
  final String digest;                       // Model digest hash
  final DateTime modifiedAt;                 // Last modified
}
```

---

## Error Handling

### Try-Catch Pattern

```dart
try {
  await conversation.sendMessage(content: 'Hello');
} catch (e) {
  print('Error: $e');
  conversation.clearError();
}
```

### Monitor Errors

```dart
Consumer<ConversationProvider>(
  builder: (context, provider, _) {
    if (provider.errorMessage != null) {
      return ErrorWidget(message: provider.errorMessage!);
    }
    return Content();
  },
)
```

---

## Examples

### Complete Chat Flow

```dart
// Initialize
final aiAgent = context.read<AIAgentProvider>();
final conversation = context.read<ConversationProvider>();

await aiAgent.initialize();
await conversation.initialize();

// Create conversation
final conv = await conversation.createNewConversation(
  title: 'My Chat',
  category: 'Prompting',
);

// Send messages
await conversation.sendMessage(content: 'Hello!');
await conversation.sendMessage(content: 'How are you?');

// Export
final path = await conversation.exportConversation(
  conv!.id,
  'My Chat',
);
```

### Complete Task Flow

```dart
final task = context.read<TaskProvider>();
await task.initialize();

// Create task
final t = await task.createTask(
  title: 'Analyze Image',
  description: 'Process uploaded photo',
  category: TaskCategory.photography,
);

// Update status
if (t != null) {
  await task.updateTaskStatus(t.id, TaskStatus.inProgress);
  
  // Simulate processing
  await Future.delayed(Duration(seconds: 5));
  
  // Add result
  await task.addTaskResult(t.id, 'Analysis complete!');
}
```

---

## Best Practices

1. **Always initialize** before using providers
2. **Handle errors** with try-catch blocks
3. **Check connection** before operations
4. **Use appropriate models** for task type
5. **Clean up streams** to prevent memory leaks
6. **Batch operations** for better performance
7. **Monitor isLoading** for UI feedback

---

**API Documentation Version 1.0**
