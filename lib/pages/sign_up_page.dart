import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Screen/welcome_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required.";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _isLoading = false;
      });
      return;
    }
    bool isSpecial = false;
    bool isCapital = false;
    for (int i = 0; i < password.length; i++) {
      String ch = password[i];
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        isCapital = true;
      }
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        isSpecial = true;
      }
    }
    if (password.length < 8) {
      setState(() {
        _errorMessage = "Password must be at least 8 characters long.";
        _isLoading = false;
      });
      return;
    } else if (!isCapital || !isSpecial) {
      setState(() {
        _errorMessage = "Password must special characters and capital.";
        _isLoading = false;
      });
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);

        await userCredential.user!.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Registration successful! A verification email has been sent. Please verify your email to log in."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessageText;
      switch (e.code) {
        case 'weak-password':
          errorMessageText = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessageText = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessageText = 'The email address is not valid.';
          break;
        default:
          errorMessageText =
              e.message ?? "An unknown error occurred during registration.";
      }
      setState(() {
        _errorMessage = errorMessageText;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70, size: 24),
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF81D4FA), width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0F2027),
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1),
              const Icon(Icons.person_add_alt_1_rounded,
                  size: 90, color: Colors.white),
              SizedBox(height: size.height * 0.01),
              const Text(
                'Create Your Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join us to manage your tasks',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              _buildTextField(
                controller: _usernameController,
                hint: 'Username',
                icon: Icons.person_outline,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_reset_outlined,
                obscure: true,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 25),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, size.height * 0.065),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFF81D4FA),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
