import 'package:elbi_eats/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:elbi_eats/services/location_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
    
    // also check if user is already logged in (from previous session)
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('DEBUG: Already logged in user detected: ${currentUser.uid}');
      loadUserFromFirestore(currentUser.uid);
    }
  }

  void onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      // means user is logged in
      // fetch full user document from firestore
      loadUserFromFirestore(firebaseUser.uid);
    } else {
      user = null;
      notifyListeners();
    }
  }

  Future<void> loadUserFromFirestore(String uid) async {
    print('DEBUG: loadUserFromFirestore called for uid=$uid');
    try {
      final userDoc = await firestore.collection('users').doc(uid).get();
      print('DEBUG: userDoc.exists=${userDoc.exists}');

      if (userDoc.exists) {
        print('DEBUG: Raw data: ${userDoc.data()}');
        
        try {
          user = User.fromMap({
            ...userDoc.data() ?? {},
            'uid': uid,
          });
          print('DEBUG loadUserFromFirestore: isVerified=${user?.isVerified}, displayName=${user?.displayName}');
        } catch (parseError) {
          print('ERROR: Failed to parse user: $parseError');
          rethrow;
        }
        
        final token = await NotificationService().getToken();
        if (token != null) {
          await firestore.collection('users').doc(uid).update({
            'fcmTokens': FieldValue.arrayUnion([token]),
          });
        }

        await saveUserLocation(uid);

      } else {
        // fallback if doc doesnt exist
        user = User(uid: uid, email: '');
      }
      notifyListeners();
    } catch (e) {
      setError('Error loading user: $e');
      user = User(uid: uid, email: '');
      notifyListeners();
    }
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

  /// save user profile to firestore
  /// called after signup, during profile setup
  Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required List<String> selectedTags,
  }) async {
    setLoading(true);
    clearError();

    try {
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final now = DateTime.now();

      // create display name from firstName + lastName
      final displayName = '$firstName $lastName';

      // create username from email (everything before @)
      final username = user!.email.split('@')[0];

      // update user object locally
      user = user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        username: username,
        dateOfBirth: dateOfBirth,
        selectedTags: selectedTags,
        createdAt: now,
        updatedAt: now,
      );

      // write to firestore
      await firestore
          .collection('users')
          .doc(user!.uid)
          .set(
            user!.toMap(),
            SetOptions(
              merge: true,
            ), // merge: true means dont overwrite existing fields
          );

      notifyListeners();
    } catch (e) {
      setError('Failed to save profile: ${e.toString()}');
      rethrow; // re-throw so ProfileSetupPage can handle it
    } finally {
      setLoading(false);
    }
  }

  /// update verification status of a user
  Future<void> updateUserVerification(String verificationSelfieUrl) async {
    try {
      if (user == null) throw Exception('User not authenticated');

      await firestore.collection('users').doc(user!.uid).update({
        'isVerified': true,
        'verificationSelfieUrl': verificationSelfieUrl,
      });

      // update local user object
      final updatedUser = user!.copyWith(
        isVerified: true,
        verificationSelfieUrl: verificationSelfieUrl,
      );

      user = updatedUser;
      notifyListeners();
    } catch (e) {
      setError('Error updating verification: $e');
      rethrow;
    }
  }

  Future<void> updateUserSettings({
    required double discoveryRadius,
    required Map<String, bool> notificationPreferences,
  }) async {
    if (user == null) return;

    try {
      await firestore.collection('users').doc(user!.uid).update({
        'discoveryRadius': discoveryRadius,
        'notificationPreferences': notificationPreferences,
      });

      user = user!.copyWith(
        discoveryRadius: discoveryRadius,
        notificationPreferences: notificationPreferences,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
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

  // In your login/signup method after user is loaded:
  Future<void> saveUserLocation(String uid) async {
    final location = await LocationService().getCurrentLocation();
    await firestore.collection('users').doc(uid).update({
      'latitude': location?.latitude ?? 0,
      'longitude': location?.longitude ?? 0,
      'discoveryRadius': 5.0, // default 5km
    });
  }
}
