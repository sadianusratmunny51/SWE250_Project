import 'package:flutter/material.dart';

class ChartPage extends StatelessWidget {
  final double monthlyBudget;
  final Map<String, double> expenses;

  const ChartPage({
    Key? key,
    required this.monthlyBudget,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalExpenses = expenses.values.fold(0, (a, b) => a + b);
    double remaining = monthlyBudget - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Chart'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Monthly Budget: ৳${monthlyBudget.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20)),
            Text('Total Expenses: ৳${totalExpenses.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20)),
            Text('Remaining: ৳${remaining.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: expenses.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text('৳${entry.value.toStringAsFixed(2)}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
