import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/theme_service.dart';
import 'emergency_contact_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color olive = Color(0xFF808000);
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  // ============================================================
  // Helpers
  // ============================================================

  Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return glassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 13,
            ),
          ),
        ),
        trailing: trailing ??
            (showArrow
                ? Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.65),
              size: 17,
            )
                : null),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: darkOlive,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout of Persona?',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkOlive,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  // ============================================================
  // Profile
  // ============================================================

  void _openProfile() {
    final User? user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: darkOlive,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person,
                size: 55,
                color: oliveDrab,
              ),
              const SizedBox(height: 15),
              Text(
                user?.displayName ?? 'Persona User',
                style: const TextStyle(
                  color: darkOlive,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Notifications & Reminders
  // ============================================================

  void _openNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Notifications & Reminders',
            style: TextStyle(
              color: darkOlive,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Persona notifications and birthday reminders are managed by the app notification system.',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // About App
  // ============================================================

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Persona',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.spa_outlined,
        color: oliveDrab,
        size: 45,
      ),
      applicationLegalese: '© 2026 Persona',
      children: const [
        SizedBox(height: 20),
        Text(
          'Persona brings your important people, birthdays, calendar events, location and emergency tools together in one place.',
        ),
      ],
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Get the shared ThemeService.
    //
    // ThemeProvider listens to ThemeService and rebuilds this
    // screen whenever notifyListeners() is called.
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode = themeService.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              oliveDrab,
              olive,
              darkOlive,
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // App Bar
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12,
                      sigmaY: 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // Content
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    15,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      // ==================================================
                      // Header
                      // ==================================================

                      glassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.18,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.28,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.spa_outlined,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Persona Settings',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Manage your account and app preferences.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // ACCOUNT
                      // ==================================================

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ACCOUNT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      buildSettingTile(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        subtitle:
                        'View your Persona account information',
                        onTap: _openProfile,
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // PREFERENCES
                      // ==================================================

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PREFERENCES',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // DARK THEME
                      // ==================================================

                      buildSettingTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Theme',
                        subtitle: isDarkMode
                            ? 'Dark theme is enabled'
                            : 'Use Persona in light mode',
                        showArrow: false,
                        trailing: Switch(
                          value: isDarkMode,
                          activeThumbColor: darkOlive,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor:
                          Colors.white.withValues(alpha: 0.35),
                          onChanged: (value) async {
                            await themeService.setDarkMode(value);
                          },
                        ),
                        onTap: () async {
                          await themeService.setDarkMode(
                            !isDarkMode,
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      buildSettingTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications & Reminders',
                        subtitle:
                        'Manage birthday and app reminders',
                        onTap: _openNotificationSettings,
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // SAFETY
                      // ==================================================

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SAFETY',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      buildSettingTile(
                        icon: Icons.contact_emergency_outlined,
                        title: 'Emergency Contact',
                        subtitle:
                        'Set the person who will receive SOS messages',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const EmergencyContactsScreen() ,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // ABOUT
                      // ==================================================

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ABOUT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About Persona',
                        subtitle:
                        'App information and version',
                        onTap: _openAbout,
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // LOGOUT
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkOlive,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout,
                          ),
                          label: const Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: _logout,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // Persona Branding
                      // ==================================================

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'PERSONA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}