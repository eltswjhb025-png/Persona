import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

import '../services/google_auth_service.dart';
import 'home_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
const GoogleSignInScreen({super.key});

@override
State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
bool isLoading = false;
bool hasNavigated = false;

@override
void initState() {
super.initState();

GoogleAuthService.authenticationState.listen(
(credentials) {
if (!mounted || credentials == null || hasNavigated) {
return;
}

hasNavigated = true;

print('GOOGLE UI: Authentication detected');
print('GOOGLE UI: Navigating to HomeScreen');

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(),
),
);
},
);
}

Future<void> signIn() async {
if (isLoading) {
return;
}

setState(() {
isLoading = true;
});

await GoogleAuthService.signIn();

if (!mounted) {
return;
}

setState(() {
isLoading = false;
});
}

Future<void> signOut() async {
await GoogleAuthService.signOut();

if (!mounted) {
return;
}

setState(() {
hasNavigated = false;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Google Account'),
),
body: Center(
child: isLoading
? const CircularProgressIndicator()
    : ElevatedButton(
onPressed: signIn,
child: const Text(
'Sign in with Google',
),
),
),
);
}
}