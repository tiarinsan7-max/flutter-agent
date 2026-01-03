import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_agent_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ollamaUrlController = TextEditingController();
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AIAgentProvider>();
    _ollamaUrlController.text = provider.baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAgentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Connection Status
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connection Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              provider.isConnected
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: provider.isConnected
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.isConnected
                                        ? 'Connected'
                                        : 'Disconnected',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Ollama: ${provider.baseUrl}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.checkConnection();
                              },
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Model Selection
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Model',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.availableModels.isEmpty)
                          const Text('No models available')
                        else
                          DropdownButton<String>(
                            isExpanded: true,
                            value: provider.currentModel,
                            items: provider.availableModels.map((model) {
                              return DropdownMenuItem(
                                value: model.name,
                                child: Text(model.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setModel(value);
                              }
                            },
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.refreshModels();
                          },
                          child: const Text('Refresh Models'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Advanced Settings
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Advanced Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showAdvanced
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showAdvanced = !_showAdvanced;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_showAdvanced) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _ollamaUrlController,
                            decoration: InputDecoration(
                              labelText: 'Ollama URL',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: 'http://localhost:11434',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              provider.setOllamaUrl(_ollamaUrlController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ollama URL updated'),
                                ),
                              );
                            },
                            child: const Text('Save URL'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Error Display
                if (provider.errorMessage != null)
                  Card(
                    margin: const EdgeInsets.all(16),
                    color: Colors.red[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              provider.clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ollamaUrlController.dispose();
    super.dispose();
  }
}
