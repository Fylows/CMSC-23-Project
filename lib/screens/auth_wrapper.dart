import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth_provider.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'home_page.dart'; // Import the new HomePage

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Track which auth screen to show (signin or signup)
  bool showSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Use StreamBuilder to listen to firebase auth state
        return StreamBuilder(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Check if user is authenticated
            if (snapshot.hasData && snapshot.data != null) {
              // RETURN HomePage HERE, NOT HomeScreen
              return const HomePage();
            } else {
              return showSignUp
                  ? SignUpPage(
                      onSignInTapped: () {
                        setState(() {
                          showSignUp = false;
                        });
                      },
                    )
                  : SignInPage(
                      onSignUpTapped: () {
                        setState(() {
                          showSignUp = true;
                        });
                      },
                      onForgotPasswordTapped: () {
                        // TODO: navigate to forgot password screen
                      },
                    );
            }
          },
        );
      },
    );
  }
}