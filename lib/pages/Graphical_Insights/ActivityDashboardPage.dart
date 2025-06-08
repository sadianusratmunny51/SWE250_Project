import 'package:flutter/material.dart';

class ActivityDashboardPage extends StatelessWidget {
  const ActivityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Insights"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date Picker + Categorize
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateSelector(context),
                ElevatedButton(
                  onPressed: () => print("Categorize tapped"),
                  child: const Text("Categorize"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Today's Activity (horizontal scroll)
            const Text(
              "Today's Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _activityCard("Work", Icons.work, Colors.indigo),
                  _activityCard(
                      "Leisure", Icons.self_improvement, Colors.green),
                  _activityCard("Entertainment", Icons.movie, Colors.purple),
                  _activityCard(
                      "Sleep", Icons.bedtime_rounded, Colors.blueGrey),
                  _activityCard(
                      "Social Media", Icons.phone_android, Colors.pinkAccent),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // This Week's Productivity
            _sectionTitle("This Week's Productivity"),
            _chartPlaceholder(),

            const SizedBox(height: 32),

            // This Month's Productivity
            _sectionTitle("This Month's Productivity"),
            _chartPlaceholder(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _dateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // You can implement showDatePicker here
        print("Date Picker tapped");
      },
      child: Row(
        children: const [
          Icon(Icons.calendar_today, color: Colors.grey),
          SizedBox(width: 8),
          Text("Select Date", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _activityCard(String label, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _chartPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: Text("Chart goes here", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
