import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import 'dart:io';

class PhotographyScreen extends StatefulWidget {
  const PhotographyScreen({Key? key}) : super(key: key);

  @override
  State<PhotographyScreen> createState() => _PhotographyScreenState();
}

class _PhotographyScreenState extends State<PhotographyScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _analysisResult;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();
      final task = await taskProvider.createTask(
        title: 'Image Analysis',
        description: 'Analyzing selected image',
        category: TaskCategory.photography,
      );

      if (task != null) {
        setState(() {
          _analysisResult = 'Image analysis task created: ${task.id}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image analysis task created')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photography AI'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Photography Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage == null)
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.photo_library,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                          ),
                        )
                      else
                        Image.file(
                          _selectedImage!,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeImage,
                        child: _isAnalyzing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Analyze Image'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_analysisResult != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_analysisResult!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
