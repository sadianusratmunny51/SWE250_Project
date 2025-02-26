import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "Meeting with Team",
      "time": DateTime.now().add(Duration(hours: 2))
    },
    {
      "title": "Project Deadline",
      "time": DateTime.now().add(Duration(days: 1))
    },
    {
      "title": "Dentist Appointment",
      "time": DateTime.now().subtract(Duration(hours: 5))
    },
    {
      "title": "Flight to New York",
      "time": DateTime.now().add(Duration(hours: 10))
    },
    {
      "title": "Gym Session",
      "time": DateTime.now().subtract(Duration(days: 1))
    },
    {
      "title": "Dinner with Family",
      "time": DateTime.now().subtract(Duration(days: 2))
    },
    {
      "title": "Client Presentation",
      "time": DateTime.now().add(Duration(days: 3))
    },
    {"title": "Morning Run", "time": DateTime.now().add(Duration(hours: 8))},
    {
      "title": "Doctor Checkup",
      "time": DateTime.now().subtract(Duration(days: 3))
    },
    {"title": "Weekend Getaway", "time": DateTime.now().add(Duration(days: 5))},
  ];

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> pastNotifications =
        notifications.where((n) => n["time"].isBefore(now)).toList();
    List<Map<String, dynamic>> upcomingNotifications =
        notifications.where((n) => n["time"].isAfter(now)).toList();

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
            _buildSectionTitle("Upcoming Notifications"),
            Expanded(
                child:
                    _buildNotificationList(upcomingNotifications, Colors.blue)),
            const SizedBox(height: 20),
            _buildSectionTitle("Past Notifications"),
            Expanded(
                child: _buildNotificationList(pastNotifications, Colors.grey)),
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

  Widget _buildNotificationList(
      List<Map<String, dynamic>> notifications, Color color) {
    return notifications.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No notifications",
                style: TextStyle(color: Colors.white54)),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(), // Allow scrolling
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading: Icon(Icons.notifications, color: color),
                  title: Text(notification["title"],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "${notification["time"]}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
  }
}
