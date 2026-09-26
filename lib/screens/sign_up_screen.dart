import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp() {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword =
    confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields.',
          ),
        ),
      );

      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match.',
          ),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color.fromRGBO(128, 128, 0, 1);

    const Color oliveDrab =
    Color.fromRGBO(107, 142, 35, 1);

    const Color darkOlive =
    Color.fromRGBO(85, 107, 47, 1);

    return Scaffold(
      backgroundColor: oliveDrab,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),

              child: Card(
                color: Colors.white,
                elevation: 8,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(25),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(30),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      // Persona icon
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

                      const Text(
                        'Create Your Persona',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: darkOlive,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Create an account to get started.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Name
                      TextField(
                        controller: nameController,

                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your name',

                          prefixIcon: const Icon(
                            Icons.person_outline,
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade100,

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

                      // Email
                      TextField(
                        controller: emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',

                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade100,

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

                      // Password
                      TextField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create a password',

                          prefixIcon: const Icon(
                            Icons.lock_outline,
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
                            ),
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade100,

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

                      // Confirm password
                      TextField(
                        controller:
                        confirmPasswordController,

                        obscureText:
                        obscureConfirmPassword,

                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Enter your password again',

                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                !obscureConfirmPassword;
                              });
                            },

                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade100,

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

                      const SizedBox(height: 25),

                      // Create account button
                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(
                          onPressed: signUp,

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: olive,
                            foregroundColor: Colors.white,
                            elevation: 3,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),

                          child: const Text(
                            'Create Account',

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Back to login
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [
                          const Text(
                            'Already have an account?',

                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            child: Text(
                              'Login',

                              style: TextStyle(
                                color: darkOlive,
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