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

// =========================
// Notifications
// =========================

static Future<bool> getNotificationsEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_notificationsEnabledKey) ?? true;
}

static Future<void> setNotificationsEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_notificationsEnabledKey,
enabled,
);
}

// =========================
// Reminder Sounds
// =========================

static Future<bool> getReminderSoundsEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_reminderSoundsEnabledKey) ?? true;
}

static Future<void> setReminderSoundsEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_reminderSoundsEnabledKey,
enabled,
);
}

// =========================
// Birthday Reminders
// =========================

static Future<bool> getBirthdayRemindersEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_birthdayRemindersEnabledKey) ?? true;
}

static Future<void> setBirthdayRemindersEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_birthdayRemindersEnabledKey,
enabled,
);
}

// =========================
// 7 Days Before
// =========================

static Future<bool> getSevenDaysBeforeEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_sevenDaysBeforeEnabledKey) ?? true;
}

static Future<void> setSevenDaysBeforeEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_sevenDaysBeforeEnabledKey,
enabled,
);
}

// =========================
// 1 Day Before
// =========================

static Future<bool> getOneDayBeforeEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_oneDayBeforeEnabledKey) ?? true;
}

static Future<void> setOneDayBeforeEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_oneDayBeforeEnabledKey,
enabled,
);
}

// =========================
// On Birthday
// =========================

static Future<bool> getOnBirthdayEnabled() async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

return prefs.getBool(_onBirthdayEnabledKey) ?? true;
}

static Future<void> setOnBirthdayEnabled(bool enabled) async {
final SharedPreferences prefs =
await SharedPreferences.getInstance();

await prefs.setBool(
_onBirthdayEnabledKey,
enabled,
);
}
}
