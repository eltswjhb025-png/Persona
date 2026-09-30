import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persona/screens/login_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'services/google_auth_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await dotenv.load(fileName: '.env');

  await GoogleAuthService.initialize();

  await NotificationService.initialize();

  // Create and load the saved theme
  final themeService = ThemeService();
  await themeService.loadTheme();

  runApp(
    PersonaApp(
      themeService: themeService,
    ),
  );
}

class PersonaApp extends StatelessWidget {
  final ThemeService themeService;

  const PersonaApp({
    super.key,
    required this.themeService,
  });

  static const Color olive = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeService: themeService,
      child: AnimatedBuilder(
        animation: themeService,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Persona',

            themeMode: themeService.themeMode,

            // LIGHT THEME
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,

              colorScheme: ColorScheme.fromSeed(
                seedColor: olive,
                brightness: Brightness.light,
              ),

              scaffoldBackgroundColor:
              const Color(0xFFF4F5E9),

              appBarTheme: const AppBarTheme(
                backgroundColor: olive,
                foregroundColor: Colors.white,
              ),

              cardTheme: const CardThemeData(
                color: Colors.white,
              ),
            ),

            // DARK THEME
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,

              colorScheme: ColorScheme.fromSeed(
                seedColor: olive,
                brightness: Brightness.dark,
              ),

              scaffoldBackgroundColor:
              const Color(0xFF121510),

              appBarTheme: const AppBarTheme(
                backgroundColor: darkOlive,
                foregroundColor: Colors.white,
              ),

              cardTheme: const CardThemeData(
                color: Color(0xFF1E231B),
              ),
            ),

            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}