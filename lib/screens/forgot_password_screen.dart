import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
const ForgotPasswordScreen({super.key});

@override
State<ForgotPasswordScreen> createState() =>
_ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
final TextEditingController emailController =
TextEditingController();

@override
void dispose() {
emailController.dispose();
super.dispose();
}

Future<void> sendPasswordReset() async {
final String email = emailController.text.trim();

if (email.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please enter your email address.'),
),
);
return;
}

try {
await FirebaseAuth.instance.sendPasswordResetEmail(
email: email,
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'If an account exists with this email, '
'a password reset link has been sent.',
),
),
);
} on FirebaseAuthException catch (e) {
String message;

switch (e.code) {
case 'invalid-email':
message = 'Please enter a valid email address.';
break;
case 'network-request-failed':
message =
'Network error. Please check your internet connection.';
break;
default:
message =
'Unable to send the reset email. Please try again.';
}

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
),
);
} catch (e) {
if (!mounted) return;

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
const Color olive = Color(0xFF808000);
const Color oliveDrab = Color(0xFF6B8E23);
const Color darkOlive = Color(0xFF556B2F);

return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
backgroundColor: olive,
foregroundColor: Colors.white,
title: const Text('Forgot Password'),
),
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Card(
elevation: 8,
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.lock_reset,
size: 70,
color: oliveDrab,
),

const SizedBox(height: 20),

const Text(
'Reset Your Password',
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
color: darkOlive,
),
),

const SizedBox(height: 12),

const Text(
'Enter your email address and we will '
'send you a link to reset your password.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 25),

TextField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
decoration: const InputDecoration(
labelText: 'Email',
prefixIcon: Icon(Icons.email),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: sendPasswordReset,
style: ElevatedButton.styleFrom(
backgroundColor: oliveDrab,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(
vertical: 15,
),
),
child: const Text(
'Send Reset Link',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 10),

TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
'Back to Login',
style: TextStyle(
color: darkOlive,
fontWeight: FontWeight.bold,
),
),
),
],
),
),
),
),
),
);
}
}