import 'package:flutter/material.dart';

import '../services/notification_settings_service.dart';
import '../services/reminder_service.dart';
import '../models/person.dart';
import '../database/database_helper.dart';
import '../services/theme_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color olive = Color(0xFF808000);
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);
  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  // ============================================================
  // Notification Settings
  // ============================================================

  bool notificationsEnabled = true;
  bool reminderSoundsEnabled = true;
  bool birthdayRemindersEnabled = true;

  bool sevenDaysBeforeEnabled = true;
  bool oneDayBeforeEnabled = true;
  bool onBirthdayEnabled = true;

  bool isLoading = true;

  // ============================================================
  // Initialize
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ============================================================
  // Load Settings
  // ============================================================

  Future<void> _loadSettings() async {
    final bool notifications =
    await NotificationSettingsService.getNotificationsEnabled();

    final bool sounds =
    await NotificationSettingsService.getReminderSoundsEnabled();

    final bool birthdayReminders =
    await NotificationSettingsService.getBirthdayRemindersEnabled();

    final bool sevenDays =
    await NotificationSettingsService.getSevenDaysBeforeEnabled();

    final bool oneDay =
    await NotificationSettingsService.getOneDayBeforeEnabled();

    final bool birthday =
    await NotificationSettingsService.getOnBirthdayEnabled();

    if (!mounted) return;

    setState(() {
      notificationsEnabled = notifications;
      reminderSoundsEnabled = sounds;
      birthdayRemindersEnabled = birthday;

      sevenDaysBeforeEnabled = sevenDays;
      oneDayBeforeEnabled = oneDay;
      onBirthdayEnabled = birthday;

      isLoading = false;
    });
  }

  // ============================================================
  // Update Notifications
  // ============================================================

  Future<void> _updateNotifications(bool value) async {
    await NotificationSettingsService.setNotificationsEnabled(value);

    if (!mounted) return;

    setState(() {
      notificationsEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Update Reminder Sounds
  // ============================================================

  Future<void> _updateReminderSounds(bool value) async {
    await NotificationSettingsService.setReminderSoundsEnabled(value);

    if (!mounted) return;

    setState(() {
      reminderSoundsEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Update Birthday Reminders
  // ============================================================

  Future<void> _updateBirthdayReminders(bool value) async {
    await NotificationSettingsService.setBirthdayRemindersEnabled(value);

    if (!mounted) return;

    setState(() {
      birthdayRemindersEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Update 7 Days Before
  // ============================================================

  Future<void> _updateSevenDays(bool value) async {
    await NotificationSettingsService.setSevenDaysBeforeEnabled(value);

    if (!mounted) return;

    setState(() {
      sevenDaysBeforeEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Update 1 Day Before
  // ============================================================

  Future<void> _updateOneDay(bool value) async {
    await NotificationSettingsService.setOneDayBeforeEnabled(value);

    if (!mounted) return;

    setState(() {
      oneDayBeforeEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Update On Birthday
  // ============================================================

  Future<void> _updateOnBirthday(bool value) async {
    await NotificationSettingsService.setOnBirthdayEnabled(value);

    if (!mounted) return;

    setState(() {
      onBirthdayEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // Refresh Birthday Reminders
  // ============================================================

  Future<void> _refreshBirthdayReminders() async {
    try {
      final List<Person> people =
      await DatabaseHelper().getPeople();

      for (final Person person in people) {
        await ReminderService.scheduleBirthdayReminders(person);
      }
    } catch (e) {
      debugPrint(
        'Could not refresh birthday reminders: $e',
      );
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Get the shared Persona theme.
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode = themeService.isDarkMode;

    return Scaffold(
      backgroundColor:
      isDarkMode ? darkBackground : lightCream,

      // ========================================================
      // App Bar
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Notifications & Reminders',
        ),

        backgroundColor:
        isDarkMode ? darkCard : oliveDrab,

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      // ========================================================
      // Body
      // ========================================================

      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: isDarkMode
              ? oliveDrab
              : oliveDrab,
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================================================
          // NOTIFICATIONS
          // ==================================================

          _buildSectionTitle(
            'Notifications',
            isDarkMode,
          ),

          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: 'Enable Persona Notifications',
            subtitle:
            'Allow Persona to send notifications',
            value: notificationsEnabled,
            onChanged: _updateNotifications,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // REMINDER SOUNDS
          // ==================================================

          _buildSectionTitle(
            'Reminder Sounds',
            isDarkMode,
          ),

          _buildSettingTile(
            icon: Icons.volume_up_outlined,
            title: 'Reminder Sounds',
            subtitle:
            'Play a sound when a reminder appears',
            value: reminderSoundsEnabled,
            onChanged: _updateReminderSounds,
            enabled: notificationsEnabled,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // BIRTHDAY REMINDERS
          // ==================================================

          _buildSectionTitle(
            'Birthday Reminders',
            isDarkMode,
          ),

          _buildSettingTile(
            icon: Icons.cake_outlined,
            title: 'Birthday Reminders',
            subtitle:
            'Receive reminders about upcoming birthdays',
            value: birthdayRemindersEnabled,
            onChanged: _updateBirthdayReminders,
            enabled: notificationsEnabled,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 12),

          // ==================================================
          // 7 DAYS BEFORE
          // ==================================================

          _buildSettingTile(
            icon: Icons.calendar_today_outlined,
            title: '7 days before',
            subtitle:
            'Remind me one week before the birthday',
            value: sevenDaysBeforeEnabled,
            onChanged: _updateSevenDays,
            enabled:
            notificationsEnabled &&
                birthdayRemindersEnabled,
            isDarkMode: isDarkMode,
          ),

          // ==================================================
          // 1 DAY BEFORE
          // ==================================================

          _buildSettingTile(
            icon: Icons.event_outlined,
            title: '1 day before',
            subtitle:
            'Remind me the day before the birthday',
            value: oneDayBeforeEnabled,
            onChanged: _updateOneDay,
            enabled:
            notificationsEnabled &&
                birthdayRemindersEnabled,
            isDarkMode: isDarkMode,
          ),

          // ==================================================
          // ON BIRTHDAY
          // ==================================================

          _buildSettingTile(
            icon: Icons.cake_outlined,
            title: 'On birthday',
            subtitle:
            'Remind me on the birthday',
            value: onBirthdayEnabled,
            onChanged: _updateOnBirthday,
            enabled:
            notificationsEnabled &&
                birthdayRemindersEnabled,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // Section Title
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      bool isDarkMode,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 8,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? Colors.white
              : darkOlive,
        ),
      ),
    );
  }

  // ============================================================
  // Setting Tile
  // ============================================================

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
    bool enabled = true,
  }) {
    return Card(
      elevation: isDarkMode ? 0 : 1,

      color: isDarkMode
          ? darkCard
          : Colors.white,

      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
      ),

      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        secondary: Icon(
          icon,
          color: enabled
              ? oliveDrab
              : Colors.grey,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: enabled
                ? isDarkMode
                ? Colors.white
                : darkOlive
                : Colors.grey,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled
                ? isDarkMode
                ? Colors.white70
                : Colors.grey[700]
                : Colors.grey,
          ),
        ),

        value: value,

        onChanged: enabled
            ? onChanged
            : null,

        activeThumbColor: Colors.white,

        activeTrackColor: oliveDrab,

        inactiveThumbColor:
        isDarkMode
            ? Colors.grey[300]
            : Colors.white,

        inactiveTrackColor:
        isDarkMode
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.grey[400],
      ),
    );
  }
}