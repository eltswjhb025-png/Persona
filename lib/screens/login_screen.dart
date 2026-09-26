import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';
import '../services/google_auth_service.dart';


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

void login() {
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
borderRadius: BorderRadius.circular(25),
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

// Title
const Text(
'Welcome to Persona',
textAlign: TextAlign.center,

style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: darkOlive,
),
),

const SizedBox(height: 8),

// Subtitle
const Text(
'Your personal companion',
textAlign: TextAlign.center,

style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),

const SizedBox(height: 30),

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
hintText: 'Enter your password',

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

const SizedBox(height: 10),

// Forgot password
Align(
alignment: Alignment.centerRight,

child: TextButton(
onPressed: () {
// Forgot password will be
// added later.
},

child: Text(
'Forgot Password?',
style: TextStyle(
color: darkOlive,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 10),

// Login button
SizedBox(
width: double.infinity,
height: 52,

child: ElevatedButton(
onPressed: login,

style: ElevatedButton.styleFrom(
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
'Login',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 20),

// Divider
Row(
children: [
Expanded(
child: Divider(
color: Colors.grey.shade300,
),
),

const Padding(
padding:
EdgeInsets.symmetric(
horizontal: 10,
),

child: Text(
'OR',
style: TextStyle(
color: Colors.black45,
),
),
),

Expanded(
child: Divider(
color: Colors.grey.shade300,
),
),
],
),

const SizedBox(height: 20),

// Google button
  SizedBox(
    width: double.infinity,
    height: 52,

    child: OutlinedButton.icon(
      onPressed: () async {
        final credentials =
        await GoogleAuthService.signIn();

        if (!context.mounted) {
          return;
        }

        if (credentials == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google sign in was cancelled or failed.',
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
      },

      icon: const Icon(
        Icons.g_mobiledata,
        size: 30,
      ),

      label: const Text(
        'Continue with Google',
      ),

      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,

        side: BorderSide(
          color: Colors.grey.shade300,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  ),


const SizedBox(height: 25),

// Register
Row(
mainAxisAlignment:
MainAxisAlignment.center,

children: [
const Text(
"Don't have an account?",
style: TextStyle(
color: Colors.black54,
),
),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  },

child: Text(
'Sign Up',
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