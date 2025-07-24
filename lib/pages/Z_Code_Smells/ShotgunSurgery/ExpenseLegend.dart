import 'package:flutter/material.dart';
import 'package:project/pages/Z_Code_Smells/ShotgunSurgery/CategoryColorHelper.dart';

class ExpenseLegend extends StatelessWidget {
  final Map<String, double> data;

  const ExpenseLegend({required this.data, super.key});

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final percent = (entry.value / total) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: CategoryColorHelper.getColor(entry.key),
              ),
              const SizedBox(width: 8),
              Text(
                _capitalize(entry.key),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Text(
                '(${percent.toStringAsFixed(1)}%)',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
