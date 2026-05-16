import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback? onSignInTapped;

  const ForgotPasswordPage({
    this.onSignInTapped,
    super.key
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  String? emailError;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// validate email input
  /// TODO: maybe use a package for a more robust validation (same as other screens wip)
  bool validateEmail() {
    setState(() {
      emailError = null;
    });

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      return false;
    } else if (!emailController.text.contains('@')) {
      setState(() {
        emailError = 'Please enter a valid email';
      });
      return false;
    }

    return true;
  }

  /// Handle password reset
  Future<void> handleResetPassword(AuthProvider authProvider) async {
    if (!validateEmail()) {
      return;
    }

    await authProvider.resetPassword(
      email: emailController.text.trim()
    );

    // show success mess (stored in authProvider.message)
    // user should be able to see the confirmation
    // on the screen
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    // gradient background
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFA5800),
                            Color(0xFFCB2020),
                          ],
                        ),
                      ),
                    ),

                    // TODO: logo or some food illustration overlay
                    // should replace this with an actual image asset later
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          Icons.restaurant,
                          size: 200,
                          color: Colors.white.withValues(alpha: 0.2), // withOpacity is deprecated
                        ),
                      ),
                    ),

                    // text content on top of gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 90, // TODO: check if 90 or 40 better
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title
                          const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              // TODO: add inter font or something (do later)
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Enter your email to recieve a password reset link',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                // ====================================
                //        reset form
                // ====================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),

                      // email field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !authProvider.isLoading,
                            decoration: InputDecoration(
                              hintText: 'elbieats@up.edu.ph',
                              errorText: emailError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color(0xFFFA5800),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // send reset link button
                      if (authProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => handleResetPassword(authProvider), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFA5800),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                          ),
                          child: const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),

                      // message (success / error)
                      if (authProvider.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // check if success
                            color: authProvider.errorMessage!.contains('sent')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                            border: Border.all(
                              color: authProvider.errorMessage!.contains('sent')
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: TextStyle(
                              color: authProvider.errorMessage!.contains('sent')
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),

                      // back to sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Remember your password? '),
                          GestureDetector(
                            onTap: authProvider.isLoading
                              ? null
                              : widget.onSignInTapped,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFFFA5800),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}