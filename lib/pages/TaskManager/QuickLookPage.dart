import 'package:flutter/material.dart';

class QuickLookPage extends StatelessWidget {
  const QuickLookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Quick Look",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatGrid(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard("Total Tasks", "8", Icons.numbers, Colors.green),
            _buildStatCard(
                "Completed Tasks", "3", Icons.check_circle, Colors.orange),
            _buildStatCard(
                "Left Tasks", "2", Icons.pending_actions, Colors.blue),
            _buildStatCard("Current Task", "1", Icons.play_arrow, Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        _buildUpcomingTasksSection(),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Upcoming Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250, // controls visible height of scrollable area
              child: ListView.builder(
                itemCount: 10, // replace with your dynamic count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text("Upcoming Task ${index + 1}"),
                    subtitle: const Text("Due soon"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
