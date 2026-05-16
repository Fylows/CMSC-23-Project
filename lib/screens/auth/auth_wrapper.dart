import 'package:elbi_eats/screens/auth/profile_setup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  //track which auth screen to show (signin or signup)
  bool showSignUp = false;
  bool showForgotPassword = false;
  bool showProfileSetup = false;

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
              // profile setup first if signup
              if (showProfileSetup) {
                return ProfileSetupPage(
                  onComplete: () {
                    setState(() {
                      showProfileSetup = false;
                    });
                    // then navigate to home
                    // NOTE: this sijust a placeholder
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/home');
                    });
                  },
                );
              }

              // go to home
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/home');
              });
              return const Scaffold(backgroundColor: Colors.white);
            } else {
              return showForgotPassword
                ? ForgotPasswordPage(
                  onSignInTapped: () {
                    setState(() {
                      showForgotPassword = false;
                    });
                  },
                )
                : showSignUp
                  ? SignUpPage(
                    onSignInTapped: () {
                      setState(() {
                        showSignUp = false;
                      });
                    },
                    onProfileSetupNeeded: () {
                      setState(() {
                        showProfileSetup = true;
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
                      // UPDATE: already implemented; comment can be removed
                      setState(() {
                        showForgotPassword = true;
                      });

                    },
                  );
            }
          },
        );
      },
    );
  }
}

// TODO: create homescreen
// this is just a placeholder home screen for testing
// repalce this with actual homescreen later
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
            }, 
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Elbi Eats!'),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Text(
                  'User: ${authProvider.user?.email ?? 'Unknown'}',
                );
              }
            ),
            const SizedBox(height:  16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
              }, 
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}

