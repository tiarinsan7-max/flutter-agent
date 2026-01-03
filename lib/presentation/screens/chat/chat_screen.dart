import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showNewConversationDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConversationProvider>();
      if (provider.activeConversation == null) {
        _showNewConversationSheet();
      }
    });
  }

  void _showNewConversationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _NewConversationSheet(
        onConversationCreated: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    final provider = context.read<ConversationProvider>();
    provider.sendMessage(content: message);

    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        if (provider.activeConversation == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No active conversation'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showNewConversationSheet,
                  child: const Text('Start New Conversation'),
                ),
              ],
            ),
          );
        }

        final conversation = provider.activeConversation!;

        return Scaffold(
          appBar: AppBar(
            title: Text(conversation.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Conversation'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteConversation(conversation.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: conversation.messages.length +
                      (provider.isGenerating ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == conversation.messages.length) {
                      return MessageBubble(
                        content: provider.currentGeneratingMessage ?? '',
                        role: 'assistant',
                        isGenerating: true,
                      );
                    }

                    final message = conversation.messages[index];
                    return MessageBubble(
                      content: message.content,
                      role: message.role.toString().split('.').last,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed:
                          provider.isGenerating ? null : _sendMessage,
                      child: provider.isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _NewConversationSheet extends StatefulWidget {
  final VoidCallback onConversationCreated;

  const _NewConversationSheet({required this.onConversationCreated});

  @override
  State<_NewConversationSheet> createState() => __NewConversationSheetState();
}

class __NewConversationSheetState extends State<_NewConversationSheet> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Prompting';
  final List<String> _categories = [
    'Prompting',
    'Photography',
    'Documentation',
    'Analysis',
    'Writing',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Conversation Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedCategory,
            items: _categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'Prompting';
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<ConversationProvider>();
              await provider.createNewConversation(
                title: _titleController.text.isNotEmpty
                    ? _titleController.text
                    : 'New Conversation',
                category: _selectedCategory,
              );
              widget.onConversationCreated();
            },
            child: const Text('Create Conversation'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
