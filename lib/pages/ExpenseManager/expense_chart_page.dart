import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPage extends StatefulWidget {
  final double totalBudget;
  final Map<String, double> expenses; // Category -> Amount

  const ChartPage(
      {super.key, required this.totalBudget, required this.expenses});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<PieChartSectionData> getSections() {
    if (widget.totalBudget == 0 || widget.expenses.isEmpty) {
      // Show a full white chart when no data is available
      return [
        PieChartSectionData(
          color: Colors.white,
          value: 1,
          title: "",
          radius: 50,
        ),
      ];
    }

    double totalSpent =
        widget.expenses.values.fold(0, (sum, amount) => sum + amount);

    return widget.expenses.entries.map((entry) {
      double percentage = (entry.value / totalSpent) * 100;
      return PieChartSectionData(
        color: getCategoryColor(entry.key),
        value: percentage,
        title: "${percentage.toStringAsFixed(2)}%",
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();
  }

  Color getCategoryColor(String category) {
    Map<String, Color> categoryColors = {
      "Shopping": Colors.yellow,
      "Food": Colors.blue,
      "Entertainment": Colors.purple,
      "Transport": Colors.green,
      "Bills": Colors.red,
    };
    return categoryColors[category] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Expenses", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: getSections(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: widget.expenses.keys.map((category) {
        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: getCategoryColor(category),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(category, style: const TextStyle(color: Colors.white)),
          ],
        );
      }).toList(),
    );
  }
}
