import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';

///
/// COLORS:
/// Orange - Color(0xFFFA5800)
/// Red - Color(0xFFCB2020)
///

class SignUpPage extends StatefulWidget {
  final VoidCallback? onSignInTapped;
  final Function(String firstName, String lastName, DateTime dateOfBirth)? onProfileSetupNeeded;

  const SignUpPage({this.onSignInTapped, this.onProfileSetupNeeded, super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // date picker
  DateTime? selectedDate;

  // password visibility
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  // validation error
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? dateError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // open date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFFFA5800)),
          ),
          child: child!, // nothing lol
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // validation method
  /// validate all inputs
  bool validateInputs() {
    setState(() {
      firstNameError = null;
      lastNameError = null;
      emailError = null;
      dateError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool isValid = true;

    // first name
    if (firstNameController.text.isEmpty) {
      setState(() {
        firstNameError = 'First name is required';
      });
      isValid = false;
    } else if (firstNameController.text.length < 2) {
      setState(() {
        firstNameError = 'First name must be at least 2 characters';
      });
      isValid = false;
    }

    // last name
    if (lastNameController.text.isEmpty) {
      setState(() {
        lastNameError = 'Last name is required';
      });
      isValid = false;
    } else if (lastNameController.text.length < 2) {
      setState(() {
        lastNameError = 'Last name must be at least 2 characters';
      });
      isValid = false;
    }

    // email
    // TODO: create proper validation for email
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      isValid = false;
    } else if (!emailController.text.contains('@')) {
      setState(() {
        emailError = 'Please enter a valid email';
      });
      isValid = false;
    }

    // birth date
    if (selectedDate == null) {
      setState(() {
        dateError = 'Birth date is required';
      });
      isValid = false;
    }

    // password
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
      isValid = false;
    } else if (passwordController.text.length < 8) {
      setState(() {
        passwordError = 'Password must be at least 8 characters';
      });
      isValid = false;
    }

    // confirm password
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }

  // handle signup
  Future<void> handleSignUp(AuthProvider authProvider) async {
    // return if anything isnt valid
    if (!validateInputs()) {
      return;
    }

    await authProvider.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // todo completed 01:29 17/05/2026
    // save user signup data to firestore
    if (authProvider.isAuthenticated && mounted) {
      widget.onProfileSetupNeeded?.call(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        selectedDate!,
      );
    }
    // auth is handled rn but no profile saving yet
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // header with gradient
                // devs keep in mind we use a stack instead of appbar
                Stack(
                  children: [
                    // gradient bg
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFA5800), Color(0xFFCB2020)],
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
                          color: Colors.white.withValues(
                            alpha: 0.2,
                          ), // withOpacity is deprecated
                        ),
                      ),
                    ),

                    // text content on top of gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 90,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title
                          const Text(
                            'Explore the taste of Los Banos!',
                            style: TextStyle(
                              fontSize: 35,
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
                    ),
                  ],
                ),

                // ====================================
                //        SIGNUP tabs & form
                // ====================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 5),

                      // tab selector: Log In/Sign Up
                      // refer to figma wireframe
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: widget.onSignInTapped,
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // underline for the active tab
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Color(0xFFFA5800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // first name & last name (side by side)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'First Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: firstNameController,
                                  enabled: !authProvider.isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'Juan',
                                    errorText: firstNameError,
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
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: lastNameController,
                                  enabled: !authProvider.isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'Dela Cruz',
                                    errorText: lastNameError,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /* email field */
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
                            enabled: !authProvider
                                .isLoading, // basically disable the field while loading
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
                      const SizedBox(height: 20),

                      /* birth date */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date of birth',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: authProvider.isLoading
                                ? null
                                : () => selectDate(context),
                            child: TextField(
                              enabled:
                                  false, // made this false since its read-only (user should not be able to type here so do not enable)
                              decoration: InputDecoration(
                                hintText: 'DD/MM/YYYY',
                                errorText: dateError,
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey.shade600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              controller: TextEditingController(
                                text: selectedDate != null
                                    // a custom date format
                                    // we used the 'intl' package for this
                                    // source/api docs: https://pub.dev/packages/intl
                                    ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(selectedDate!)
                                    : '',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /* set password */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: !passwordVisible,
                            enabled: !authProvider.isLoading,
                            decoration: InputDecoration(
                              labelText: '••••••••',
                              errorText: passwordError,
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /* confirm password */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !confirmPasswordVisible,
                            enabled: !authProvider.isLoading,
                            decoration: InputDecoration(
                              labelText: '••••••••',
                              errorText: confirmPasswordError,
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    confirmPasswordVisible =
                                        !confirmPasswordVisible;
                                  });
                                },
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

                      /* register button */
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
                          onPressed: () => handleSignUp(authProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFA5800),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // error message
                      // if signup fails
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
