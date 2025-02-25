import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;

  const ReportsPage({super.key, required this.expenses});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  double monthlyBudget = 0.0;
  double dailyBudget = 0.0;

  double getTotalExpenses() {
    return widget.expenses
        .fold(0.0, (sum, item) => sum + (item["amount"] as double));
  }

  void _showBudgetOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.white),
                title: const Text("Set Monthly Budget",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showBudgetDialog("Monthly Budget");
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.white),
                title: const Text("Set Daily Budget",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showBudgetDialog("Daily Budget");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetDialog(String budgetType) {
    TextEditingController budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set $budgetType"),
          content: TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter $budgetType amount"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  double amount = double.tryParse(budgetController.text) ?? 0.0;
                  if (budgetType == "Monthly Budget") {
                    monthlyBudget = amount;
                  } else {
                    dailyBudget = amount;
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = getTotalExpenses();
    double remainingMonthly = monthlyBudget - totalExpenses;
    double remainingDaily = dailyBudget - totalExpenses;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Reports", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatisticsSection("Monthly Statistics", remainingMonthly,
                monthlyBudget, totalExpenses),
            const SizedBox(height: 20),
            _buildStatisticsSection(
                "Daily Statistics", remainingDaily, dailyBudget, totalExpenses),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBudgetOptions,
        child: const Icon(Icons.edit),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  Widget _buildStatisticsSection(
      String title, double remaining, double budget, double expenses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Column(
            children: [
              _buildStatItem("Budget", budget.toStringAsFixed(2), Colors.blue),
              _buildStatItem(
                  "Expenses", expenses.toStringAsFixed(2), Colors.red),
              _buildStatItem(
                  "Remaining", remaining.toStringAsFixed(2), Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
