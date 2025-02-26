import 'package:flutter/material.dart';
import 'package:project/pages/dashboard_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  final List<String> texts = [
    "WELCOME",
    "TO",
    "TrackEase & Notify Application",
    "Press continue to start"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimations = List.generate(
      texts.length,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeIn),
        ),
      ),
    );

    _controller.forward();
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
            // Animated "WELCOME"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                texts[0].length,
                (index) => FadeTransition(
                  opacity: _fadeAnimations[0],
                  child: Text(
                    texts[0][index],
                    style: TextStyle(
                      fontSize: 55, // Increase size for "WELCOME"
                      fontWeight: FontWeight.w900, // Strong bold font
                      color: Colors.purpleAccent, // Unique color
                      letterSpacing: 5, // More spacing between letters
                      fontFamily: 'Cinzel', // Custom font (use a unique one)
                      shadows: [
                        Shadow(
                          color: Colors.purple.withOpacity(0.5), // Shadow color
                          blurRadius: 15, // Shadow blur
                          offset: Offset(5, 5), // Shadow offset
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Animated "TO"
            FadeTransition(
              opacity: _fadeAnimations[1],
              child: Text(
                texts[1],
                style: TextStyle(
                  fontSize: 35,
                  fontStyle: FontStyle.italic,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Animated "TrackEase & Notify Application"
            FadeTransition(
              opacity: _fadeAnimations[2],
              child: Text(
                texts[2],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.white30,
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animated "Press continue to start"
            FadeTransition(
              opacity: _fadeAnimations[3],
              child: Text(
                texts[3],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Animated Button
            FadeTransition(
              opacity: _fadeAnimations[3],
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
