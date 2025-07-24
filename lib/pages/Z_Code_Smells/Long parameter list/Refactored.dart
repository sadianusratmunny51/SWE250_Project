import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/pages/Graphical_Insights/ActivityDashboardPage.dart';
import 'package:project/pages/Graphical_Insights/SpendingsDasboard.dart';
import 'package:project/pages/Z_Code_Smells/Long%20parameter%20list/GlassBoxData.dart';

class GraphicalInsightsPage extends StatelessWidget {
  const GraphicalInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double boxSize = 140;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Graphical Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[600],
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [
              Color(0xFF1A237E),
              Colors.black87,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TOP: 4 chart containers grouped
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _chartBox(context, PieChartWidget(), "Pie Chart"),
                            _chartBox(context, BarChartWidget(), "Bar Chart"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _chartBox(
                                context, OgiveChartWidget(), "Ogive Chart"),
                            _chartBox(
                                context, AreaChartWidget(), "Mountain Chart"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTTOM BUTTONS
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _glassBox(GlassBoxData(
                    width: boxSize,
                    height: 180,
                    icon: Icons.access_time_filled,
                    title: "Analyze Activity",
                    colors: [
                      const Color.fromARGB(255, 190, 177, 225),
                      Colors.indigoAccent
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ActivityDashboardPage()),
                      );
                    },
                  )),
                  _glassBox(GlassBoxData(
                    width: boxSize,
                    height: 180,
                    icon: Icons.account_balance_wallet_rounded,
                    title: "Analyze Spendings",
                    colors: [
                      Colors.tealAccent.shade200,
                      Colors.greenAccent.shade400
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SpendingsDashboard()),
                      );
                    },
                  )),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _glassBox(GlassBoxData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: data.width,
            height: data.height,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.colors.map((c) => c.withOpacity(0.15)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.colors.last.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data.icon,
                    size: 40, color: data.colors.last.withOpacity(0.8)),
                const SizedBox(height: 20),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartBox(BuildContext context, Widget chart, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: chart),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(sections: [
        PieChartSectionData(value: 40, color: Colors.blueAccent),
        PieChartSectionData(value: 30, color: Colors.purpleAccent),
        PieChartSectionData(value: 15, color: Colors.tealAccent),
        PieChartSectionData(value: 15, color: Colors.orangeAccent),
      ]),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
              x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.purple)]),
          BarChartGroupData(
              x: 1, barRods: [BarChartRodData(toY: 3, color: Colors.indigo)]),
          BarChartGroupData(
              x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.teal)]),
        ],
      ),
    );
  }
}

class OgiveChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 10),
              FlSpot(2, 30),
              FlSpot(3, 50),
              FlSpot(4, 80),
              FlSpot(5, 100),
            ],
            isCurved: true,
            color: Colors.cyanAccent,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class AreaChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 6,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
            ],
            isCurved: true,
            color: Colors.greenAccent.withOpacity(0.7),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
