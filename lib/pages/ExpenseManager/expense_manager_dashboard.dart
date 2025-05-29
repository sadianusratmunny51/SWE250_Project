import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/ExpenseManager/expense_records.dart';
import 'package:project/pages/ExpenseManager/expense_reports_page.dart';
import 'package:project/pages/ExpenseManager/expense_chart_page.dart';
import 'package:table_calendar/table_calendar.dart';

class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  List<Map<String, dynamic>> expenses = [];
  double totalBudget = 0000.0;
  double dailyBudget = 0.0;

  void _addExpense(String type, double amount) {
    setState(() {
      expenses.add({"type": type, "amount": amount});
    });
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
            // Calendar on top
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.week,
              availableCalendarFormats: const {
                CalendarFormat.week: '1 Weeks',
              },
              daysOfWeekHeight: 20,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final today = DateTime.now();
                  final twoWeeksStart = focusedDay.subtract(Duration(days: 7));
                  final twoWeeksEnd = focusedDay.add(Duration(days: 6));

                  if (day.isBefore(twoWeeksStart) || day.isAfter(twoWeeksEnd)) {
                    return const SizedBox.shrink(); // Hide extra days
                  }

                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),

            // Budget boxes immediately below calendar
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
                              value: (expenses.fold(
                                          0.0, (sum, e) => sum + e['amount']) /
                                      (dailyBudget > 0 ? dailyBudget : 1))
                                  .clamp(0.0, 1.0),
                              backgroundColor: Colors.white24,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Remaining: ৳${(dailyBudget - expenses.fold(0.0, (sum, e) => sum + e['amount'])).toStringAsFixed(2)}",
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

            // Expense list fills remaining space
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
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
                    builder: (context) => RecordsPage(expenses: expenses),
                  ),
                );
              }),
              _buildNavItem(Icons.pie_chart, "Charts", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartPage(
                      monthlyBudget: totalBudget,
                      expenses: _convertExpensesToCategoryMap(expenses),
                    ),
                  ),
                );
              }),
              _buildNavItem(Icons.description, "Reports", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsPage(expenses: expenses),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _showAddExpenseDialog();
                  },
                  backgroundColor: const Color.fromARGB(255, 80, 72, 226),
                  icon: const Icon(Icons.add, color: Colors.black, size: 24),
                  label:
                      const Text("Add", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showAddExpenseDialog() {
    TextEditingController typeController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Expense",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Expense Type"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String type = typeController.text;
                  double? amount = double.tryParse(amountController.text);

                  if (type.isNotEmpty && amount != null) {
                    _addExpense(type, amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateBudgetDialog() {
    TextEditingController budgetController =
        TextEditingController(text: totalBudget.toString());

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
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredBudget = double.tryParse(budgetController.text);
                if (enteredBudget != null && enteredBudget > 0) {
                  setState(() {
                    totalBudget = enteredBudget;
                  });
                  Navigator.of(context).pop();
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
    TextEditingController budgetController =
        TextEditingController(text: dailyBudget.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update daily Budget"),
          content: TextField(
            controller: budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Daily Budget",
              prefixText: "৳",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredBudget = double.tryParse(budgetController.text);
                if (enteredBudget != null && enteredBudget > 0) {
                  setState(() {
                    dailyBudget = enteredBudget;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.yellow : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
