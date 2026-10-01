import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/google_auth_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

// ============================================================
// SYSTEM UI
// ============================================================
//
// Allows the Persona background to extend underneath the
// Android status bar and navigation bar.
//
// This prevents the bottom navigation area from appearing
// as a separate white section.
//
// ============================================================

await SystemChrome.setEnabledSystemUIMode(
SystemUiMode.edgeToEdge,
);

  SystemChrome.setSystemUIOverlayStyle(
const SystemUiOverlayStyle(
// ----------------------------------------------------------
// Status bar
// ----------------------------------------------------------

statusBarColor: Colors.transparent,
statusBarIconBrightness: Brightness.light,

// ----------------------------------------------------------
// Navigation bar
// ----------------------------------------------------------

systemNavigationBarColor: Colors.transparent,
systemNavigationBarIconBrightness: Brightness.light,

// Prevent Android from adding a contrast scrim.
systemNavigationBarContrastEnforced: false,

// Android status-bar contrast
systemStatusBarContrastEnforced: false,
),
);

// ============================================================
// SQLite
// ============================================================

// sqflite_common_ffi is only needed for desktop platforms.
//
// Android and iOS should use the normal sqflite database
// factory provided by the sqflite package.

if (Platform.isWindows ||
Platform.isLinux ||
Platform.isMacOS) {
sqfliteFfiInit();
databaseFactory = databaseFactoryFfi;
}

// ============================================================
// Environment
// ============================================================

await dotenv.load(
fileName: '.env',
);

// ============================================================
// Firebase
// ============================================================

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

// ============================================================
// Services
// ============================================================

await GoogleAuthService.initialize();

await NotificationService.initialize();

// ============================================================
// Theme
// ============================================================

final ThemeService themeService = ThemeService();

await themeService.loadTheme();

// ============================================================
// Run App
// ============================================================

runApp(
ThemeProvider(
themeService: themeService,
child: const PersonaApp(),
),
);
}

// ============================================================
// Persona App
// ============================================================

class PersonaApp extends StatelessWidget {
const PersonaApp({
super.key,
});

@override
Widget build(BuildContext context) {
// Get the shared ThemeService from ThemeProvider.
//
// Because ThemeProvider extends InheritedNotifier,
// PersonaApp will rebuild whenever ThemeService calls
// notifyListeners().

final ThemeService themeService =
ThemeProvider.of(context);

return MaterialApp(
debugShowCheckedModeBanner: false,

title: 'Persona',

// ==========================================================
// Light Theme
// ==========================================================

theme: ThemeData(
brightness: Brightness.light,

colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF808000),
brightness: Brightness.light,
),

useMaterial3: true,
),

// ==========================================================
// Dark Theme
// ==========================================================

darkTheme: ThemeData(
brightness: Brightness.dark,

colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF6B8E23),
brightness: Brightness.dark,
),

useMaterial3: true,
),

// ==========================================================
// Current Theme
// ==========================================================

themeMode: themeService.themeMode,

// ==========================================================
// First Screen
// ==========================================================

home: const LoginScreen(),
);
}
}