import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state — used in main.dart StreamBuilder
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current signed-in user
  User? get currentUser => _auth.currentUser;

  // ─── SIGN IN ─────────────────────────────────────────────────
  // Returns null on success, error message string on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  // ─── SIGN UP ─────────────────────────────────────────────────
  // Returns null on success, error message string on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await cred.user?.updateDisplayName(fullName.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  // ─── SIGN OUT ────────────────────────────────────────────────
  Future<void> signOut() async => _auth.signOut();

  // ─── ERROR MESSAGES ──────────────────────────────────────────
  String _message(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
