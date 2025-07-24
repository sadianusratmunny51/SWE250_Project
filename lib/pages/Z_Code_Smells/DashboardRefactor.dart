import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardRefactor extends StatefulWidget {
  const DashboardRefactor({super.key});

  @override
  _DashboardRefactorState createState() => _DashboardRefactorState();
}

class _DashboardRefactorState extends State<DashboardRefactor> {
  String displayText = '';
  String descriptionText = '';
  String line1Text = '';
  String line2Text = '';
  int _currentBackgroundIndex = 0;

  final List<String> _backgroundImages = [
    'assets/images/back1.png',
    'assets/images/back2.png',
    'assets/images/back44.png',
    'assets/images/back3.jpg',
  ];

  final List<String> _backgroundDescriptions = [
    'Track your Location',
    'Schedule your Tasks',
    'Summarize your spendings',
    'Analyze your performance',
  ];

  @override
  void initState() {
    super.initState();
    _animateTextEffect(
        'TrackEase Dashboard', (text) => displayText = text, 300);
    _animateTextEffect(_backgroundDescriptions[_currentBackgroundIndex],
        (text) => descriptionText = text, 150);
    _animateTextEffect('Empower your day', (text) => line1Text = text, 300);
    _animateTextEffect('organize your life', (text) => line2Text = text, 300);
    _startBackgroundRotation();
  }

  void _animateTextEffect(
      String fullText, void Function(String) updateState, int duration) {
    int index = 0;
    Timer.periodic(Duration(milliseconds: duration), (timer) {
      if (index < fullText.length) {
        setState(() {
          updateState(fullText.substring(0, index + 1));
        });
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  void _startBackgroundRotation() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentBackgroundIndex =
            (_currentBackgroundIndex + 1) % _backgroundImages.length;
        _animateTextEffect(_backgroundDescriptions[_currentBackgroundIndex],
            (text) => descriptionText = text, 150);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(450),
        child: AppBar(
          title: Text(
            displayText,
            style: const TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.red),
          flexibleSpace: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: Image.asset(
                    _backgroundImages[_currentBackgroundIndex],
                    key: ValueKey<String>(
                        _backgroundImages[_currentBackgroundIndex]),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: -140,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      line1Text,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -8,
                left: 140,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      line2Text,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 150,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    descriptionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
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
                  _buildDashboardCard(context,
                      icon: Icons.task,
                      title: "Task List",
                      color: Colors.orange,
                      route: '/tasks'),
                  _buildDashboardCard(context,
                      icon: Icons.account_balance_wallet,
                      title: "Expenses",
                      color: Colors.green,
                      route: '/expense'),
                  _buildDashboardCard(context,
                      icon: Icons.map,
                      title: "Track Me",
                      color: Colors.blue,
                      route: '/trackme'),
                  _buildDashboardCard(context,
                      icon: Icons.bar_chart,
                      title: "Graph",
                      color: Colors.purple,
                      route: '/insights'),
                  _buildDashboardCard(context,
                      icon: Icons.person,
                      title: "Profile",
                      color: Colors.deepPurpleAccent,
                      route: '/profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required String route}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Card(
          color: Colors.transparent,
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
