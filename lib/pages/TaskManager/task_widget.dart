import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskChanged;
  final Function(Task) onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTaskChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onTaskChanged(task),
        ),
        title: Text(
          task.taskText,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.startTime != null && task.endTime != null
            ? Text(
                "Start: ${task.startTime!.hour}:${task.startTime!.minute} | "
                "End: ${task.endTime!.hour}:${task.endTime!.minute}",
                style: const TextStyle(color: Colors.grey),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDelete(task),
        ),
      ),
    );
  }
}
