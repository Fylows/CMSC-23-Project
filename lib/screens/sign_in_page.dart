import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  // navigation fallback (for signup and forgot password)
  final VoidCallback? onSignUpTapped;
  final VoidCallback? onForgotPasswordTapped;

  const SignInPage({
    this.onSignUpTapped,
    this.onForgotPasswordTapped,
    super.key
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // controllers for cpaturing what user types in to the text fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool passwordVisible = false;

  // for tracking validation
  // (separate from the one in AuthProvider)
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // validation
  bool validateInputs() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    bool isValid = true;

    // email validation
    // empty
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      isValid = false;
    }

    // invalid format
    /**
     * TODO:
     *  implement validation later
     *  use this (email validator)
     *  https://pub.dev/packages/email_validator
     */
    else if (!emailController.text.contains('@')) {
      setState(() {
        emailError = 'Please enter a valid email';
      });
      isValid = false;
    }
    
    // password validation
    // empty
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });

      isValid = false;
    }

    // password too short
    // TODO: add validation later
    else if (passwordController.text.length < 8) {
      setState(() {
        passwordError = 'Password must be at least 8 characters';
      });
      isValid = false;
    }
    
    return isValid;
  }

  // HANDLE SIGN IN
  // called when user taps the "sign in" button
  Future<void> handleSignIn(AuthProvider authProvider) async {
    // validate first
    if (!validateInputs()) {
      return;
    }

    await authProvider.signIn(
      email: emailController.text.trim(), 
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          // we use a stack instead of an appbar
          // **removed appbar
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
                            Colors.orange.shade600,
                            Colors.red.shade600
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
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title
                          const Text(
                            'Explore the taste of Los Banos!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              // TODO: add inter font or something (do later)
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Create an account or log in to explore about our app',
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
                //        LOGIN/SIGNUP tabs & form
                // ====================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),

                      // tab selector: Log In/Sign Up
                      // refer to figma wireframe
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: widget.onSignUpTapped,
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            )
                          ),
                        ],
                      ),

                      // underline for the active tab
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.orange.shade600,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      /* email field */
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !authProvider.isLoading, // basically disable the field while loading
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          errorText: emailError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.email)
                        ),
                      ),
                      const SizedBox(height: 16),

                      /* password field */
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        enabled: !authProvider.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 8),

                      /* forgot password link */
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: authProvider.isLoading
                            ? null
                            : widget.onForgotPasswordTapped, 
                          child: const Text('Forgot Password?'),
                          ),
                      ),
                      const SizedBox(height: 24),

                      /* sign in button */
                      // or spinner if loading
                      if (authProvider.isLoading)
                        const Center(
                          // show spinner while loading
                          child: CircularProgressIndicator(),
                        )
                      else
                      // show button
                        ElevatedButton(
                          // disable button while loading
                          onPressed: () => handleSignIn(authProvider),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      
                      const SizedBox(height: 24),

                      // error message
                      // if signin fails
                      if (authProvider.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      const SizedBox(height: 32),

                      /* divider */
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Or'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      /* sign up link */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an acount?"),
                          GestureDetector(
                            onTap: authProvider.isLoading
                              ? null
                              : widget.onSignUpTapped,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}