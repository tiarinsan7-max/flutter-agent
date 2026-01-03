import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: _getStatusIcon(),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              task.category.displayName,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () {},
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () {
                context.read<TaskProvider>().deleteTask(task.id);
              },
            ),
          ],
        ),
        onTap: () {
          context.read<TaskProvider>().selectTask(task.id);
        },
      ),
    );
  }

  Widget _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case TaskStatus.inProgress:
        return const Icon(Icons.hourglass_bottom, color: Colors.blue);
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case TaskStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
    }
  }
}
