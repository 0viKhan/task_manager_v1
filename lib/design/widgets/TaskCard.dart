import 'package:flutter/material.dart';


// Example enum for task types
enum TaskType { newTask, progress, completed }

// Simple TaskCard widget
class TaskCard extends StatelessWidget {
  final TaskType taskType;
  final String? title;
  final String? description;

  const TaskCard({
    super.key,
    required this.taskType,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (taskType) {
      case TaskType.newTask:
        color = Colors.blue;
        break;
      case TaskType.progress:
        color = Colors.orange;
        break;
      case TaskType.completed:
        color = Colors.green;
        break;
    }

    return Card(
      color: color.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title ?? "No Title"),
        subtitle: Text(description ?? "No Description"),
        trailing: Icon(Icons.arrow_forward),
      ),
    );
  }
}
