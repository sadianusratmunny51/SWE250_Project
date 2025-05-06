import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';
import 'package:project/pages/TaskManager/task_widget.dart';
import 'package:project/pages/Notifications/notification_page.dart'; // Import NotificationsPage

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> taskList = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    taskList = Task.taskList();
  }

  void toggleTaskStatus(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });
  }

  void deleteTask(Task task) {
    setState(() {
      taskList.remove(task);
    });
  }

  void addTask(String task, DateTime startTime, DateTime endTime) {
    if (task.isNotEmpty) {
      setState(() {
        taskList.add(Task(
          id: DateTime.now().toString(),
          taskText: task,
          startTime: startTime,
          endTime: endTime,
        ));
      });
      _taskController.clear();
    }
  }

  void _showAddTaskDialog() {
    DateTime? selectedStartTime;
    DateTime? selectedEndTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.white,
              title: const Text(
                "Add New Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: "Enter task",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedStartTime == null
                        ? "Select Start Time"
                        : "Start: ${selectedStartTime!.hour}:${selectedStartTime!.minute}"),
                    trailing: const Icon(Icons.timer, color: Colors.blue),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedStartTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(selectedEndTime == null
                        ? "Select End Time"
                        : "End: ${selectedEndTime!.hour}:${selectedEndTime!.minute}"),
                    trailing: const Icon(Icons.timer_off, color: Colors.red),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedEndTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child:
                      const Text("Add", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (_taskController.text.isNotEmpty &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      addTask(_taskController.text, selectedStartTime!,
                          selectedEndTime!);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          "Task Manager",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NotificationsPage(taskList: taskList)),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: taskList
            .map((task) => TaskItem(
                  task: task,
                  onTaskChanged: toggleTaskStatus,
                  onDelete: deleteTask,
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
      ),
    );
  }
}
