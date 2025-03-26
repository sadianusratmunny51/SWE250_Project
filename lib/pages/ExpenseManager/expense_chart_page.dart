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
        radius: 70,
        titleStyle: const TextStyle(
            color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
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
        backgroundColor: Colors.blueGrey,
        title: const Text("Percentage Calculator",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30), // Adds space from the top
            SizedBox(
              height: 250, // Reduce height to move it up
              child: PieChart(
                PieChartData(
                  sections: getSections(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 100), // Space between chart and legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    double totalSpent =
        widget.expenses.values.fold(0, (sum, amount) => sum + amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.expenses.entries.map((entry) {
        double percentage = (entry.value / totalSpent) * 100;

        return Padding(
          padding:
              const EdgeInsets.only(bottom: 10), // Add spacing between items
          child: Row(
            children: [
              Container(
                width: 14, // Increased size
                height: 14, // Increased size
                decoration: BoxDecoration(
                  color: getCategoryColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${entry.key} - ${percentage.toStringAsFixed(2)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Increase font size for better visibility
                  fontWeight: FontWeight.bold, // Make text bold
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
