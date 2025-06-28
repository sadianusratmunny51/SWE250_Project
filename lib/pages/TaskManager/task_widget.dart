import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';
import 'package:intl/intl.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 4.0), // Margin between task items
      decoration: BoxDecoration(
        color: Colors.deepPurple, // Main background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 244, 116, 116).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            // Left Icon Container (Calendar icon)
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.work,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.taskText, // Task title
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.startTime != null && task.endTime != null
                        ? '${DateFormat('HH:mm').format(task.startTime!)} - ${DateFormat('HH:mm').format(task.endTime!)}' // ONLY TIME DETAILS
                        : 'No time specified',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Checkbox
            Checkbox(
              value: task.isDone,
              onChanged: (bool? newValue) {
                onTaskChanged(task);
              },
              activeColor: Colors.green,
              checkColor: Colors.white,
              side: const BorderSide(
                color: Colors.white70,
                width: 2.0,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                onDelete(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
