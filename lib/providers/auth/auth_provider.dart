import 'package:flutter/material.dart';
import '../../models/user/user_model.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  User? user;

  // idea from lecture (make things seem fast muhehe)
  // track loading state to show spinning thingy while signing in
  // implementation in the screens section
  bool isLoading = false;

  // to store any error message
  String? errorMessage;

  // check if user is logged
  bool get isAuthenticated => user != null;

  Stream<firebase_auth.User?> get authStateChanges =>
      authService.authStateChanges;

  AuthProvider() {
    authService.authStateChanges.listen(onAuthStateChanged);
  }

  void onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      // means user is logged in
      user = User(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
    } else {
      user = null;
    }

    notifyListeners();
  }

  // signup
  Future<void> signUp({required String email, required String password}) async {
    setLoading(true);
    clearError();

    try {
      final currentUser = await authService.signUp(
        email: email,
        password: password,
      );

      user = currentUser;

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // sign in
  Future<void> signIn({required String email, required String password}) async {
    setLoading(true);
    clearError();

    try {
      final currentUser = await authService.signIn(
        email: email,
        password: password,
      );

      user = currentUser;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // sign out
  Future<void> signOut() async {
    setLoading(true);

    try {
      await authService.signOut();
      user = null;
      clearError();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // reset password
  // this will send a password reset email to the connected email
  Future<void> resetPassword({required String email}) async {
    setLoading(true);
    clearError();

    try {
      await authService.sendPasswordResetEmail(email: email);
      // successs
      setError('Password reset email sent. Please check your inbox.');
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // ==== HELPER METHODS ====
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
  }
}
