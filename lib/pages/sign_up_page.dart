import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Screen/welcome_screen.dart'; // Make sure this path is correct
// No need to import sign_up_page here as we are in sign_up_page itself
// import 'package:project/services/notification_service.dart'; // Not directly used in UI
// import 'package:project/widgets/google_map.dart'; // Not directly used in UI

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
  String? _errorMessage; // To display custom error messages

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to handle user registration
  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _errorMessage = null; // Clear previous error messages
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    // Input validation
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

    // Password strength check (example: minimum 6 characters)
    if (password.length < 6) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters long.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Create user with email and password using Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Show success confirmation SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Registration successful! A verification email has been sent. Please verify your email to log in."),
            backgroundColor: Colors.green, // Green for success
            duration: Duration(seconds: 5), // Show for a longer duration
          ),
        );

        // Clear form fields after successful registration
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Optionally navigate back to login after showing message
        // Navigator.pop(context); // Go back to login after successful registration
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication exceptions
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
      // Catch any other unexpected errors
      setState(() {
        _errorMessage = "An unexpected error occurred: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Helper method to build text input fields with elegant styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false, // Default to false
    TextInputType keyboardType = TextInputType.text, // Default keyboard type
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.15), // Slightly more opaque for better contrast
        borderRadius: BorderRadius.circular(15), // More rounded corners
        boxShadow: [
          // Subtle shadow for depth
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
        style: const TextStyle(
            color: Colors.white, fontSize: 16), // Standard TextStyle
        cursorColor: Colors.white, // White cursor for visibility
        keyboardType: keyboardType, // Set keyboard type
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.white54), // Standard TextStyle for hint
          prefixIcon: Icon(icon,
              color: Colors.white70, size: 24), // Slightly larger icon
          filled: false, // Fill color is on the Container now
          contentPadding: const EdgeInsets.symmetric(
              vertical: 18, horizontal: 20), // More padding
          border: InputBorder
              .none, // No border, as container provides the background
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            // Subtle border on focus
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
                color: Color(0xFF81D4FA),
                width: 1.5), // Highlight color on focus
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size; // Get screen size for responsive design

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents resizing when keyboard appears
      // FIX: Set a background color for the Scaffold to prevent white gaps
      backgroundColor:
          const Color(0xFF0F2027), // Matches the darkest gradient color
      body: Container(
        width: double.infinity,
        height: size.height, // Set height to full screen height
        decoration: const BoxDecoration(
          // Elegant gradient background, consistent with LoginPage
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08), // Responsive horizontal padding
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1), // Top spacing
              // App Icon/Logo for Sign Up
              const Icon(Icons.person_add_alt_1_rounded,
                  size: 90,
                  color: Colors.white), // Appropriate icon for sign-up
              SizedBox(height: size.height * 0.01),

              // Title and Subtitle
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
              SizedBox(
                  height: size.height * 0.05), // Spacing before text fields

              // Username Text Field
              _buildTextField(
                controller: _usernameController,
                hint: 'Username',
                icon: Icons.person_outline,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 18), // Spacing between fields

              // Email Text Field
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18), // Spacing between fields

              // Password Text Field
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 18), // Spacing between fields

              // Confirm Password Text Field
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons
                    .lock_reset_outlined, // Different icon for confirm password
                obscure: true,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 25), // Spacing before error message/button

              // Error Message Display
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

              // Sign Up Button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _register, // Disable button while loading
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF4FC3F7), // Bright elegant blue
                  foregroundColor: Colors.black, // Dark text for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // More rounded corners
                  ),
                  minimumSize: Size(double.infinity,
                      size.height * 0.065), // Responsive height
                  elevation: 8, // Subtle shadow
                  shadowColor: Colors.black.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black, // Color of the loading indicator
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600, // Slightly bolder text
                        ),
                      ),
              ),
              SizedBox(
                  height: size.height *
                      0.04), // Spacing before "Already have an account?"

              // "Already have an account?" section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login page
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFF81D4FA), // Lighter, complementary blue
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.05), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
