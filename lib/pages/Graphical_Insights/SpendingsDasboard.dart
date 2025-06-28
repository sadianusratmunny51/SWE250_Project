import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class SpendingsDashboard extends StatefulWidget {
  const SpendingsDashboard({super.key});

  @override
  State<SpendingsDashboard> createState() => _SpendingsDashboardState();
}

class _SpendingsDashboardState extends State<SpendingsDashboard> {
  DateTime _today = DateTime.now();
  Map<String, double?> weeklySpendings = {};
  Map<String, double> monthlyCategoryTotals = {};
  double monthlyBudget = 0.0;

  final List<String> dayLabels = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri'
  ];

  // Define the gradient colors for consistency
  final List<Color> _gradientColors = [
    const Color.fromARGB(255, 170, 155, 212),
    const Color.fromARGB(255, 122, 135, 209),
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime(_today.year, _today.month, 1);
    _loadWeeklySpendings();
    _loadMonthlyData(_today);
  }

  Future<void> _loadWeeklySpendings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    DateTime today = DateTime.now();
    int wd = today.weekday % 7;
    DateTime sat = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: wd + 1));
    DateTime fri = sat
        .add(const Duration(days: 6))
        .copyWith(hour: 23, minute: 59, second: 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sat))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(fri))
        .get();

    Map<String, double?> temp = {for (var d in dayLabels) d: 0.0};

    for (var doc in snapshot.docs) {
      final dt = (doc['date'] as Timestamp).toDate();
      final label = DateFormat.E().format(dt);
      final amt = (doc['amount'] as num).toDouble();
      temp[label] = (temp[label] ?? 0) + amt;
    }

    for (int i = 0; i < 7; i++) {
      final d = sat.add(Duration(days: i));
      final l = DateFormat.E().format(d);
      if (d.isAfter(today)) {
        temp[l] = null;
      } else {
        temp[l] = temp[l] ?? 0.0;
      }
    }

    setState(() {
      weeklySpendings = temp;
    });
  }

  Future<void> _loadMonthlyData(DateTime month) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    DateTime firstDay = DateTime(month.year, month.month, 1);
    DateTime lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    final budgetSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('monthlyBudgets')
        .doc("${month.year}-${month.month.toString().padLeft(2, '0')}")
        .get();

    Map<String, double> catTotals = {};
    for (var doc in snapshot.docs) {
      final type = (doc['type'] as String?)?.toLowerCase() ?? 'other';
      final amt = (doc['amount'] as num).toDouble();
      catTotals[type] = (catTotals[type] ?? 0) + amt;
    }

    setState(() {
      monthlyCategoryTotals = catTotals;
      monthlyBudget = (budgetSnap.data()?['amount'] ?? 0).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Analyze Spendings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("This Week Spendings",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors
                        .map((c) => c.withOpacity(0.15))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gradientColors.last.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildBarChart(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("This Month Spendings",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _monthPicker(),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientColors
                          .map((c) => c.withOpacity(0.15))
                          .toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gradientColors.last.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text("Budget: ₹${monthlyBudget.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white70)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors
                        .map((c) => c.withOpacity(0.15))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gradientColors.last.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(child: _buildCategoryPieChart()),
                    const SizedBox(height: 12),
                    Expanded(child: _buildCategoryDetailsList()),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCategoryDetailsList() {
    if (monthlyCategoryTotals.isEmpty) {
      return const Center(
        child: Text('No expense data available',
            style: TextStyle(color: Colors.white70)),
      );
    }

    final total = monthlyCategoryTotals.values.fold(0.0, (a, b) => a + b);

    return ListView(
      children: monthlyCategoryTotals.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = (amount / total) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category[0].toUpperCase() + category.substring(1),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                "₹${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _monthPicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showMonthPicker(
          context: context,
          initialDate: _today,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _today = DateTime(picked.year, picked.month, 1);
          });
          await _loadMonthlyData(_today);
          await _loadWeeklySpendings();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _gradientColors.map((c) => c.withOpacity(0.15)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gradientColors.last.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month, color: Colors.white70),
                const SizedBox(width: 10),
                Text(DateFormat.yMMMM().format(_today),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final groups = List.generate(dayLabels.length, (i) {
      final label = dayLabels[i];
      final amt = weeklySpendings[label];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: amt ?? 0,
            color: amt == null ? Colors.grey.shade800 : Colors.deepPurpleAccent,
            width: 16,
          )
        ],
      );
    });

    return BarChart(
      BarChartData(
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        barGroups: groups,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: const BorderSide(color: Colors.transparent),
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: -12.0,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = dayLabels[group.x.toInt()];
              final value = rod.toY;

              if (weeklySpendings[label] == null || value == 0) {
                return null;
              }

              return BarTooltipItem(
                value.toStringAsFixed(1),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    return Text(dayLabels[idx],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12));
                  })),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (monthlyCategoryTotals.isEmpty) {
      return const Center(
        child: Text('No data for pie chart',
            style: TextStyle(color: Colors.white70)),
      );
    }
    final total = monthlyCategoryTotals.values.fold(0.0, (a, b) => a + b);
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal
    ];
    int i = 0;
    final sections = monthlyCategoryTotals.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[i++ % colors.length],
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 50,
        sectionsSpace: 1,
      ),
    );
  }
}
