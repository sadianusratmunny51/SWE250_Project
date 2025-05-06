import 'package:flutter/material.dart';
import 'package:project/pages/TaskManager/task_model.dart';

class NotificationsPage extends StatefulWidget {
  final List<Task> taskList;

  const NotificationsPage({Key? key, required this.taskList}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    List<Task> upcomingTasks = widget.taskList
        .where((task) =>
            task.startTime != null && task.startTime!.isAfter(DateTime.now()))
        .toList();
    List<Task> pastTasks =
        widget.taskList.where((task) => task.isDone).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Upcoming Tasks"),
            Expanded(child: _buildNotificationList(upcomingTasks, Colors.blue)),
            const SizedBox(height: 20),
            _buildSectionTitle("Completed Tasks"),
            Expanded(child: _buildNotificationList(pastTasks, Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildNotificationList(List<Task> tasks, Color color) {
    return tasks.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text("No tasks found", style: TextStyle(color: Colors.white54)),
          )
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading: Icon(Icons.notifications, color: color),
                  title: Text(task.taskText,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Start: ${task.startTime != null ? "${task.startTime!.hour}:${task.startTime!.minute}" : "N/A"} | "
                    "End: ${task.endTime != null ? "${task.endTime!.hour}:${task.endTime!.minute}" : "N/A"}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
  }
}
