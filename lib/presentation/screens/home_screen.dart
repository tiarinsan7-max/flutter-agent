import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_agent_provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/task_provider.dart';
import 'chat/chat_screen.dart';
import 'tasks/tasks_screen.dart';
import 'photography/photography_screen.dart';
import 'documentation/documentation_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final aiAgent = context.read<AIAgentProvider>();
    final conversation = context.read<ConversationProvider>();
    final task = context.read<TaskProvider>();

    await aiAgent.initialize();
    await conversation.initialize();
    await task.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ChatScreen(),
          TasksScreen(),
          PhotographyScreen(),
          DocumentationScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Photography',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Documentation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
