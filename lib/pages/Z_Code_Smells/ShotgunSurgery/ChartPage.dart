import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/pages/Z_Code_Smells/ShotgunSurgery/ExpenseLegend.dart';
import 'package:project/pages/Z_Code_Smells/ShotgunSurgery/ExpensePieChart.dart';
import 'package:project/pages/Z_Code_Smells/ShotgunSurgery/ExpenseService.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  Map<String, double> _data = {};
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _data = await ExpenseService().fetchGroupedExpenses(_selectedDate);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Spending Chart",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}",
                        style: const TextStyle(
                            color: Colors.lightGreenAccent, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.amber),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                            _loadData();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _data.isEmpty
                      ? const Text("No expenses found",
                          style: TextStyle(color: Colors.white70))
                      : Expanded(child: ExpensePieChart(data: _data)),
                  const SizedBox(height: 16),
                  if (_data.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(child: ExpenseLegend(data: _data)),
                    ),
                ],
              ),
            ),
    );
  }
}
