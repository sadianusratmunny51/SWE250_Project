import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';
import 'package:project/pages/TaskManager/task_widget.dart';
import 'package:project/pages/Notifications/notification_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> taskList = [];
  final TextEditingController _taskController = TextEditingController();
  User? currentUser;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      fetchTasksFromFirestore();
    }
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          currentUser = user;
          fetchTasksFromFirestore();
        });
      } else {
        setState(() {
          currentUser = null;
          taskList.clear();
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void fetchTasksFromFirestore() async {
    if (currentUser == null) return;

    final formattedDate = _formatDate(_selectedDay);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .where('date', isEqualTo: formattedDate)
        .get();

    final tasks = snapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        id: doc.id,
        taskText: data['taskText'] ?? '',
        startTime: data['startTime'] != null
            ? (data['startTime'] as Timestamp).toDate()
            : null,
        endTime: data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : null,
        isDone: data['isDone'] ?? false,
      );
    }).toList();

    setState(() {
      taskList = tasks;
    });
  }

  void toggleTaskStatus(Task task) async {
    if (currentUser == null) return;

    setState(() {
      task.isDone = !task.isDone;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .doc(task.id)
        .update({'isDone': task.isDone});
  }

  void deleteTask(Task task) async {
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .doc(task.id)
        .delete();

    setState(() {
      taskList.remove(task);
    });
  }

  void addTask(String taskText, DateTime startTime, DateTime endTime) async {
    if (currentUser == null || taskText.isEmpty) return;

    final taskData = {
      'taskText': taskText,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isDone': false,
      'date': _formatDate(_selectedDay), // ✅ Save date string
    };

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .add(taskData);

    final newTask = Task(
      id: docRef.id,
      taskText: taskText,
      startTime: startTime,
      endTime: endTime,
      isDone: false,
    );

    setState(() {
      taskList.add(newTask);
    });

    _taskController.clear();
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
              title: const Text("Add New Task",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                        : "Start: ${selectedStartTime!.hour}:${selectedStartTime!.minute.toString().padLeft(2, '0')}"),
                    trailing: const Icon(Icons.timer, color: Colors.blue),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedStartTime = DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
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
                        : "End: ${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}"),
                    trailing: const Icon(Icons.timer_off, color: Colors.red),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedEndTime = DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
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
                  onPressed: () => Navigator.of(context).pop(),
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
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to see your tasks')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Task Manager",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              fetchTasksFromFirestore();
            },
            calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: taskList
                  .map((task) => TaskItem(
                        task: task,
                        onTaskChanged: toggleTaskStatus,
                        onDelete: deleteTask,
                      ))
                  .toList(),
            ),
          ),
        ],
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
