import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime selectedMonth = DateTime.now();
  double monthlyBudget = 0.0;
  List<Map<String, dynamic>> expenses = [];
  Map<String, double> dailyBudgets = {};
  String biggestCategory = '-';
  String leastCategory = '-';
  List<String> daysUnderBudget = [];
  List<String> daysOverBudget = [];
  double totalSpent = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
    fetchData();
  }

  Future<void> fetchData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    final monthKey = DateFormat('yyyy-MM').format(selectedMonth);
    final monthSnapshot =
        await userDoc.collection('monthlyBudgets').doc(monthKey).get();
    monthlyBudget = (monthSnapshot.data()?['amount'] ?? 0).toDouble();

    final dailyBudgetSnapshots = await userDoc.collection('dailyBudgets').get();
    dailyBudgets.clear();
    for (var doc in dailyBudgetSnapshots.docs) {
      final dateStr = doc.id; // yyyy-MM-dd
      final amount = (doc.data()['amount'] ?? 0).toDouble();
      dailyBudgets[dateStr] = amount;
    }

    final expenseSnapshots = await userDoc.collection('expenses').get();
    expenses = expenseSnapshots.docs.where((doc) {
      final data = doc.data();
      return data.containsKey('date') && data['date'] is Timestamp;
    }).map((doc) {
      final data = doc.data();
      return {
        'amount': (data['amount'] ?? 0).toDouble(),
        'category': data['category'] ?? 'Uncategorized',
        'date': (data['date'] as Timestamp).toDate(),
      };
    }).toList();

    _processData();
  }

  void _processData() {
    final monthExpenses = expenses.where((e) {
      final date = e['date'] as DateTime;
      return date.month == selectedMonth.month &&
          date.year == selectedMonth.year;
    }).toList();

    Map<String, double> categoryTotals = {};
    Map<String, double> dailyTotals = {};
    Map<String, DateTime> dateMap = {};

    for (var expense in monthExpenses) {
      final category = expense['category'];
      final amount = expense['amount'];
      final date = expense['date'];
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
      dateMap[dateKey] = date;
    }

    totalSpent = monthExpenses.fold(0.0, (sum, item) => sum + item['amount']);

    if (categoryTotals.isNotEmpty) {
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      biggestCategory = sorted.first.key;
      leastCategory = sorted.last.key;
    } else {
      biggestCategory = '-';
      leastCategory = '-';
    }

    daysUnderBudget.clear();
    daysOverBudget.clear();

    dailyTotals.forEach((key, total) {
      final date = dateMap[key]!;
      final label =
          "${DateFormat('EEEE').format(date)} (${DateFormat('MMM d').format(date)})";
      final dayBudget = dailyBudgets[key];

      if (dayBudget != null) {
        if (total > dayBudget) {
          daysOverBudget.add(label);
        } else {
          daysUnderBudget.add(label);
        }
      } else {
        daysUnderBudget.add("$label (no budget)");
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  Widget _monthDropdown() {
    return DropdownButton<DateTime>(
      value: selectedMonth,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      dropdownColor: Colors.black87,
      underline: Container(height: 1, color: Colors.white),
      items: List.generate(12, (index) {
        final now = DateTime.now();
        final month = DateTime(now.year, index + 1, 1);
        return DropdownMenuItem(
          value: month,
          child: Text(DateFormat('MMMM yyyy').format(month)),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedMonth = value;
            fetchData();
          });
        }
      },
    );
  }

  Widget _statusBar() {
    final isOver = totalSpent > monthlyBudget;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isOver ? Colors.red[700] : Colors.green[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isOver
            ? "Over Budgeted Month: ₹${totalSpent.toStringAsFixed(2)} / ₹${monthlyBudget.toStringAsFixed(2)}"
            : "Under Budgeted Month: ₹${totalSpent.toStringAsFixed(2)} / ₹${monthlyBudget.toStringAsFixed(2)}",
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoTile(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _scrollableDaysList(String title, List<String> items, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(items[i],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Reports",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _monthDropdown(),
                  _statusBar(),
                  Row(
                    children: [
                      _infoTile(
                          "Biggest Category", biggestCategory, Colors.orange),
                      _infoTile("Least Category", leastCategory, Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        _scrollableDaysList(
                            "Days Under Budget", daysUnderBudget, Colors.green),
                        const SizedBox(width: 8),
                        _scrollableDaysList(
                            "Days Over Budget", daysOverBudget, Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
