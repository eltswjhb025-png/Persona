import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  await NotificationService.initialize();

  runApp(const PersonaApp());
}

class PersonaApp extends StatelessWidget{
  const PersonaApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persona',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}