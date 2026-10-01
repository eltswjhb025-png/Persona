import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final TextEditingController emailController =
  TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // =========================
  // SEND PASSWORD RESET
  // =========================

  Future<void> sendPasswordReset() async {
    if (isLoading) {
      return;
    }

    final String email =
    emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email address.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'If an account exists with this email, '
            'a password reset link has been sent.',
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message =
          'Please enter a valid email address.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your '
              'internet connection.';
          break;

        default:
          message =
          'Unable to send the reset email. '
              'Please try again.';
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        const Color(0xFF3F4A16),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }

  // =========================
  // GLASS CONTAINER
  // =========================

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(24),
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(30),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.17,
            ),

            borderRadius:
            BorderRadius.circular(30),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.32,
              ),

              width: 1.2,
            ),
          ),

          child: child,
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color(0xFF808000);

    const Color oliveDrab =
    Color(0xFF6B8E23);

    const Color darkOlive =
    Color(0xFF3F4A16);

    const Color lightCream =
    Color(0xFFF4F5E9);

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
              padding:
              const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 440,
                ),

                child: _buildGlassContainer(
                  padding:
                  const EdgeInsets.fromLTRB(
                    28,
                    34,
                    28,
                    28,
                  ),

                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      // =========================
                      // PERSONA ICON
                      // =========================

                      Container(
                        width: 90,
                        height: 90,

                        decoration:
                        BoxDecoration(
                          shape: BoxShape.circle,

                          color: Colors.white
                              .withValues(
                            alpha: 0.17,
                          ),

                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: 0.35,
                            ),

                            width: 1.5,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: darkOlive
                                  .withValues(
                                alpha: 0.25,
                              ),

                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.lock_reset,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =========================
                      // TITLE
                      // =========================

                      const Text(
                        'Reset Your Password',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      const Text(
                        'Enter your email address and '
                            'we will send you a link to '
                            'reset your password.',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // EMAIL FIELD
                      // =========================

                      TextField(
                        controller:
                        emailController,

                        keyboardType:
                        TextInputType
                            .emailAddress,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration:
                        InputDecoration(
                          labelText: 'Email',
                          hintText:
                          'Enter your email',

                          labelStyle:
                          const TextStyle(
                            color:
                            Colors.white70,
                          ),

                          hintStyle:
                          const TextStyle(
                            color:
                            Colors.white54,
                          ),

                          prefixIcon:
                          const Icon(
                            Icons
                                .email_outlined,
                            color:
                            Colors.white70,
                          ),

                          filled: true,

                          fillColor:
                          Colors.white
                              .withValues(
                            alpha: 0.12,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),

                            borderSide:
                            BorderSide(
                              color: Colors
                                  .white
                                  .withValues(
                                alpha: 0.20,
                              ),
                            ),
                          ),

                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),

                            borderSide:
                            BorderSide(
                              color: Colors
                                  .white
                                  .withValues(
                                alpha: 0.20,
                              ),
                            ),
                          ),

                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),

                            borderSide:
                            const BorderSide(
                              color: olive,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // =========================
                      // SEND BUTTON
                      // =========================

                      SizedBox(
                        width:
                        double.infinity,
                        height: 54,

                        child:
                        ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : sendPasswordReset,

                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            Colors.white,

                            foregroundColor:
                            darkOlive,

                            disabledBackgroundColor:
                            Colors.white54,

                            elevation: 0,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                18,
                              ),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,

                              color:
                              darkOlive,
                            ),
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            children: [
                              const Icon(
                                Icons
                                    .mail_outline,
                                size: 21,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              const Text(
                                'Send Reset Link',

                                style:
                                TextStyle(
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // =========================
                      // BACK TO LOGIN
                      // =========================

                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child: const Text(
                          'Back to Login',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // =========================
                      // SECURITY MESSAGE
                      // =========================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.white
                                .withValues(
                              alpha: 0.55,
                            ),
                            size: 16,
                          ),

                          const SizedBox(
                            width: 7,
                          ),

                          const Text(
                            'Your password remains secure',

                            style: TextStyle(
                              color:
                              Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      const Text(
                        'PERSONA',

                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
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