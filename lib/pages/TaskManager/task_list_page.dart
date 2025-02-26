import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';
import 'package:project/pages/TaskManager/task_widget.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late List<Task> taskList;
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
              title: const Text("Add Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(hintText: "Enter task"),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedStartTime == null
                        ? "Select Start Time"
                        : "Start: ${selectedStartTime!.hour}:${selectedStartTime!.minute}"),
                    trailing: const Icon(Icons.timer),
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
                    trailing: const Icon(Icons.timer_off),
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
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Add"),
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
      backgroundColor: const Color.fromARGB(255, 141, 190, 142),
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            _buildSearchBox(),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50, bottom: 20),
                    child: const Text(
                      'All Tasks',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  for (Task task in taskList)
                    TaskItem(
                      task: task,
                      onTaskChanged: toggleTaskStatus,
                      onDelete: deleteTask,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 141, 190, 142),
      title: const Text(
        "Task List",
        style: TextStyle(
            color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
          border: InputBorder.none,
          hintText: 'Search for tasks',
        ),
      ),
    );
  }
}
