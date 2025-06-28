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
    if (uid == null) {
      setState(() {
        totalTasks = 0;
        completedTasks = 0;
        leftTasks = 0;
        currentTask = null;
        upcomingTasks = [];
      });
      return;
    }

    final now = DateTime.now();

    final today = DateFormat('yyyy-MM-dd').format(now);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("tasks")
          .where("date", isEqualTo: today)
          .get();

      // Initialize counters
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

      // Sort upcoming tasks
      upcoming.sort((a, b) {
        final aStart = (a['startTime'] as Timestamp).toDate();
        final bStart = (b['endTime'] as Timestamp).toDate();
        return aStart.compareTo(bStart);
      });

      // Update the UI
      setState(() {
        totalTasks = total;
        completedTasks = completed;
        leftTasks = left;
        currentTask = current;
        upcomingTasks = upcoming;
      });
    } catch (e) {
      print("Error fetching tasks: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load tasks: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Quick Look",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatGrid(), // Grid
            const SizedBox(height: 25),
            _buildUpcomingTasksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 2;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            // Total Tasks Card
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                "Total Tasks",
                "$totalTasks",
                Icons.task_alt_outlined,
                const Color(0xFFFDD835),
                const Color(0xFFF9A825),
              ),
            ),
            // Completed Tasks Card
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                "Completed Tasks",
                "$completedTasks",
                Icons.check_circle_outline,
                const Color(0xFF66BB6A),
                const Color(0xFF388E3C),
              ),
            ),
            // Left Tasks Card
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                "Left Tasks",
                "$leftTasks",
                Icons.cancel_outlined,
                const Color(0xFFEF5350),
                const Color(0xFFD32F2F),
              ),
            ),
            // Current Task Card
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                "Current Task",
                currentTask ?? "No task active",
                Icons.play_circle_outline,
                currentTask != null
                    ? const Color(0xFF42A5F5)
                    : const Color(0xFF9E9E9E),
                currentTask != null
                    ? const Color(0xFF1976D2)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String content, IconData icon, Color color1, Color color2) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black), // Larger icon
          const SizedBox(height: 12),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF1A2A3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 0),
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),

          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.schedule, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Upcoming Tasks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Inner container
          Container(
            constraints: BoxConstraints(
              minHeight: upcomingTasks.isEmpty ? 100 : 0, // when empty
              maxHeight: 300, // Max height
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: upcomingTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No upcoming tasks scheduled",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: upcomingTasks.length,
                    itemBuilder: (context, index) {
                      final task = upcomingTasks[index];
                      final start = (task['startTime'] as Timestamp).toDate();
                      final end = (task['endTime'] as Timestamp).toDate();

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: -1,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle,
                                size: 10, color: Colors.blueAccent.shade100),
                            const SizedBox(width: 10),
                            Expanded(
                              // Allows text to take available space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['taskText'] ?? "Unnamed Task",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "From: ${DateFormat.jm().format(start)} To: ${DateFormat.jm().format(end)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70, // Muted white
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
