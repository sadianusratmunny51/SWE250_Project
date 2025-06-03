import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

final List<Color> _availableColors = [
  Colors.cyan,
  Colors.teal,
  Colors.amber,
  Colors.deepOrange,
  Colors.indigo,
  Colors.lightGreen,
  Colors.pinkAccent,
  Colors.deepPurple,
  Colors.lime,
  Colors.brown,
  Colors.blueGrey,
  Colors.lightBlue,
  Colors.greenAccent,
  Colors.red,
  Colors.yellow,
  Colors.orangeAccent,
  Colors.indigoAccent,
  Colors.blue,
  Colors.tealAccent,
  Colors.purpleAccent,
  Colors.cyanAccent,
  Colors.grey,
  Colors.purple,
  Colors.green,
  Colors.lightGreenAccent,
  Colors.deepOrangeAccent,
  Colors.black,
  Colors.white10,
  Colors.blueAccent,
  Colors.pink,
];

final Map<String, Color> _categoryColorMap = {};

class _ChartPageState extends State<ChartPage> {
  Map<String, double> categoryTotals = {};
  bool loading = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final rawExpenses = snapshot.docs.map((doc) => doc.data()).toList();

      final grouped = _groupExpensesByCategory(rawExpenses);

      setState(() {
        categoryTotals = grouped;
        loading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
      setState(() => loading = false);
    }
  }

  Map<String, double> _groupExpensesByCategory(
      List<Map<String, dynamic>> rawExpenses) {
    final Map<String, double> grouped = {};

    for (var expense in rawExpenses) {
      final type =
          (expense['type'] as String?)?.toLowerCase().trim() ?? 'others';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;

      if (grouped.containsKey(type)) {
        grouped[type] = grouped[type]! + amount;
      } else {
        grouped[type] = amount;
      }
    }

    return grouped;
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase().trim();

    if (_categoryColorMap.containsKey(lower)) {
      return _categoryColorMap[lower]!;
    }

    final usedColors = _categoryColorMap.values.toSet();
    final available = _availableColors.firstWhere(
      (color) => !usedColors.contains(color),
      orElse: () => Colors.grey,
    );

    _categoryColorMap[lower] = available;
    return available;
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    final totalSpent = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "Spending Chart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date display + calendar picker button — always visible
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                        style: const TextStyle(
                            color: Colors.lightGreenAccent, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.amber),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: Colors.green,
                                    onPrimary: Colors.black,
                                    surface: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: Colors.black,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                            _fetchExpenses();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  categoryTotals.isEmpty
                      ? const Center(
                          child: Text(
                            "No expenses found for selected date.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: categoryTotals.entries.map((entry) {
                                final totalSpent = categoryTotals.values
                                    .fold(0.0, (sum, val) => sum + val);
                                final percentage =
                                    (entry.value / totalSpent) * 100;
                                return PieChartSectionData(
                                  color: _getCategoryColor(entry.key),
                                  value: entry.value,
                                  title: '${percentage.toStringAsFixed(1)}%',
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Legend only if data exists
                  if (categoryTotals.isNotEmpty)
                    SizedBox(
                      height: 200, // Set max height for scrollable area
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categoryTotals.entries.map((entry) {
                            final totalSpent = categoryTotals.values
                                .fold(0.0, (sum, val) => sum + val);
                            final percentage = (entry.value / totalSpent) * 100;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: _getCategoryColor(entry.key),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _capitalize(entry.key),
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${percentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
