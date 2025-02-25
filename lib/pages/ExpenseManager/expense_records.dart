import 'package:flutter/material.dart';

class RecordsPage extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const RecordsPage({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Records", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                "No expenses added",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  leading: const Icon(Icons.money, color: Colors.yellow),
                  title: Text(
                    expense["type"],
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    "-\$${expense["amount"].toString()}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
    );
  }
}
