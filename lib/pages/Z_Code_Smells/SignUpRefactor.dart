import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Screen/welcome_screen.dart';

class SignUpRefactor extends StatefulWidget {
  const SignUpRefactor({super.key});

  @override
  State<SignUpRefactor> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpRefactor> {
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        confirmPassword.isEmpty) {
      _setError("All fields are required.");
      return false;
    }

    if (password != confirmPassword) {
      _setError("Passwords do not match.");
      return false;
    }

    return true;
  }

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}\$');
    if (!regex.hasMatch(password)) {
      _setError(
          "Password must include a capital letter and special character, and be at least 8 characters long.");
      return false;
    }
    return true;
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

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
            content: Text("Registration successful! Please verify your email."),
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
          errorMessageText = e.message ?? "An unknown error occurred.";
      }
      _setError(errorMessageText);
    } catch (e) {
      _setError("An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final password = _passwordController.text.trim();

    if (!_validateInputs()) return;
    if (!_validatePassword(password)) return;

    await _registerUser();

    setState(() {
      _isLoading = false;
    });
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join us to manage your tasks',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: size.height * 0.05),
              _buildTextField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.person_outline),
              const SizedBox(height: 18),
              _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true),
              const SizedBox(height: 18),
              _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_reset_outlined,
                  obscure: true),
              const SizedBox(height: 25),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, size.height * 0.065),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5))
                    : const Text('Sign Up',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Log in',
                        style: TextStyle(
                            color: Color(0xFF81D4FA),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
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
