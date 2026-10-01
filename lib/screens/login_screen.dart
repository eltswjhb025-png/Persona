import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
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
bool isLoading = false;

static const Color oliveDrab = Color(0xFF6B8E23);
static const Color olive = Color(0xFF808000);
static const Color darkOlive = Color(0xFF3F4A16);
static const Color lightCream = Color(0xFFF4F5E9);

@override
void dispose() {
emailController.dispose();
passwordController.dispose();
super.dispose();
}

// ------------------------------------------------------------
// EMAIL / PASSWORD LOGIN
// ------------------------------------------------------------

Future<void> login() async {
final String email = emailController.text.trim();
final String password = passwordController.text.trim();

if (email.isEmpty || password.isEmpty) {
_showMessage(
'Please enter your email and password.',
);
return;
}

setState(() {
isLoading = true;
});

try {
await FirebaseAuth.instance.signInWithEmailAndPassword(
email: email,
password: password,
);

if (!mounted) return;

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

if (!mounted) return;

_showMessage(message);
} catch (e) {
if (!mounted) return;

_showMessage(
'Something went wrong. Please try again.',
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

// ------------------------------------------------------------
// GOOGLE LOGIN
// ------------------------------------------------------------

Future<void> signInWithGoogle() async {
setState(() {
isLoading = true;
});

try {
final userCredential =
await GoogleAuthService.signIn();

if (userCredential == null) {
if (!mounted) return;

_showMessage(
'Google sign-in was unsuccessful. Please try again.',
);

return;
}

if (!mounted) return;

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(),
),
);
} catch (e) {
if (!mounted) return;

_showMessage(
'Google sign-in failed. Please try again.',
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

// ------------------------------------------------------------
// MESSAGE
// ------------------------------------------------------------

void _showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
margin: const EdgeInsets.all(16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
);
}

// ------------------------------------------------------------
// BUILD
// ------------------------------------------------------------

@override
Widget build(BuildContext context) {
final bool isDarkMode =
Theme.of(context).brightness == Brightness.dark;

return Scaffold(
extendBodyBehindAppBar: true,
backgroundColor:
isDarkMode ? const Color(0xFF202414) : lightCream,

body: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: isDarkMode
? const [
Color(0xFF202414),
Color(0xFF3F4A16),
Color(0xFF151810),
]
    : const [
Color(0xFF808000),
Color(0xFF6B8E23),
Color(0xFF556B2F),
],
),
),

child: SafeArea(
child: Center(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),

padding: const EdgeInsets.symmetric(
horizontal: 22,
vertical: 25,
),

child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 450,
),

child: _buildLoginCard(
context,
isDarkMode,
),
),
),
),
),
),
);
}

// ------------------------------------------------------------
// GLASS LOGIN CARD
// ------------------------------------------------------------

Widget _buildLoginCard(
BuildContext context,
bool isDarkMode,
) {
return ClipRRect(
borderRadius: BorderRadius.circular(32),

child: BackdropFilter(
filter: ImageFilter.blur(
sigmaX: 18,
sigmaY: 18,
),

child: Container(
padding: const EdgeInsets.fromLTRB(
26,
32,
26,
24,
),

decoration: BoxDecoration(
color: isDarkMode
? Colors.black.withOpacity(0.28)
    : Colors.white.withOpacity(0.16),

borderRadius: BorderRadius.circular(32),

border: Border.all(
color: Colors.white.withOpacity(0.28),
width: 1,
),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.18),
blurRadius: 30,
offset: const Offset(0, 15),
),
],
),

child: Column(
mainAxisSize: MainAxisSize.min,
children: [
_buildPersonaIcon(),

const SizedBox(height: 20),

_buildTitle(),

const SizedBox(height: 8),

_buildSubtitle(),

const SizedBox(height: 30),

_buildEmailField(),

const SizedBox(height: 15),

_buildPasswordField(),

const SizedBox(height: 7),

_buildForgotPassword(context),

const SizedBox(height: 8),

_buildLoginButton(),

const SizedBox(height: 22),

_buildDivider(),

const SizedBox(height: 20),

_buildGoogleButton(),

const SizedBox(height: 22),

_buildSignUp(context),

const SizedBox(height: 4),

_buildBranding(),
],
),
),
),
);
}

// ------------------------------------------------------------
// PERSONA ICON
// ------------------------------------------------------------

Widget _buildPersonaIcon() {
return Container(
height: 92,
width: 92,

decoration: BoxDecoration(
color: Colors.white.withOpacity(0.16),
shape: BoxShape.circle,

border: Border.all(
color: Colors.white.withOpacity(0.35),
width: 1.5,
),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.12),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),

child: Container(
margin: const EdgeInsets.all(7),

decoration: const BoxDecoration(
color: olive,
shape: BoxShape.circle,
),

child: const Icon(
Icons.spa_outlined,
color: Colors.white,
size: 48,
),
),
);
}

// ------------------------------------------------------------
// TITLE
// ------------------------------------------------------------

Widget _buildTitle() {
return const Text(
'Welcome to Persona',
textAlign: TextAlign.center,

style: TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.w800,
letterSpacing: -0.3,
),
);
}

// ------------------------------------------------------------
// SUBTITLE
// ------------------------------------------------------------

Widget _buildSubtitle() {
return Text(
'Your personal companion',
textAlign: TextAlign.center,

style: TextStyle(
color: Colors.white.withOpacity(0.72),
fontSize: 15,
fontWeight: FontWeight.w400,
),
);
}

// ------------------------------------------------------------
// EMAIL
// ------------------------------------------------------------

Widget _buildEmailField() {
return _buildGlassTextField(
controller: emailController,
label: 'Email',
hint: 'Enter your email',
icon: Icons.email_outlined,
keyboardType: TextInputType.emailAddress,
);
}

// ------------------------------------------------------------
// PASSWORD
// ------------------------------------------------------------

Widget _buildPasswordField() {
return _buildGlassTextField(
controller: passwordController,
label: 'Password',
hint: 'Enter your password',
icon: Icons.lock_outline,
obscureText: obscurePassword,

suffixIcon: IconButton(
onPressed: () {
setState(() {
obscurePassword = !obscurePassword;
});
},

icon: Icon(
obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,

color: Colors.white.withOpacity(0.65),
),
),
);
}

// ------------------------------------------------------------
// GLASS TEXT FIELD
// ------------------------------------------------------------

Widget _buildGlassTextField({
required TextEditingController controller,
required String label,
required String hint,
required IconData icon,
TextInputType? keyboardType,
bool obscureText = false,
Widget? suffixIcon,
}) {
return TextField(
controller: controller,
keyboardType: keyboardType,
obscureText: obscureText,

style: const TextStyle(
color: Colors.white,
fontSize: 15,
),

cursorColor: Colors.white,

decoration: InputDecoration(
labelText: label,
hintText: hint,

labelStyle: TextStyle(
color: Colors.white.withOpacity(0.75),
),

hintStyle: TextStyle(
color: Colors.white.withOpacity(0.42),
),

prefixIcon: Icon(
icon,
color: Colors.white.withOpacity(0.68),
),

suffixIcon: suffixIcon,

filled: true,
fillColor: Colors.white.withOpacity(0.10),

contentPadding: const EdgeInsets.symmetric(
horizontal: 18,
vertical: 17,
),

enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(17),
borderSide: BorderSide(
color: Colors.white.withOpacity(0.16),
),
),

focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(17),
borderSide: const BorderSide(
color: Colors.white,
width: 1.5,
),
),
),
);
}

// ------------------------------------------------------------
// FORGOT PASSWORD
// ------------------------------------------------------------

Widget _buildForgotPassword(BuildContext context) {
return Align(
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

style: TextButton.styleFrom(
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(
horizontal: 4,
),
),

child: const Text(
'Forgot Password?',
style: TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
),
);
}

// ------------------------------------------------------------
// LOGIN BUTTON
// ------------------------------------------------------------

Widget _buildLoginButton() {
return SizedBox(
width: double.infinity,
height: 54,

child: ElevatedButton(
onPressed: isLoading ? null : login,

style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: darkOlive,
disabledBackgroundColor:
Colors.white.withOpacity(0.55),
elevation: 0,

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(17),
),
),

child: isLoading
? const SizedBox(
height: 22,
width: 22,

child: CircularProgressIndicator(
strokeWidth: 2.5,
color: darkOlive,
),
)
    : const Text(
'Login',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
),
);
}

// ------------------------------------------------------------
// DIVIDER
// ------------------------------------------------------------

Widget _buildDivider() {
return Row(
children: [
Expanded(
child: Container(
height: 1,
color: Colors.white.withOpacity(0.18),
),
),

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 14,
),

child: Text(
'OR',
style: TextStyle(
color: Colors.white.withOpacity(0.60),
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),

Expanded(
child: Container(
height: 1,
color: Colors.white.withOpacity(0.18),
),
),
],
);
}

// ------------------------------------------------------------
// GOOGLE BUTTON
// ------------------------------------------------------------

Widget _buildGoogleButton() {
return SizedBox(
width: double.infinity,
height: 54,

child: OutlinedButton.icon(
onPressed:
isLoading ? null : signInWithGoogle,

icon: Container(
height: 28,
width: 28,

decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
),

child: const Center(
child: Text(
'G',
style: TextStyle(
color: Color(0xFF4285F4),
fontSize: 17,
fontWeight: FontWeight.w800,
),
),
),
),

label: const Text(
'Continue with Google',
style: TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight: FontWeight.w600,
),
),

style: OutlinedButton.styleFrom(
backgroundColor:
Colors.white.withOpacity(0.08),

side: BorderSide(
color: Colors.white.withOpacity(0.25),
),

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(17),
),
),
),
);
}

// ------------------------------------------------------------
// SIGN UP
// ------------------------------------------------------------

Widget _buildSignUp(BuildContext context) {
return Wrap(
alignment: WrapAlignment.center,
crossAxisAlignment: WrapCrossAlignment.center,

children: [
Text(
"Don't have an account?",
style: TextStyle(
color: Colors.white.withOpacity(0.68),
fontSize: 13,
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

style: TextButton.styleFrom(
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(
horizontal: 6,
),
),

child: const Text(
'Sign Up',
style: TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight: FontWeight.w800,
),
),
),
],
);
}

// ------------------------------------------------------------
// BRANDING
// ------------------------------------------------------------

Widget _buildBranding() {
return Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.spa_outlined,
color: Colors.white.withOpacity(0.40),
size: 16,
),

const SizedBox(width: 7),

Text(
'PERSONA',
style: TextStyle(
color: Colors.white.withOpacity(0.40),
fontSize: 9,
fontWeight: FontWeight.w700,
letterSpacing: 3,
),
),
],
);
}
}