# Development Guide

Guidelines and best practices for developing with the AI Agent Assistant app.

## Table of Contents

1. [Architecture](#architecture)
2. [Code Style](#code-style)
3. [Adding Features](#adding-features)
4. [Testing](#testing)
5. [Performance Tips](#performance-tips)
6. [Common Patterns](#common-patterns)

## Architecture

### Clean Architecture Layers

```
Presentation Layer
    ↓
Business Logic Layer (Providers)
    ↓
Domain Layer
    ↓
Data Layer (Repositories)
    ↓
Data Source Layer (Services)
```

### Layer Responsibilities

**Presentation Layer** (`lib/presentation/`)

- UI Components
- Widgets
- Screens
- User interaction handling

**Business Logic** (`lib/presentation/providers/`)

- State management
- Business rules
- Data transformation
- Error handling

**Domain Layer** (`lib/domain/`)

- Entities (business objects)
- Repository interfaces
- Use cases (business logic)

**Data Layer** (`lib/data/`)

- Repository implementations
- Models (data structures)
- Data sources (services)
- Local/remote storage

**Data Source** (`lib/data/datasources/`)

- Ollama API client
- Storage operations
- External service calls

### Dependency Flow

```
Presentation → Provider → Repository → Service
     ↑                          ↓
     ←←←← Local Databases ←←←←←
```

## Code Style

### Dart Conventions

```dart
// Class names: PascalCase
class MyWidget extends StatelessWidget {}

// File names: snake_case
// my_widget.dart

// Constants: camelCase or SCREAMING_SNAKE_CASE
const String appName = 'AI Agent';
const int maxRetries = 3;

// Private members: _prefix
class _PrivateClass {}
String _privateVariable;

// Functions: camelCase
void myFunction() {}
Future<String> fetchData() {}
```

### Documentation

```dart
/// Single line documentation
String name;

/// Multi-line documentation
/// provides more details
/// about the implementation
class MyClass {
  /// Describes what this method does
  /// 
  /// [parameter] - what this parameter is
  /// Returns: what is returned
  String myMethod(String parameter) {
    // Implementation
  }
}
```

### Error Handling

```dart
// ✓ Good
try {
  final result = await repository.fetchData();
  return result;
} catch (e) {
  logger.e('Error fetching data: $e');
  rethrow;
}

// ✗ Avoid
try {
  final result = await repository.fetchData();
} catch (_) {
  // Silent failure
}
```

### Async Programming

```dart
// ✓ Good - using async/await
Future<String> fetchData() async {
  final response = await http.get(url);
  return response.body;
}

// ✓ Also acceptable - using streams
Stream<String> streamData() async* {
  yield 'data1';
  yield 'data2';
}

// ✗ Avoid - mixing patterns
Future<void> mixedPattern() {
  return http.get(url).then((response) {
    return Future.value(response.body);
  });
}
```

## Adding Features

### 1. Add New Task Category

```dart
// Step 1: Update TaskCategory enum in task_model.dart
enum TaskCategory {
  photography,
  documentation,
  prompting,
  analysis,      // existing
  newCategory,   // Add here
}

// Step 2: Update constants
static const List<String> taskCategories = [
  'Photography',
  'Documentation',
  'Prompting',
  'Analysis',
  'New Category',
];

// Step 3: Create screen in lib/presentation/screens/
class NewCategoryScreen extends StatefulWidget {
  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

// Step 4: Add to home_screen.dart navigation
const NewCategoryScreen(),

// Step 5: Update bottom navigation
BottomNavigationBarItem(
  icon: Icon(Icons.new_icon),
  label: 'New Category',
)
```

### 2. Add New Provider Feature

```dart
// Step 1: Create use case or method
class MyProvider extends ChangeNotifier {
  // Properties
  bool isLoading = false;
  String? errorMessage;
  
  // Methods
  Future<void> myFeature() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Implementation
      
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error: $e';
      logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Step 2: Use in UI
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }
    if (provider.errorMessage != null) {
      return ErrorWidget(message: provider.errorMessage!);
    }
    return ContentWidget();
  },
)
```

### 3. Add New Repository Method

```dart
// Step 1: Add to data source
class MyService {
  Future<MyData> fetchData() async {
    // API call
  }
}

// Step 2: Add to repository
class MyRepository {
  final MyService service;
  
  Future<MyData> fetchData() async {
    try {
      return await service.fetchData();
    } catch (e) {
      logger.e('Error: $e');
      rethrow;
    }
  }
}

// Step 3: Register in service locator
getIt.registerSingleton<MyRepository>(
  MyRepository(service: getIt<MyService>()),
);

// Step 4: Use in provider
class MyProvider extends ChangeNotifier {
  final MyRepository repository;
  
  MyProvider(this.repository);
  
  Future<void> loadData() async {
    final data = await repository.fetchData();
  }
}
```

## Testing

### Unit Tests

```dart
// test/providers/my_provider_test.dart
void main() {
  late MyProvider provider;
  late MockRepository mockRepository;
  
  setUp(() {
    mockRepository = MockRepository();
    provider = MyProvider(mockRepository);
  });
  
  test('Should update data when fetching', () async {
    // Arrange
    when(mockRepository.fetchData()).thenAnswer(
      (_) async => TestData(),
    );
    
    // Act
    await provider.loadData();
    
    // Assert
    expect(provider.data, isNotNull);
    verify(mockRepository.fetchData()).called(1);
  });
}
```

### Widget Tests

```dart
// test/widgets/my_widget_test.dart
void main() {
  testWidgets('Widget displays data', (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(MyTestApp());
    
    // Verify initial state
    expect(find.byType(LoadingWidget), findsOneWidget);
    
    // Simulate data loading
    await tester.pumpAndSettle();
    
    // Verify final state
    expect(find.byType(ContentWidget), findsOneWidget);
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/path/to/test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --summary coverage/lcov.info
```

## Performance Tips

### 1. Optimize Rebuilds

```dart
// ✓ Good - use Consumer with specific provider
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return Text(provider.data);
  },
)

// ✗ Avoid - rebuilds entire widget tree
Text(context.read<MyProvider>().data)
```

### 2. Use const Constructors

```dart
// ✓ Good
const SizedBox(height: 16);
const Padding(padding: EdgeInsets.all(8));

// ✗ Avoid
SizedBox(height: 16);
Padding(padding: EdgeInsets.all(8));
```

### 3. Lazy Loading

```dart
// ✓ Good - load on demand
FutureBuilder<Data>(
  future: repository.fetchData(),
  builder: (context, snapshot) {
    if (snapshot.hasData) return DataWidget(snapshot.data);
    return LoadingWidget();
  },
)

// ✗ Avoid - load everything upfront
await repository.fetchData();
```

### 4. Image Optimization

```dart
// ✓ Good - use cached network image
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => LoadingWidget(),
)

// ✓ Good - compress before upload
final compressed = await compressImage(file);
await uploadImage(compressed);
```

### 5. Database Queries

```dart
// ✓ Good - paginate results
final tasks = await taskRepository.getTasks(
  limit: 20,
  offset: 0,
);

// ✗ Avoid - load all at once
final allTasks = await taskRepository.getAllTasks();
```

## Common Patterns

### 1. Provider with Loading State

```dart
class MyProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  MyData? data;
  
  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      data = await repository.fetchData();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Usage
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.errorMessage != null) {
      return ErrorWidget(message: provider.errorMessage!);
    }
    return DataWidget(data: provider.data);
  },
)
```

### 2. Stream with Consumer

```dart
class MyProvider extends ChangeNotifier {
  Stream<String> getStreamData() {
    return repository.streamData();
  }
}

// Usage
StreamBuilder<String>(
  stream: context.read<MyProvider>().getStreamData(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return LoadingWidget();
    return Text(snapshot.data!);
  },
)
```

### 3. Form Validation

```dart
class FormProvider extends ChangeNotifier {
  String? _email;
  String? _emailError;
  
  String? get emailError => _emailError;
  
  void setEmail(String email) {
    _email = email;
    _validateEmail();
    notifyListeners();
  }
  
  void _validateEmail() {
    if (_email == null || _email!.isEmpty) {
      _emailError = 'Email is required';
    } else if (!_email!.contains('@')) {
      _emailError = 'Invalid email format';
    } else {
      _emailError = null;
    }
  }
  
  bool isValid() {
    return _emailError == null;
  }
}
```

### 4. Retry Logic

```dart
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(delay * (i + 1));
    }
  }
  throw Exception('Should not reach here');
}

// Usage
final data = await withRetry(
  () => repository.fetchData(),
  maxRetries: 3,
);
```

### 5. Debounce

```dart
class SearchProvider extends ChangeNotifier {
  Timer? _debounce;
  List<String> results = [];
  
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }
  
  void _performSearch(String query) async {
    results = await repository.search(query);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

## Debugging Tips

### 1. Enable Verbose Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### 2. Use DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
devtools

# Or with Flutter
flutter pub global run devtools
```

### 3. Print Provider State

```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    print('Provider state: ${provider.toString()}');
    return Widget();
  },
)
```

---

**Happy Coding! 🚀**
