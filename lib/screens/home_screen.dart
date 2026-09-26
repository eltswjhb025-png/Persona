import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'birthdays_screen.dart';
import 'calendar_screen.dart';
import 'locator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color.fromRGBO(128, 128, 0, 1);

    const Color oliveDrab =
    Color.fromRGBO(107, 142, 35, 1);

    return Scaffold(
      backgroundColor: oliveDrab,

      appBar: AppBar(
        title: const Text('Persona'),
        backgroundColor: olive,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 25),

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: const Icon(
                Icons.spa_outlined,
                size: 55,
                color: olive,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome to Persona',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your personal space, all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 35),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                children: [

                  _buildMenuCard(
                    context,
                    icon: Icons.cake,
                    title: 'My Birthdays',
                    color: olive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const BirthdaysScreen(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    context,
                    icon: Icons.calendar_month,
                    title: 'Calendar',
                    color: olive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CalendarScreen(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Locator',
                    color: olive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const LocatorScreen(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    context,
                    icon: Icons.sos,
                    title: 'SOS',
                    color: olive,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                          Text('SOS coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 55,
              color: Colors.white,
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}