import 'package:flutter/material.dart';
import 'package:project/pages/ExpenseManager/expense_manager_dashboard.dart';
import 'package:project/pages/TaskManager/task_list_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220), // Increased height for the AppBar
        child: AppBar(
          title: const Text("TrackEase Dashboard"),
          backgroundColor: Colors.deepPurple,
          centerTitle: true, // Centers the title for a better layout
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.task,
                    title: "Task List",
                    color: Colors.orange,
                    route: '/tasks',
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: "Expenses",
                    color: Colors.green,
                    route: '/expense',
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.map,
                    title: "TrackMe",
                    color: Colors.blue,
                    route: '/trackme',
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Graph",
                    color: Colors.purple,
                    route: '/insights',
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.notifications,
                    title: "Notifications",
                    color: Colors.red,
                    route: '/reminders',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 30,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
