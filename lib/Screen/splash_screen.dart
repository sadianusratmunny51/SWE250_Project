import 'package:flutter/material.dart';
import 'dart:async';
import 'package:project/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);

    //  Show immediate notification
    // NotificationService.showImmediateTestNotification();

    // final now = DateTime.now().add(const Duration(seconds: 8));
    // print(' Scheduling test notification for: $now');
    // NotificationService.scheduleNotification(
    //   id: 1,
    //   title: "Welcome!",
    //   body: "Scheduled notification working ",
    //   scheduledTime: now,
    // );

    //  Delay navigation to give time for scheduled notification
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Starting the Application",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLetter('L', 0),
                    _buildAnimatedLetter('O', 1),
                    _buildAnimatedLetter('A', 2),
                    _buildAnimatedLetter('D', 3),
                    _buildAnimatedLetter('I', 4),
                    _buildAnimatedLetter('N', 5),
                    _buildAnimatedLetter('G', 6),
                    _buildAnimatedLetter('.', 7),
                    _buildAnimatedLetter('.', 8),
                    _buildAnimatedLetter('.', 9),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLetter(String letter, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value * (index % 2 == 0 ? 1 : -1)),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
