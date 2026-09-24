import 'package:flutter/material.dart';
import 'birthdays_screen.dart';
import '../services/notification_service.dart';
import 'calendar_screen.dart';

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

            const SizedBox(height: 15),

            ElevatedButton(
                onPressed: () {
                  NotificationService.showTestNotification();
                },
                child: const Text('Test Notification'),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
                onPressed: () {
                  final DateTime scheduledDate =
                      DateTime.now().add(const Duration(minutes: 1));

                  NotificationService.scheduleNotification(
                      id: 1,
                      title: 'Persona',
                      body: 'This is a scheduled birthday reminder!',
                      scheduledDate: scheduledDate,
                  );
                },
                child: const Text('Test Scheduled Notification'),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              },
              child: const Text('Calendar'),
            ),
          ],
        ),
      ),
    );
  }
}