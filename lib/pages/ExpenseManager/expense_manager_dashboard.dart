import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/ExpenseManager/expense_records.dart';
import 'package:project/pages/ExpenseManager/expense_reports_page.dart';
import 'package:project/pages/ExpenseManager/expense_chart_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  String? uid;

  List<Map<String, dynamic>> expenses = [];
  double totalBudget = 0.0;

  // Track selected date for daily budget and expenses
  DateTime selectedDate = DateTime.now();

  // Daily budget per selected date
  double dailyBudget = 0.0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid;

    if (uid != null) {
      _fetchExpenses();
      _fetchDailyBudgetForDate(selectedDate);
      _fetchMonthlyBudgetForMonth(selectedDate);
    }
  }

  Map<String, double> _convertExpensesToCategoryMap(
      List<Map<String, dynamic>> expenses) {
    Map<String, double> categoryMap = {};
    for (var expense in expenses) {
      String category = expense['type'];
      double amount = expense['amount'];
      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
    }
    return categoryMap;
  }

  @override
  Widget build(BuildContext context) {
    // Filter expenses only for selectedDate
    final selectedDayExpenses = expenses.where((e) {
      final d = e['date'] as DateTime;
      return d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day;
    }).toList();

    final dailyExpensesSum =
        selectedDayExpenses.fold(0.0, (sum, e) => sum + e['amount']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "Expenses",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.blueGrey],
          ),
        ),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              calendarFormat: CalendarFormat.week,
              availableCalendarFormats: const {
                CalendarFormat.week: '1 Weeks',
              },
              daysOfWeekHeight: 20,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final twoWeeksStart =
                      focusedDay.subtract(const Duration(days: 7));
                  final twoWeeksEnd = focusedDay.add(const Duration(days: 6));
                  if (day.isBefore(twoWeeksStart) || day.isAfter(twoWeeksEnd)) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
                _fetchDailyBudgetForDate(selectedDay);
                _fetchExpenses();
                _fetchMonthlyBudgetForMonth(selectedDay);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showUpdateBudgetDialog,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.deepPurple[400],
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Monthly Budget",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text("৳${totalBudget.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (expenses.fold(
                                          0.0, (sum, e) => sum + e['amount']) /
                                      (totalBudget > 0 ? totalBudget : 1))
                                  .clamp(0.0, 1.0),
                              backgroundColor: Colors.white24,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Remaining: ৳${(totalBudget - expenses.fold(0.0, (sum, e) => sum + e['amount'])).toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _showUpdateDailyBudgetDialog,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.teal[400],
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Daily Budget",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text("৳${dailyBudget.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (dailyExpensesSum /
                                      (dailyBudget > 0 ? dailyBudget : 1))
                                  .clamp(0.0, 1.0),
                              backgroundColor: Colors.white24,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Remaining: ৳${(dailyBudget - dailyExpensesSum).toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedDayExpenses.length,
                itemBuilder: (context, index) {
                  final expense = selectedDayExpenses[index];
                  return Card(
                    color: Colors.white10,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on,
                          color: Colors.greenAccent),
                      title: Text(expense['type'],
                          style: const TextStyle(color: Colors.white)),
                      trailing: Text("৳${expense['amount'].toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.amber)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.receipt, "Records", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordsPage(),
                  ),
                );
              }),
              _buildNavItem(Icons.pie_chart, "Charts", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartPage(),
                  ),
                );
              }),
              _buildNavItem(Icons.description, "Reports", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsPage(),
                  ),
                );
              }),
              FloatingActionButton(
                onPressed: () {
                  _showAddExpenseDialog();
                },
                backgroundColor: const Color.fromARGB(255, 80, 151, 73),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    return MaterialButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _fetchExpenses() async {
    if (uid == null) return;

    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('expenses')
              .get();

      List<Map<String, dynamic>> fetchedExpenses = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'];
        DateTime date = timestamp is Timestamp
            ? timestamp.toDate()
            : DateTime.tryParse(timestamp.toString()) ?? DateTime.now();

        fetchedExpenses.add({
          'type': data['type'] ?? '',
          'amount': (data['amount'] ?? 0).toDouble(),
          'date': date,
        });
      }

      setState(() {
        expenses = fetchedExpenses;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching expenses: $e");
      }
    }
  }

  Future<void> _fetchDailyBudgetForDate(DateTime date) async {
    if (uid == null) return;

    final dayKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyBudgets')
        .doc(dayKey)
        .get();

    setState(() {
      dailyBudget = (doc.exists && doc.data()?['amount'] != null)
          ? (doc.data()!['amount'] as num).toDouble()
          : 0.0;
    });
  }

  Future<void> _fetchMonthlyBudgetForMonth(DateTime date) async {
    if (uid == null) return;

    final monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('monthlyBudgets')
        .doc(monthKey)
        .get();

    setState(() {
      totalBudget = (doc.exists && doc.data()?['amount'] != null)
          ? (doc.data()!['amount'] as num).toDouble()
          : 0.0;
    });
  }

  void _showAddExpenseDialog() {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Expense Type"),
              ),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Amount"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final type = typeController.text.trim();
                  final amount = double.tryParse(amountController.text.trim());
                  if (type.isNotEmpty &&
                      amount != null &&
                      amount > 0 &&
                      uid != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('expenses')
                        .add({
                      'type': type,
                      'amount': amount,
                      'date': Timestamp.fromDate(selectedDate),
                    });
                    Navigator.of(context).pop();
                    await _fetchExpenses();
                    await _fetchDailyBudgetForDate(selectedDate);
                    await _fetchMonthlyBudgetForMonth(selectedDate);

                    //  Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("Error adding expense: $e");
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateBudgetDialog() {
    TextEditingController budgetController =
        TextEditingController(text: totalBudget.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Monthly Budget"),
          content: TextField(
            controller: budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Monthly Budget",
              prefixText: "৳",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final enteredBudget =
                      double.tryParse(budgetController.text.trim());
                  if (enteredBudget != null &&
                      enteredBudget >= 0 &&
                      uid != null) {
                    final monthKey =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('monthlyBudgets')
                        .doc(monthKey)
                        .set({'amount': enteredBudget});
                    Navigator.of(context).pop();

                    await _fetchMonthlyBudgetForMonth(selectedDate);

                    //  Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("Error updating monthly budget: $e");
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDailyBudgetDialog() {
    TextEditingController dailyBudgetController =
        TextEditingController(text: dailyBudget.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Daily Budget"),
          content: TextField(
            controller: dailyBudgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Daily Budget",
              prefixText: "৳",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final enteredDailyBudget =
                      double.tryParse(dailyBudgetController.text.trim());
                  if (enteredDailyBudget != null &&
                      enteredDailyBudget >= 0 &&
                      uid != null) {
                    final dayKey =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('dailyBudgets')
                        .doc(dayKey)
                        .set({'amount': enteredDailyBudget});

                    Navigator.of(context).pop();

                    await _fetchDailyBudgetForDate(selectedDate);

                    //  Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("Error updating daily budget: $e");
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
