import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'birthdays_screen.dart';
import 'calendar_screen.dart';
import 'locator_screen.dart';
import 'package:persona/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color.fromRGBO(128, 128, 0, 1);

    const Color oliveDrab =
    Color.fromRGBO(107, 142, 35, 1);

    // Check which theme is currently active.
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Change the background depending on the theme.
      backgroundColor:
      isDarkMode
          ? const Color(0xFF121510)
          : oliveDrab,

      appBar: AppBar(
        title: const Text('Persona'),

        // Use the AppBar theme from main.dart.
        // Light mode = olive.
        // Dark mode = dark olive.
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
            ),
            tooltip: 'Settings',

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 25),

            // Persona icon
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color:
                isDarkMode
                    ? const Color(0xFF1E231B)
                    : Colors.white,

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

            // Welcome title
            const Text(
              'Welcome to Persona',

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // Welcome subtitle
            const Text(
              'Your personal space, all in one place.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 35),

            // Menu cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                children: [
                  // Birthdays
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

                  // Calendar
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

                  // Locator
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

                  // SOS
                  _buildMenuCard(
                    context,
                    icon: Icons.sos,
                    title: 'SOS',
                    color: olive,

                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'SOS coming soon',
                          ),
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