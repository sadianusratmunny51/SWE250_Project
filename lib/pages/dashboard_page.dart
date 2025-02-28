import 'dart:async'; // Import for Timer
import 'dart:ui'; // Import for blur effect
import 'package:flutter/material.dart';
import 'package:project/pages/ExpenseManager/expense_manager_dashboard.dart';
import 'package:project/pages/TaskManager/task_list_page.dart';
import 'package:project/pages/Profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String displayText = ''; // Text that will be displayed in AppBar

  @override
  void initState() {
    super.initState();
    _animateText(); // Start the animation when the widget is initialized
  }

  // Method to animate text
  void _animateText() {
    const text = 'TrackEase Dashboard'; // The text to animate
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (index < text.length) {
        setState(() {
          displayText += text[index]; // Add one letter at a time
        });
        index++;
      } else {
        timer.cancel(); // Stop the timer once the text is fully displayed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(450),
        child: AppBar(
          title: Text(
            displayText, // Animated text in the AppBar
            style: const TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.red,
          ),
          flexibleSpace: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/back.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Glassmorphism Effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

              // Smaller Image on Top of the Background
              Positioned(
                top: 100,
                left: 50,
                right: 50,
                child: SizedBox(
                  width: 500,
                  height: 400,
                  child: Image.asset(
                    'assets/images/munni-img2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        // Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                    title: "Track Me",
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
                  _buildDashboardCard(
                    context,
                    icon: Icons.person,
                    title: "Profile",
                    color: Colors.deepPurpleAccent,
                    route: '/profile',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5), // Glow effect
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Card(
          color: Colors.transparent, // Keeps it aligned with the container
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
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
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
