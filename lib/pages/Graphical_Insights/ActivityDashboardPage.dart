import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/pages/Graphical_Insights/WeeklyProductivityChart.dart';

class ActivityDashboardPage extends StatefulWidget {
  const ActivityDashboardPage({super.key});

  @override
  State<ActivityDashboardPage> createState() => _ActivityDashboardPageState();
}

class _ActivityDashboardPageState extends State<ActivityDashboardPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, Duration> categoryDurations = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryDurationsFromFirestore();
  }

  Future<List<Map<String, dynamic>>> _fetchDoneTasksByDate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .where("isDone", isEqualTo: true)
        .where("date", isEqualTo: dateStr)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _loadCategoryDurationsFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySummaries')
        .doc(dateStr)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      Map<String, Duration> loadedDurations = {};
      for (var entry in data.entries) {
        if (entry.key != 'date' && entry.key != 'updatedAt') {
          loadedDurations[_toTitleCase(entry.key)] =
              Duration(minutes: (entry.value as int));
        }
      }
      setState(() {
        categoryDurations = loadedDurations;
      });
    } else {
      setState(() {
        categoryDurations = {};
      });
    }
  }

  void _pickDate() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Dark theme for date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple.shade300,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[850],
          ),
          child: child!,
        );
      },
    );
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
      await _loadCategoryDurationsFromFirestore();
    }
  }

  void _handleCategoryTap(String category) async {
    final tasks = await _fetchDoneTasksByDate();

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No completed tasks found for selected date.")),
      );
      return;
    }

    final selectedTasks = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) {
        final selected = <Map<String, dynamic>>[];
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Select tasks for '$category'",
              style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final start = (task["startTime"] as Timestamp).toDate();
                final end = (task["endTime"] as Timestamp).toDate();
                return StatefulBuilder(
                  builder: (context, setState) => CheckboxListTile(
                    activeColor: Colors.deepPurpleAccent,
                    title: Text(
                        "${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}",
                        style: const TextStyle(color: Colors.white70)),
                    subtitle: Text(task['taskText'],
                        style: const TextStyle(color: Colors.white60)),
                    value: selected.contains(task),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(task);
                        } else {
                          selected.remove(task);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text("Done",
                  style: TextStyle(color: Colors.deepPurpleAccent)),
            )
          ],
        );
      },
    );

    if (selectedTasks != null && selectedTasks.isNotEmpty) {
      Duration total = Duration.zero;
      for (final task in selectedTasks) {
        final start = (task["startTime"] as Timestamp).toDate();
        final end = (task["endTime"] as Timestamp).toDate();
        total += end.difference(start);
      }

      setState(() {
        categoryDurations[category] = total;
      });

      await _saveCategoryToFirestore(category, total);
    }
  }

  Future<void> _saveCategoryToFirestore(
      String category, Duration duration) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final minutes = duration.inMinutes;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dailySummaries')
          .doc(dateStr)
          .set({
        category.toLowerCase(): minutes,
        'date': dateStr,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved $minutes minutes to '$category'")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving '$category': $e")),
      );
    }
  }

  String _toTitleCase(String input) {
    return input
        .split(' ')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(
          0xFF1E1E2C), // Dark elegant background with a hint of blue/purple
      appBar: AppBar(
        title: const Text("Activity Insights"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Today's Activity Title
            const Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Activity Cards Horizontal Scroll
            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _activityCard(
                    "Work",
                    Icons.work,
                    colors: [
                      const Color.fromARGB(255, 100, 152, 255),
                      Colors.blueAccent
                    ],
                  ),
                  _activityCard(
                    "Leisure",
                    Icons.self_improvement,
                    colors: [
                      Colors.tealAccent.shade200,
                      Colors.greenAccent.shade400
                    ],
                  ),
                  _activityCard(
                    "Etertainment",
                    Icons.movie,
                    colors: [
                      Colors.pink,
                      const Color.fromARGB(255, 252, 29, 252)
                    ],
                  ),
                  _activityCard(
                    "Sleep",
                    Icons.night_shelter,
                    colors: [
                      const Color.fromARGB(255, 210, 224, 19),
                      const Color.fromARGB(255, 218, 161, 17)
                    ],
                  ),
                  _activityCard(
                    "Social Media",
                    Icons.mobile_friendly,
                    colors: [
                      const Color.fromARGB(255, 12, 231, 235),
                      const Color.fromARGB(255, 90, 218, 241)
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // This Week's Productivity Section Title + Graph Container
            _sectionTitle("This Week's Productivity"),
            const SizedBox(
                height: 16), // Added gap here between title and graph container
            //padding: const EdgeInsets.all(16),
            const WeeklyProductivityChart(),
            // Container(
            //   decoration: BoxDecoration(
            //     color: const Color.fromARGB(255, 172, 141, 226)
            //         .withOpacity(0.25), // Transparent elegant color
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: const [
            //       BoxShadow(
            //         color: Colors.black54,
            //         blurRadius: 12,
            //         offset: Offset(0, 6),
            //       ),
            //     ],
            //   ),
            //   padding: const EdgeInsets.all(16),
            //   child: const WeeklyProductivityChart(),
            // ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(String label, IconData icon,
      {required List<Color> colors}) {
    final duration = categoryDurations[label];
    final durationStr = duration != null
        ? "${duration.inHours}h ${duration.inMinutes.remainder(60)}m"
        : "Tap to review";

    return GestureDetector(
      onTap: () => _handleCategoryTap(label),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.18)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: colors.last.withOpacity(0.85)),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  durationStr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}
