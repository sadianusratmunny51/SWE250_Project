import 'package:flutter/material.dart';

class QuickLookPage extends StatelessWidget {
  const QuickLookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Look'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildStatGrid(),
            const SizedBox(height: 16),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Good Morning,",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              "Alex!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Here’s your summary for today.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard("Tasks", "8", Icons.check_circle, Colors.green),
        _buildStatCard("Messages", "14", Icons.message, Colors.orange),
        _buildStatCard("Events", "2", Icons.calendar_today, Colors.blue),
        _buildStatCard("Alerts", "1", Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.event_available, color: Colors.blue),
          title: const Text("Meeting with HR"),
          subtitle: const Text("10:00 AM - Conference Room"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            // Add action here if needed
          },
        ),
        ListTile(
          leading: const Icon(Icons.task, color: Colors.green),
          title: const Text("Submit project report"),
          subtitle: const Text("Due today"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            // Add action here if needed
          },
        ),
      ],
    );
  }
}
