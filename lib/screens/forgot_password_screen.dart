import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/theme_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color olive =
  Color(0xFF808000);

  static const Color oliveDrab =
  Color(0xFF6B8E23);

  static const Color darkOlive =
  Color(0xFF3F4A16);

  static const Color lightCream =
  Color(0xFFF4F5E9);

  static const Color darkBackground =
  Color(0xFF1E2412);

  static const Color darkCard =
  Color(0xFF2B321B);

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController emailController =
  TextEditingController();

  bool isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND PASSWORD RESET
  // ============================================================

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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode
            ? darkCard
            : darkOlive,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // GLASS CONTAINER
  // ============================================================

  Widget _buildGlassContainer({
    required Widget child,
    required bool isDarkMode,
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
            color: isDarkMode
                ? Colors.black.withValues(
              alpha: 0.20,
            )
                : Colors.white.withValues(
              alpha: 0.17,
            ),

            borderRadius:
            BorderRadius.circular(30),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: isDarkMode
                    ? 0.12
                    : 0.32,
              ),

              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDarkMode
                      ? 0.25
                      : 0.12,
                ),
                blurRadius: 25,
                offset:
                const Offset(0, 10),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    final Color backgroundStart =
    isDarkMode
        ? const Color(0xFF3F4A16)
        : darkOlive;

    final Color backgroundMiddle =
    isDarkMode
        ? const Color(0xFF2B321B)
        : oliveDrab;

    final Color backgroundEnd =
    isDarkMode
        ? darkBackground
        : lightCream;

    final Color primaryText =
    isDarkMode
        ? Colors.white
        : Colors.white;

    final Color secondaryText =
    isDarkMode
        ? Colors.white.withValues(
      alpha: 0.68,
    )
        : Colors.white70;

    final Color fieldFill =
    isDarkMode
        ? Colors.black.withValues(
      alpha: 0.20,
    )
        : Colors.white.withValues(
      alpha: 0.12,
    );

    final Color fieldBorder =
    isDarkMode
        ? Colors.white.withValues(
      alpha: 0.12,
    )
        : Colors.white.withValues(
      alpha: 0.20,
    );

    final Color buttonBackground =
    isDarkMode
        ? oliveDrab
        : Colors.white;

    final Color buttonForeground =
    isDarkMode
        ? Colors.white
        : darkOlive;

    return Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor:
      isDarkMode
          ? darkBackground
          : darkOlive,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              backgroundStart,
              backgroundMiddle,
              isDarkMode
                  ? const Color(0xFF1E2412)
                  : olive,
              backgroundEnd,
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
                  isDarkMode: isDarkMode,

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
                      // =====================================================
                      // PERSONA ICON
                      // =====================================================

                      Container(
                        width: 90,
                        height: 90,

                        decoration:
                        BoxDecoration(
                          shape:
                          BoxShape.circle,

                          color: Colors.white
                              .withValues(
                            alpha: isDarkMode
                                ? 0.08
                                : 0.17,
                          ),

                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: isDarkMode
                                  ? 0.16
                                  : 0.35,
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

                        child:
                        const Icon(
                          Icons.lock_reset,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =====================================================
                      // TITLE
                      // =====================================================

                      Text(
                        'Reset Your Password',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: primaryText,
                          fontSize: 27,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      Text(
                        'Enter your email address and '
                            'we will send you a link to '
                            'reset your password.',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =====================================================
                      // EMAIL FIELD
                      // =====================================================

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
                          TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                .withValues(
                              alpha: 0.68,
                            )
                                : Colors.white70,
                          ),

                          hintStyle:
                          TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                .withValues(
                              alpha: 0.42,
                            )
                                : Colors.white54,
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
                          fieldFill,

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),

                            borderSide:
                            BorderSide(
                              color:
                              fieldBorder,
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
                              color:
                              fieldBorder,
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

                      // =====================================================
                      // SEND BUTTON
                      // =====================================================

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

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            buttonBackground,

                            foregroundColor:
                            buttonForeground,

                            disabledBackgroundColor:
                            isDarkMode
                                ? oliveDrab
                                .withValues(
                              alpha: 0.45,
                            )
                                : Colors.white54,

                            disabledForegroundColor:
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
                              ? SizedBox(
                            width: 23,
                            height: 23,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,

                              color:
                              buttonForeground,
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

                      // =====================================================
                      // BACK TO LOGIN
                      // =====================================================

                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child: Text(
                          'Back to Login',

                          style: TextStyle(
                            color: Colors.white
                                .withValues(
                              alpha: isDarkMode
                                  ? 0.88
                                  : 1.0,
                            ),
                            fontSize: 14,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // =====================================================
                      // SECURITY MESSAGE
                      // =====================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.white
                                .withValues(
                              alpha: isDarkMode
                                  ? 0.48
                                  : 0.55,
                            ),
                            size: 16,
                          ),

                          const SizedBox(
                            width: 7,
                          ),

                          Text(
                            'Your password remains secure',

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: isDarkMode
                                    ? 0.48
                                    : 0.60,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      Text(
                        'PERSONA',

                        style: TextStyle(
                          color: Colors.white
                              .withValues(
                            alpha: isDarkMode
                                ? 0.40
                                : 0.54,
                          ),
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