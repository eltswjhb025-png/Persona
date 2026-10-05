import '../models/calendar_event.dart';
import 'notification_service.dart';
import 'notification_settings_service.dart';

class EventReminderService {
  /// Schedules or refreshes the reminder for a calendar event.
  static Future<void> scheduleEventReminder(
      CalendarEvent event,
      ) async {
    // Always cancel the old reminder first.
    // This prevents duplicate notifications when an event is edited.
    await cancelEventReminder(event);

    // No reminder requested for this event.
    if (!event.reminder) {
      return;
    }

    // Check the global notification setting.
    final bool notificationsEnabled =
    await NotificationSettingsService.getNotificationsEnabled();

    if (!notificationsEnabled) {
      return;
    }

    // Check the global calendar-event reminder setting.
    final bool eventRemindersEnabled =
    await NotificationSettingsService.getEventRemindersEnabled();

    if (!eventRemindersEnabled) {
      return;
    }

    // Get the configured reminder time.
    final int reminderMinutes =
    await NotificationSettingsService.getEventReminderMinutes();

    // Calculate when the notification should appear.
    final DateTime reminderDate = event.date.subtract(
      Duration(minutes: reminderMinutes),
    );

    // Do not schedule notifications in the past.
    if (!reminderDate.isAfter(DateTime.now())) {
      return;
    }

    await NotificationService.scheduleNotification(
      id: event.id.hashCode,
      title: 'Event Reminder',
      body: _buildReminderMessage(
        event,
        reminderMinutes,
      ),
      scheduledDate: reminderDate,
    );
  }

  /// Cancels the reminder for a calendar event.
  static Future<void> cancelEventReminder(
      CalendarEvent event,
      ) async {
    await NotificationService.cancelNotification(
      event.id.hashCode,
    );
  }

  /// Refreshes an event reminder after its settings/details change.
  static Future<void> refreshEventReminder(
      CalendarEvent event,
      ) async {
    await cancelEventReminder(event);
    await scheduleEventReminder(event);
  }

  /// Creates the notification message based on the reminder timing.
  static String _buildReminderMessage(
      CalendarEvent event,
      int minutes,
      ) {
    if (minutes == 0) {
      return 'Your event "${event.title}" is starting now.';
    }

    if (minutes == 60) {
      return 'Your event "${event.title}" starts in 1 hour.';
    }

    return 'Your event "${event.title}" starts in $minutes minutes.';
  }
}