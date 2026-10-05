import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/calendar_event.dart';
import '../models/person.dart';
import '../services/event_reminder_service.dart';
import '../services/notification_settings_service.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = true;
  bool reminderSoundsEnabled = true;

  bool birthdayRemindersEnabled = true;
  bool sevenDaysBeforeEnabled = true;
  bool oneDayBeforeEnabled = true;
  bool onBirthdayEnabled = true;

  bool eventRemindersEnabled = true;
  int eventReminderMinutes = 15;

  bool isLoading = true;

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final bool notifications =
    await NotificationSettingsService
        .getNotificationsEnabled();

    final bool sounds =
    await NotificationSettingsService
        .getReminderSoundsEnabled();

    final bool birthdayReminders =
    await NotificationSettingsService
        .getBirthdayRemindersEnabled();

    final bool sevenDays =
    await NotificationSettingsService
        .getSevenDaysBeforeEnabled();

    final bool oneDay =
    await NotificationSettingsService
        .getOneDayBeforeEnabled();

    final bool onBirthday =
    await NotificationSettingsService
        .getOnBirthdayEnabled();

    final bool eventReminders =
    await NotificationSettingsService
        .getEventRemindersEnabled();

    final int eventMinutes =
    await NotificationSettingsService
        .getEventReminderMinutes();

    if (!mounted) {
      return;
    }

    setState(() {
      notificationsEnabled = notifications;
      reminderSoundsEnabled = sounds;

      birthdayRemindersEnabled =
          birthdayReminders;

      sevenDaysBeforeEnabled =
          sevenDays;

      oneDayBeforeEnabled =
          oneDay;

      onBirthdayEnabled =
          onBirthday;

      eventRemindersEnabled =
          eventReminders;

      eventReminderMinutes =
          eventMinutes;

      isLoading = false;
    });
  }

  // ============================================================
  // REFRESH BIRTHDAY REMINDERS
  // ============================================================

  Future<void> _refreshBirthdayReminders() async {
    final List<Person> people =
    await DatabaseHelper()
        .getPeople();

    for (final Person person in people) {
      await ReminderService
          .scheduleBirthdayReminders(
        person,
      );
    }
  }

  // ============================================================
  // REFRESH EVENT REMINDERS
  // ============================================================

  Future<void> _refreshEventReminders() async {
    final List<CalendarEvent> events =
    await DatabaseHelper()
        .getCalendarEvents();

    for (final CalendarEvent event
    in events) {
      await EventReminderService
          .refreshEventReminder(
        event,
      );
    }
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> _updateNotifications(
      bool value,
      ) async {
    await NotificationSettingsService
        .setNotificationsEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      notificationsEnabled = value;
    });

    await _refreshBirthdayReminders();
    await _refreshEventReminders();
  }

  // ============================================================
  // REMINDER SOUNDS
  // ============================================================

  Future<void> _updateReminderSounds(
      bool value,
      ) async {
    await NotificationSettingsService
        .setReminderSoundsEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      reminderSoundsEnabled = value;
    });

    // Sound preference is saved immediately.
    //
    // We do not refresh reminders here because
    // this setting does not change whether a
    // reminder exists.
  }

  // ============================================================
  // BIRTHDAY REMINDERS
  // ============================================================

  Future<void> _updateBirthdayReminders(
      bool value,
      ) async {
    await NotificationSettingsService
        .setBirthdayRemindersEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      birthdayRemindersEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // SEVEN DAYS BEFORE
  // ============================================================

  Future<void> _updateSevenDaysBefore(
      bool value,
      ) async {
    await NotificationSettingsService
        .setSevenDaysBeforeEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      sevenDaysBeforeEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // ONE DAY BEFORE
  // ============================================================

  Future<void> _updateOneDayBefore(
      bool value,
      ) async {
    await NotificationSettingsService
        .setOneDayBeforeEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      oneDayBeforeEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // ON BIRTHDAY
  // ============================================================

  Future<void> _updateOnBirthday(
      bool value,
      ) async {
    await NotificationSettingsService
        .setOnBirthdayEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      onBirthdayEnabled = value;
    });

    await _refreshBirthdayReminders();
  }

  // ============================================================
  // EVENT REMINDERS
  // ============================================================

  Future<void> _updateEventReminders(
      bool value,
      ) async {
    await NotificationSettingsService
        .setEventRemindersEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      eventRemindersEnabled = value;
    });

    await _refreshEventReminders();
  }

  // ============================================================
  // EVENT REMINDER TIMING
  // ============================================================

  Future<void> _updateEventReminderMinutes(
      int minutes,
      ) async {
    await NotificationSettingsService
        .setEventReminderMinutes(
      minutes,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      eventReminderMinutes = minutes;
    });

    await _refreshEventReminders();
  }

  // ============================================================
  // REMINDER LABEL
  // ============================================================

  String _eventReminderLabel(
      int minutes,
      ) {
    switch (minutes) {
      case 0:
        return 'At event time';

      case 15:
        return '15 minutes before';

      case 30:
        return '30 minutes before';

      case 60:
        return '1 hour before';

      default:
        return '$minutes minutes before';
    }
  }

  // ============================================================
  // BUILD SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDark =
        themeService.isDarkMode;

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      leading: Icon(
        icon,
        color: isDark
            ? Colors.white
            : const Color(0xFF3F4A16),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark
              ? Colors.white
              : const Color(0xFF3F4A16),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark
              ? Colors.white70
              : Colors.black54,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor:
        const Color(0xFF6B8E23),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDark =
        themeService.isDarkMode;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 20,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2B321B)
            .withValues(alpha: 0.92)
            : Colors.white
            .withValues(alpha: 0.90),
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: isDark
                ? 0.10
                : 0.30,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : const Color(
                0xFF3F4A16,
              ),
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // EVENT REMINDER TIMING SELECTOR
  // ============================================================

  Widget _buildEventReminderTiming(
      BuildContext context,
      ) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDark =
        themeService.isDarkMode;

    const List<int> reminderOptions = [
      0,
      15,
      30,
      60,
    ];

    return Column(
      children: reminderOptions.map(
            (int minutes) {
          return RadioListTile<int>(
            contentPadding:
            EdgeInsets.zero,
            value: minutes,
            groupValue:
            eventReminderMinutes,
            activeColor:
            const Color(0xFF6B8E23),
            title: Text(
              _eventReminderLabel(
                minutes,
              ),
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF3F4A16,
                ),
              ),
            ),
            onChanged:
            eventRemindersEnabled
                ? (int? value) {
              if (value != null) {
                _updateEventReminderMinutes(
                  value,
                );
              }
            }
                : null,
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDark =
        themeService.isDarkMode;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF1E2412)
            : const Color(0xFF6B8E23),
        appBar: AppBar(
          backgroundColor:
          Colors.transparent,
          elevation: 0,
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child:
          CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1E2412)
          : const Color(0xFF6B8E23),
      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        iconTheme:
        const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration:
        BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topLeft,
            end:
            Alignment.bottomRight,
            colors: isDark
                ? const [
              Color(0xFF1E2412),
              Color(0xFF2B321B),
              Color(0xFF11150B),
            ]
                : const [
              Color(0xFF6B8E23),
              Color(0xFF808000),
              Color(0xFF3F4A16),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              40,
            ),
            children: [
              // ==================================================
              // GENERAL NOTIFICATIONS
              // ==================================================

              _buildSectionCard(
                context: context,
                title: 'Notifications',
                child:
                _buildSwitchTile(
                  context: context,
                  title:
                  'Notifications',
                  subtitle:
                  notificationsEnabled
                      ? 'Persona notifications are enabled.'
                      : 'All Persona notifications are disabled.',
                  icon: Icons
                      .notifications_outlined,
                  value:
                  notificationsEnabled,
                  onChanged:
                  _updateNotifications,
                ),
              ),

              // ==================================================
              // REMINDER SOUNDS
              // ==================================================

              _buildSectionCard(
                context: context,
                title: 'Reminder Sounds',
                child:
                _buildSwitchTile(
                  context: context,
                  title:
                  'Reminder Sounds',
                  subtitle:
                  reminderSoundsEnabled
                      ? 'Notification sounds are enabled.'
                      : 'Notification sounds are disabled.',
                  icon: Icons
                      .volume_up_outlined,
                  value:
                  reminderSoundsEnabled,
                  onChanged:
                  _updateReminderSounds,
                ),
              ),

              // ==================================================
              // BIRTHDAY REMINDERS
              // ==================================================

              _buildSectionCard(
                context: context,
                title:
                'Birthday Reminders',
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context: context,
                      title:
                      'Birthday Reminders',
                      subtitle:
                      birthdayRemindersEnabled
                          ? 'Birthday reminders are enabled.'
                          : 'Birthday reminders are disabled.',
                      icon: Icons
                          .cake_outlined,
                      value:
                      birthdayRemindersEnabled,
                      onChanged:
                      _updateBirthdayReminders,
                    ),

                    if (birthdayRemindersEnabled) ...[
                      const Divider(),

                      _buildSwitchTile(
                        context: context,
                        title:
                        '7 Days Before',
                        subtitle:
                        'Remind me one week before a birthday.',
                        icon: Icons
                            .date_range_outlined,
                        value:
                        sevenDaysBeforeEnabled,
                        onChanged:
                        _updateSevenDaysBefore,
                      ),

                      _buildSwitchTile(
                        context: context,
                        title:
                        '1 Day Before',
                        subtitle:
                        'Remind me the day before a birthday.',
                        icon: Icons
                            .event_outlined,
                        value:
                        oneDayBeforeEnabled,
                        onChanged:
                        _updateOneDayBefore,
                      ),

                      _buildSwitchTile(
                        context: context,
                        title:
                        'On Birthday',
                        subtitle:
                        'Remind me on the birthday.',
                        icon: Icons
                            .celebration_outlined,
                        value:
                        onBirthdayEnabled,
                        onChanged:
                        _updateOnBirthday,
                      ),
                    ],
                  ],
                ),
              ),

              // ==================================================
              // CALENDAR EVENT REMINDERS
              // ==================================================

              _buildSectionCard(
                context: context,
                title:
                'Calendar Event Reminders',
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context: context,
                      title:
                      'Event Reminders',
                      subtitle:
                      eventRemindersEnabled
                          ? 'Reminders for calendar events are enabled.'
                          : 'Calendar event reminders are disabled.',
                      icon: Icons
                          .event_available_outlined,
                      value:
                      eventRemindersEnabled,
                      onChanged:
                      _updateEventReminders,
                    ),

                    if (eventRemindersEnabled) ...[
                      const Divider(),

                      Align(
                        alignment:
                        Alignment.centerLeft,
                        child: Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            left: 12,
                            top: 8,
                            bottom: 4,
                          ),
                          child: Text(
                            'Remind me',
                            style:
                            TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(
                                0xFF3F4A16,
                              ),
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      _buildEventReminderTiming(
                        context,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}