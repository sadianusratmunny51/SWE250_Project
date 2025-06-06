import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class QuickLookPage extends StatefulWidget {
  const QuickLookPage({Key? key}) : super(key: key);

  @override
  State<QuickLookPage> createState() => _QuickLookPageState();
}

class _QuickLookPageState extends State<QuickLookPage> {
  int totalTasks = 0;
  int completedTasks = 0;
  int leftTasks = 0;
  String? currentTask;
  List<Map<String, dynamic>> upcomingTasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .where("date", isEqualTo: today)
        .get();

    final tasks = snapshot.docs.map((doc) => doc.data()).toList();
    int total = tasks.length;
    int completed = 0;
    int left = 0;
    String? current;
    List<Map<String, dynamic>> upcoming = [];

    for (var task in tasks) {
      final isDone = task['isDone'] == true;
      final start = (task['startTime'] as Timestamp).toDate();
      final end = (task['endTime'] as Timestamp).toDate();

      if (isDone) {
        completed++;
      } else if (end.isBefore(now)) {
        left++;
      } else if (now.isAfter(start) && now.isBefore(end)) {
        current ??= task['taskText'] ?? 'Unnamed Task';
      } else if (start.isAfter(now)) {
        upcoming.add(task);
      }
    }

    setState(() {
      totalTasks = total;
      completedTasks = completed;
      leftTasks = left;
      currentTask = current;
      upcomingTasks = upcoming;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Quick Look",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatGrid(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildStatCard(
                "Total Tasks", "$totalTasks", Icons.numbers, Colors.orange),
            _buildStatCard("Completed Tasks", "$completedTasks",
                Icons.check_circle, Colors.green),
            _buildStatCard(
                "Left Tasks", "$leftTasks", Icons.pending_actions, Colors.red),
            _buildStatCard(
              "Current Task",
              currentTask ?? "No task scheduled",
              Icons.play_arrow,
              currentTask != null ? Colors.blue : Colors.grey,
            ),
          ].map((card) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 42) /
                  2, // 2 columns with spacing
              child: card,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildUpcomingTasksSection(),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String content, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  "Upcoming Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: upcomingTasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No upcoming tasks",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: upcomingTasks.length,
                      itemBuilder: (context, index) {
                        final task = upcomingTasks[index];
                        final start = (task['startTime'] as Timestamp).toDate();
                        return Card(
                          color: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 0),
                          child: ListTile(
                            leading:
                                const Icon(Icons.task_alt, color: Colors.black),
                            title: Text(
                              task['taskText'] ?? "Unnamed Task",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              "Starts at ${DateFormat.jm().format(start)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
