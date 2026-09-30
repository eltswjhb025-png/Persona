import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';
import '../services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email and password.',
          ),
        ),
      );

      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-not-found':
          message = 'No account was found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your internet connection.';
          break;

        default:
          message =
          'Login failed. Please check your details and try again.';
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color.fromRGBO(128, 128, 0, 1);

    const Color oliveDrab =
    Color.fromRGBO(107, 142, 35, 1);

    const Color darkOlive =
    Color.fromRGBO(85, 107, 47, 1);

    // Check the current theme.
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    // Login screen background.
    final Color backgroundColor = isDarkMode
        ? const Color(0xFF121510)
        : oliveDrab;

    // Login card background.
    final Color cardColor = isDarkMode
        ? const Color(0xFF1E231B)
        : Colors.white;

    // Main text colour.
    final Color textColor = isDarkMode
        ? Colors.white
        : Colors.black87;

    // Secondary text colour.
    final Color secondaryTextColor = isDarkMode
        ? Colors.white70
        : Colors.black54;

    // Text field background.
    final Color inputColor = isDarkMode
        ? const Color(0xFF292F25)
        : Colors.grey.shade100;

    // Text inside the Google button.
    final Color buttonTextColor = isDarkMode
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),

              child: Card(
                color: cardColor,
                elevation: 8,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(30),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // --------------------------------------------------
                      // PERSONA ICON
                      // --------------------------------------------------
                      Container(
                        width: 90,
                        height: 90,

                        decoration: BoxDecoration(
                          color: olive,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.spa_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // TITLE
                      // --------------------------------------------------
                      Text(
                        'Welcome to Persona',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : darkOlive,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --------------------------------------------------
                      // SUBTITLE
                      // --------------------------------------------------
                      Text(
                        'Your personal companion',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --------------------------------------------------
                      // EMAIL
                      // --------------------------------------------------
                      TextField(
                        controller: emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        style: TextStyle(
                          color: textColor,
                        ),

                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',

                          labelStyle: TextStyle(
                            color: secondaryTextColor,
                          ),

                          hintStyle: TextStyle(
                            color: secondaryTextColor,
                          ),

                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: secondaryTextColor,
                          ),

                          filled: true,
                          fillColor: inputColor,

                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: olive,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // --------------------------------------------------
                      // PASSWORD
                      // --------------------------------------------------
                      TextField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        style: TextStyle(
                          color: textColor,
                        ),

                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',

                          labelStyle: TextStyle(
                            color: secondaryTextColor,
                          ),

                          hintStyle: TextStyle(
                            color: secondaryTextColor,
                          ),

                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: secondaryTextColor,
                          ),

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
                                  : Icons.visibility_off_outlined,
                              color: secondaryTextColor,
                            ),
                          ),

                          filled: true,
                          fillColor: inputColor,

                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: olive,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --------------------------------------------------
                      // FORGOT PASSWORD
                      // --------------------------------------------------
                      Align(
                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgotPasswordScreen(),
                              ),
                            );
                          },

                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : darkOlive,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --------------------------------------------------
                      // LOGIN BUTTON
                      // --------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(
                          onPressed: login,

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: olive,
                            foregroundColor:
                            Colors.white,
                            elevation: 3,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),

                          child: const Text(
                            'Login',

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // DIVIDER
                      // --------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color:
                              isDarkMode
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                          ),

                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),

                            child: Text(
                              'OR',
                              style: TextStyle(
                                color:
                                secondaryTextColor,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Divider(
                              color:
                              isDarkMode
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // GOOGLE BUTTON
                      // --------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final userCredential =
                            await GoogleAuthService
                                .signIn();

                            if (userCredential == null) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Google sign-in was unsuccessful. '
                                        'Please try again.',
                                  ),
                                ),
                              );

                              return;
                            }

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const HomeScreen(),
                              ),
                            );
                          },

                          icon: Icon(
                            Icons.g_mobiledata,
                            size: 30,
                            color: buttonTextColor,
                          ),

                          label: Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: buttonTextColor,
                            ),
                          ),

                          style:
                          OutlinedButton.styleFrom(
                            foregroundColor:
                            buttonTextColor,

                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --------------------------------------------------
                      // REGISTER
                      // --------------------------------------------------
                      Wrap(
                        alignment:
                        WrapAlignment.center,

                        crossAxisAlignment:
                        WrapCrossAlignment.center,

                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color:
                              secondaryTextColor,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const SignUpScreen(),
                                ),
                              );
                            },

                            child: Text(
                              'Sign Up',

                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : darkOlive,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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