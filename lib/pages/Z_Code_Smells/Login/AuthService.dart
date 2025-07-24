import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          return null; // success, no error
        } else {
          await _auth.signOut();
          return 'Please verify your email first.';
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? "Unknown error occurred.";
      }
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
    return "Login failed.";
  }
}
