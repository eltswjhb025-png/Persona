import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persona/services/google_auth_service.dart';
import 'package:persona/screens/login_screen.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color olive = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightOlive = Color(0xFFE8ECD5);

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleAuthService.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Get the ThemeService from ThemeProvider.
    final themeService = ThemeProvider.of(context);

    // Check whether the app is currently using Dark Mode.
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    // Colors that change depending on the selected theme.
    final Color headingColor =
    isDarkMode ? Colors.white : darkOlive;

    final Color secondaryTextColor =
    isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      // Let the current theme control the background.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ACCOUNT
          Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: lightOlive,
                child: Icon(
                  Icons.person,
                  color: olive,
                ),
              ),
              title: Text(
                user?.displayName ?? 'Persona User',
              ),
              subtitle: Text(
                user?.email ?? 'No email available',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // APP SETTINGS
          Text(
            'App Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                // DARK MODE
                ListTile(
                  leading: Icon(
                    themeService.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    color: olive,
                  ),

                  title: const Text(
                    'Dark Mode',
                  ),

                  subtitle: Text(
                    themeService.isDarkMode
                        ? 'Dark theme is enabled'
                        : 'Use the light theme',
                  ),

                  trailing: Switch(
                    value: themeService.isDarkMode,
                    activeThumbColor: olive,

                    onChanged: (value) {
                      themeService.setDarkMode(value);
                    },
                  ),
                ),

                const Divider(height: 1),

                // NOTIFICATIONS
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: olive,
                  ),

                  title: const Text(
                    'Notifications',
                  ),

                  subtitle: const Text(
                    'Manage birthday reminders',
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    // Notification settings will be added here.
                  },
                ),

                const Divider(height: 1),

                // LOCATION
                ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: olive,
                  ),

                  title: const Text(
                    'Location',
                  ),

                  subtitle: const Text(
                    'Manage location access',
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    // Location settings will be added here.
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ABOUT
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: olive,
              ),

              title: const Text(
                'About Persona',
              ),

              subtitle: const Text(
                'Persona birthday, calendar, locator and SOS app',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Persona',
                  applicationVersion: '1.0.0',

                  applicationIcon: const Icon(
                    Icons.spa_outlined,
                    color: olive,
                    size: 40,
                  ),

                  children: const [
                    Text(
                      'Persona helps you manage birthdays, '
                          'calendar events, location and SOS features.',
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // SIGN OUT
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}