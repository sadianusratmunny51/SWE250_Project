import 'package:flutter/material.dart';
import 'package:project/pages/ExpenseManager/expense_records.dart';
import 'package:project/pages/ExpenseManager/expense_reports_page.dart';

class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  List<Map<String, dynamic>> expenses = []; // Stores expenses

  void _addExpense(String type, double amount) {
    setState(() {
      expenses.add({"type": type, "amount": amount});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keep background as before

      body: Column(
        children: const [
          SizedBox(height: 100), // Adjust space for better alignment
          Center(
            child: Text(
              "Expenses",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          Spacer(),
        ],
      ),

      // BottomAppBar with 3 items + FloatingActionButton as the 4th item
      bottomNavigationBar: BottomAppBar(
        color: Colors.black, // Matching background
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
              _buildNavItem(Icons.pie_chart, "Charts", false, () {}),
              _buildNavItem(Icons.description, "Reports", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportsPage(expenses: expenses), // Pass data if needed
                  ),
                );
              }),

              // FloatingActionButton positioned at the last place
              Padding(
                padding: const EdgeInsets.only(left: 20), // Keep the spacing
                child: FloatingActionButton(
                  onPressed: () {
                    _showAddExpenseDialog();
                  },
                  backgroundColor: const Color.fromARGB(255, 80, 72, 226),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add,
                      color: Color.fromARGB(255, 15, 15, 15), size: 30),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    Navigator.pop(context); // Close modal
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
