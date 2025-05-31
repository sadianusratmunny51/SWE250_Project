import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> expenses = [];
  double? dailyBudget;
  double? monthlyBudget;
  bool loading = false;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        loading = true;
      });

      await _fetchData(pickedDate);

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchData(DateTime date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          expenses = [];
          dailyBudget = null;
          monthlyBudget = null;
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final monthKey = DateFormat('yyyy-MM').format(date);

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final expensesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final expenseList =
          expensesSnapshot.docs.map((doc) => doc.data()).toList();

      final dailySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('dailyBudgets')
          .doc(formattedDate)
          .get();

      final monthlySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('monthlyBudgets')
          .doc(monthKey)
          .get();

      setState(() {
        expenses = expenseList.cast<Map<String, dynamic>>();
        dailyBudget =
            dailySnapshot.exists && dailySnapshot.data()!.containsKey('amount')
                ? (dailySnapshot['amount'] as num).toDouble()
                : null;

        monthlyBudget = monthlySnapshot.exists &&
                monthlySnapshot.data()!.containsKey('amount')
            ? (monthlySnapshot['amount'] as num).toDouble()
            : null;
      });
    } catch (e) {
      print("Fetch error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "Records",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (selectedDate != null)
                Text(
                  "Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              const SizedBox(height: 8),
              if (selectedDate != null)
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Change Date"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              if (selectedDate == null) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 80,
                            color: Colors.greenAccent.withOpacity(0.8)),
                        const SizedBox(height: 20),
                        const Text(
                          "Welcome to your Records",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Select a date to view your daily expenses\nand budget summary",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("Open Calendar"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ] else if (loading) ...[
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              ] else ...[
                const SizedBox(height: 16),
                if (dailyBudget != null || monthlyBudget != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (dailyBudget != null)
                          _buildBudgetCard(
                            title: "Daily Budget",
                            amount: dailyBudget!,
                            color: Colors.greenAccent,
                            icon: Icons.calendar_today,
                          ),
                        if (monthlyBudget != null)
                          _buildBudgetCard(
                            title: "Monthly Budget",
                            amount: monthlyBudget!,
                            color: Colors.orangeAccent,
                            icon: Icons.date_range,
                          ),
                      ],
                    ),
                  ),
                const Divider(color: Colors.white24),
                expenses.isEmpty
                    ? const Text(
                        "No expenses for selected day.",
                        style: TextStyle(color: Colors.white70),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            final amount =
                                (expense['amount'] as num?)?.toDouble() ?? 0.0;
                            final type = expense['type'] ?? 'Unknown';
                            final description = expense['description'] ?? '';
                            final timestamp = expense['date'] as Timestamp?;
                            final time = timestamp != null
                                ? DateFormat('hh:mm a')
                                    .format(timestamp.toDate())
                                : '';

                            IconData icon;
                            Color iconColor;

                            switch (type.toLowerCase()) {
                              case 'food':
                                icon = Icons.fastfood;
                                iconColor = Colors.orange;
                                break;
                              case 'transport':
                                icon = Icons.directions_car;
                                iconColor = Colors.blue;
                                break;
                              case 'shopping':
                                icon = Icons.shopping_bag;
                                iconColor = Colors.purple;
                                break;
                              case 'entertainment':
                                icon = Icons.movie;
                                iconColor = Colors.redAccent;
                                break;
                              default:
                                icon = Icons.money;
                                iconColor = Colors.grey;
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: iconColor.withOpacity(0.2),
                                    child:
                                        Icon(icon, color: iconColor, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          type,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (description.isNotEmpty)
                                          Text(
                                            description,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "-\$${amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
