import '../models/person.dart';
import 'notification_service.dart';
import 'notification_settings_service.dart';

class ReminderService {

  static DateTime getNextBirthday(Person person) {
    final DateTime today = DateTime.now();

    DateTime nextBirthday = DateTime(
      today.year,
      person.birthday.month,
      person.birthday.day,
    );

    if (nextBirthday.isBefore(
      DateTime(today.year, today.month, today.day),
    )) {
      nextBirthday = DateTime(
        today.year + 1,
        person.birthday.month,
        person.birthday.day,
      );
    }

    return nextBirthday;
  }

  static List<DateTime> getReminderDates(Person person) {
    final DateTime birthday = getNextBirthday(person);

    return [
      birthday.subtract(const Duration(days: 7)),
      birthday.subtract(const Duration(days: 1)),
      birthday,
    ];
  }

  static Future<void> scheduleBirthdayReminders(Person person) async {
    // Check whether Persona notifications are enabled.
    final bool notificationsEnabled =
    await NotificationSettingsService.getNotificationsEnabled();

    // Check whether birthday reminders are enabled.
    final bool birthdayRemindersEnabled =
    await NotificationSettingsService.getBirthdayRemindersEnabled();

    // If either main setting is OFF, cancel any existing reminders
    // for this person and do not schedule new ones.
    if (!notificationsEnabled || !birthdayRemindersEnabled) {
      await cancelBirthdayReminders(person);
      return;
    }

    final List<DateTime> reminderDates = getReminderDates(person);
    final DateTime now = DateTime.now();

    // =========================
    // 7 DAYS BEFORE
    // =========================

    final bool sevenDaysBeforeEnabled =
    await NotificationSettingsService.getSevenDaysBeforeEnabled();

    if (sevenDaysBeforeEnabled &&
        reminderDates[0].isAfter(now)) {
      await NotificationService.scheduleNotification(
        id: '${person.id}_7'.hashCode,
        title: 'Birthday Reminder',
        body: '${person.name}\'s birthday is in 7 days!',
        scheduledDate: reminderDates[0],
      );
    } else if (!sevenDaysBeforeEnabled) {
      await NotificationService.cancelNotification(
        '${person.id}_7'.hashCode,
      );
    }

    // =========================
    // 1 DAY BEFORE
    // =========================

    final bool oneDayBeforeEnabled =
    await NotificationSettingsService.getOneDayBeforeEnabled();

    if (oneDayBeforeEnabled &&
        reminderDates[1].isAfter(now)) {
      await NotificationService.scheduleNotification(
        id: '${person.id}_1'.hashCode,
        title: 'Birthday Reminder',
        body: '${person.name}\'s birthday is tomorrow!',
        scheduledDate: reminderDates[1],
      );
    } else if (!oneDayBeforeEnabled) {
      await NotificationService.cancelNotification(
        '${person.id}_1'.hashCode,
      );
    }

    // =========================
    // ON BIRTHDAY
    // =========================

    final bool onBirthdayEnabled =
    await NotificationSettingsService.getOnBirthdayEnabled();

    if (onBirthdayEnabled &&
        reminderDates[2].isAfter(now)) {
      await NotificationService.scheduleNotification(
        id: '${person.id}_0'.hashCode,
        title: 'Birthday 🎂',
        body: 'Today is ${person.name}\'s birthday!',
        scheduledDate: reminderDates[2],
      );
    } else if (!onBirthdayEnabled) {
      await NotificationService.cancelNotification(
        '${person.id}_0'.hashCode,
      );
    }
  }

  static Future<void> cancelBirthdayReminders(Person person) async {
    await NotificationService.cancelNotification(
      '${person.id}_7'.hashCode,
    );

    await NotificationService.cancelNotification(
      '${person.id}_1'.hashCode,
    );

    await NotificationService.cancelNotification(
      '${person.id}_0'.hashCode,
    );
  }
}