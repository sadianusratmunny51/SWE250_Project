import 'package:flutter/material.dart';
import 'package:project/Screen/welcome_screen.dart';
import 'package:project/pages/Z_Code_Smells/Login/AuthService.dart';
import 'package:project/pages/login.dart';

abstract class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    final error = await _authService.loginUser(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
