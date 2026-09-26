import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:persona/screens/login_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/google_auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

sqfliteFfiInit();
databaseFactory = databaseFactoryFfi;

await dotenv.load(fileName: '.env');
await GoogleAuthService.initialize();
await NotificationService.initialize();

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