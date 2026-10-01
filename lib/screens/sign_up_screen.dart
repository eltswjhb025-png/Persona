import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (isLoading) {
      return;
    }

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword =
    confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please complete all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      if (!mounted) {
        return;
      }

      _showMessage('Account created successfully!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
          'An account already exists with this email.';
          break;

        case 'invalid-email':
          message =
          'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
          'The password is too weak.';
          break;

        case 'operation-not-allowed':
          message =
          'Email/password sign up is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your internet connection.';
          break;

        default:
          message =
          'Sign up failed. Please try again.';
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(message);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3F4A16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(24),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    const Color olive = Color(0xFF808000);

    return InputDecoration(
      labelText: label,
      hintText: hint,

      labelStyle: const TextStyle(
        color: Colors.white70,
      ),

      hintStyle: const TextStyle(
        color: Colors.white54,
      ),

      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: olive,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color olive = Color(0xFF808000);
    const Color oliveDrab = Color(0xFF6B8E23);
    const Color darkOlive = Color(0xFF3F4A16);
    const Color lightCream = Color(0xFFF4F5E9);

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darkOlive,
              oliveDrab,
              olive,
              lightCream,
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ),

                child: _buildGlassContainer(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    32,
                    28,
                    28,
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Persona icon
                      Container(
                        width: 86,
                        height: 86,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.35,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkOlive.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.spa_outlined,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Create Your Persona',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Create an account to get started.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Full Name
                      TextField(
                        controller: nameController,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: _inputDecoration(
                          label: 'Full Name',
                          hint: 'Enter your name',
                          icon: Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Email
                      TextField(
                        controller: emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: _inputDecoration(
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password
                      TextField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: _inputDecoration(
                          label: 'Password',
                          hint: 'Create a password',
                          icon: Icons.lock_outline,

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                !obscurePassword;
                              });
                            },

                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons
                                  .visibility_off_outlined,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Confirm Password
                      TextField(
                        controller:
                        confirmPasswordController,

                        obscureText:
                        obscureConfirmPassword,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: _inputDecoration(
                          label: 'Confirm Password',
                          hint:
                          'Enter your password again',
                          icon: Icons.lock_outline,

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                !obscureConfirmPassword;
                              });
                            },

                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons
                                  .visibility_outlined
                                  : Icons
                                  .visibility_off_outlined,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton(
                          onPressed:
                          isLoading ? null : signUp,

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkOlive,

                            disabledBackgroundColor:
                            Colors.white54,

                            elevation: 0,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,

                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: darkOlive,
                            ),
                          )
                              : const Text(
                            'Create Account',

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [
                          const Text(
                            'Already have an account?',

                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                              Navigator.pop(
                                context,
                              );
                            },

                            child: const Text(
                              'Login',

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'PERSONA',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}