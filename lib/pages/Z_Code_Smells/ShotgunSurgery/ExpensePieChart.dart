import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/Z_Code_Smells/ShotgunSurgery/CategoryColorHelper.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpensePieChart({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final percent = (entry.value / total) * 100;
          return PieChartSectionData(
            color: CategoryColorHelper.getColor(entry.key),
            value: entry.value,
            title: '${percent.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 50,
      ),
    );
  }
}
