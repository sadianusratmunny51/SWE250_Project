import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyProductivityChart extends StatefulWidget {
  const WeeklyProductivityChart({super.key});

  @override
  State<WeeklyProductivityChart> createState() =>
      _WeeklyProductivityChartState();
}

class _WeeklyProductivityChartState extends State<WeeklyProductivityChart> {
  List<BarChartGroupData> _barGroups = [];
  List<String> _weekdays = [];

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: (now.weekday % 7 + 1) % 7));

    final List<BarChartGroupData> groups = [];
    final List<String> labels = [];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dailySummaries')
          .doc(dateStr)
          .get();

      double productivity = 0;
      if (doc.exists) {
        final data = doc.data()!;
        final sleep = (data['sleep'] ?? 0) as int;
        final work = (data['work'] ?? 0) as int;
        final awake = (24 * 60) - sleep;
        if (awake > 0) {
          productivity = (work / awake) * 100;
        }
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: productivity,
              color: Colors.deepPurple,
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
      labels.add(DateFormat.E().format(date)); // Mon, Tue, etc.
    }

    setState(() {
      _barGroups = groups;
      _weekdays = labels;
    });
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    if (_barGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final spots = List<FlSpot>.generate(
      _barGroups.length,
      (index) => FlSpot(index.toDouble(), _barGroups[index].barRods[0].toY),
    );

    final List<Color> gradientColors = [
      const Color.fromARGB(255, 170, 155, 212),
      const Color.fromARGB(255, 122, 135, 209),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.15)).toList(),
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
                color: gradientColors.last.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _weekdays.length)
                          return Container();
                        return Text(
                          _weekdays[idx],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        "${value.toInt()}%",
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.deepPurpleAccent,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurpleAccent.withOpacity(0.3),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
