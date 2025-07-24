import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/pages/TaskManager/task_model.dart'; // Import your Task model

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Task> todayTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayTasks();
  }

  Future<void> fetchTodayTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .where('date', isEqualTo: todayDate)
        .get();

    final tasks = snapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        id: doc.id,
        taskText: data['taskText'] ?? '',
        isDone: data['isDone'] ?? false,
        startTime: data['startTime'] != null
            ? (data['startTime'] as Timestamp).toDate()
            : null,
        endTime: data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : null,
      );
    }).toList();

    setState(() {
      todayTasks = tasks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Notifications"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todayTasks.isEmpty
              ? const Center(child: Text("No tasks for today! 🎉"))
              : ListView.builder(
                  itemCount: todayTasks.length,
                  itemBuilder: (context, index) {
                    final task = todayTasks[index];
                    return ListTile(
                      title: Text(task.taskText),
                      subtitle: Text(
                          'Start: ${task.startTime?.hour}:${task.startTime?.minute.toString().padLeft(2, '0')}'),
                      trailing: Icon(
                        task.isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isDone ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
    );
  }
}
