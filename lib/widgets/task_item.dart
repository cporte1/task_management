import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final void Function(Task) onToggleComplete;
  final void Function(Task) onDelete;

  TaskItem({
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: task.subTasks.entries.map((dayEntry) {
          String day = dayEntry.key;
          Map<String, dynamic> timeTasks = Map<String, dynamic>.from(dayEntry.value);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
              ...timeTasks.entries.map((timeEntry) {
                String time = timeEntry.key;
                // Convert each dynamic list to List<String> safely
                List<String> tasks = List<String>.from(timeEntry.value ?? []);
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('$time: ${tasks.join(', ')}'),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => onToggleComplete(task),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => onDelete(task),
      ),
    );
  }
}
