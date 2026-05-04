import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  //track which auth screen to show (signin or signup)
  bool showSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // use streambuilder to listen to firebase auth state
        return StreamBuilder(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
            // check if user is authenticated
            if (snapshot.hasData && snapshot.data != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/home');
              });
              return const Scaffold(
                backgroundColor: Colors.white,
              ); // return empty scaffold while navigating to home screen
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
