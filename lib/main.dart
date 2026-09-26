import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PersonaApp());
}

class PersonaApp extends StatelessWidget {
  const PersonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persona',
      home: const LoginScreen(),
    );
  }
}