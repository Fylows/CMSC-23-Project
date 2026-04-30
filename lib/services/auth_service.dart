import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // added an alias since 'User' in firebase_auth is conflicting with our 'User' model
import 'package:elbi_eats/models/user_model.dart';

class AuthService {
  static final auth = firebase_auth.FirebaseAuth.instance;

  // listen to firebase
  Stream<firebase_auth.User?> get authStateChanges {
    return auth.authStateChanges();
  }

  // get currently logged in user
  firebase_auth.User? get currentFirebaseUser {
    return auth.currentUser;
  }

  // signup
  Future<User> signUp({ required String email, required String password}) async {
    try {
      // create account on firebase
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Failed to create user");
      }

      // convert to user model
      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw handleAuthException(e); // check bottom for what this fn is
    }
  }

  // sign-in
  Future<User> signIn({
    required String email,
    required String password
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in');
      }

      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // sign-out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // reset password
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // HELPER FUNCTION TO SIMPLIFY CREATION OF AUTH ERROR MESSAGES (dump yall's code here)
  // for the user to see ofcourse
  // see https://firebase.google.com/docs/auth/admin/errors for documentation
  String handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'Email not found. Please sign up';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      default:
        return 'An error occured: ${e.message}';
    }
  }
}