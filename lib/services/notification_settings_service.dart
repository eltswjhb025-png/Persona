import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static const String _notificationsEnabledKey =
      'notifications_enabled';

  static const String _reminderSoundsEnabledKey =
      'reminder_sounds_enabled';

  static const String _birthdayRemindersEnabledKey =
      'birthday_reminders_enabled';

  static const String _sevenDaysBeforeEnabledKey =
      'seven_days_before_enabled';

  static const String _oneDayBeforeEnabledKey =
      'one_day_before_enabled';

  static const String _onBirthdayEnabledKey =
      'on_birthday_enabled';

  // ============================================================
  // EVENT REMINDER SETTINGS
  // ============================================================

  static const String _eventRemindersEnabledKey =
      'event_reminders_enabled';

  static const String _eventReminderMinutesKey =
      'event_reminder_minutes';

  // ============================================================
  // GENERAL NOTIFICATIONS
  // ============================================================

  static Future<bool> getNotificationsEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _notificationsEnabledKey,
    ) ??
        true;
  }

  static Future<void> setNotificationsEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _notificationsEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // REMINDER SOUNDS
  // ============================================================

  static Future<bool> getReminderSoundsEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _reminderSoundsEnabledKey,
    ) ??
        true;
  }

  static Future<void> setReminderSoundsEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _reminderSoundsEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // BIRTHDAY REMINDERS
  // ============================================================

  static Future<bool> getBirthdayRemindersEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _birthdayRemindersEnabledKey,
    ) ??
        true;
  }

  static Future<void> setBirthdayRemindersEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _birthdayRemindersEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // 7 DAYS BEFORE
  // ============================================================

  static Future<bool> getSevenDaysBeforeEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _sevenDaysBeforeEnabledKey,
    ) ??
        true;
  }

  static Future<void> setSevenDaysBeforeEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _sevenDaysBeforeEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // 1 DAY BEFORE
  // ============================================================

  static Future<bool> getOneDayBeforeEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _oneDayBeforeEnabledKey,
    ) ??
        true;
  }

  static Future<void> setOneDayBeforeEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _oneDayBeforeEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // ON BIRTHDAY
  // ============================================================

  static Future<bool> getOnBirthdayEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _onBirthdayEnabledKey,
    ) ??
        true;
  }

  static Future<void> setOnBirthdayEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _onBirthdayEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // EVENT REMINDERS
  // ============================================================

  static Future<bool> getEventRemindersEnabled() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _eventRemindersEnabledKey,
    ) ??
        true;
  }

  static Future<void> setEventRemindersEnabled(
      bool enabled,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _eventRemindersEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // EVENT REMINDER TIME
  // ============================================================

  /// Returns the number of minutes before the event.
  ///
  /// 0    = At event time
  /// 15   = 15 minutes before
  /// 30   = 30 minutes before
  /// 60   = 1 hour before
  static Future<int> getEventReminderMinutes() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(
      _eventReminderMinutesKey,
    ) ??
        15;
  }

  static Future<void> setEventReminderMinutes(
      int minutes,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setInt(
      _eventReminderMinutesKey,
      minutes,
    );
  }
}