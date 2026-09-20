import 'package:flutter/material.dart';
import 'birthday_screen.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persona'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cake,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              'Birthday Reminder',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BirthdaysScreen(),
                  ),
                );
              },
              child: const Text('My Birthdays'),
            ),
          ],
        ),
      ),
    );
  }
}