import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel birthdayChannel =
  AndroidNotificationChannel(
    'birthday_channel',
    'Birthday Reminders',
    description: 'Notifications for upcoming birthdays and reminders',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const WindowsInitializationSettings windowsSettings =
    WindowsInitializationSettings(
      appName: 'Persona',
      appUserModelId: 'com.persona.app',
      guid: '7f4a8c2e-1b63-4d91-9a52-6c8e37f1b204',
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    // Initialize notifications
    await notifications.initialize(
      settings: settings,
    );

    // Android-specific setup
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Request Android 13+ notification permission
      await androidPlugin.requestNotificationsPermission();

      // Create notification channel
      await androidPlugin.createNotificationChannel(
        birthdayChannel,
      );
    }
  }

  // =========================
  // Test Notification
  // =========================

  static Future<void> showTestNotification() async {
    final bool notificationsEnabled =
    await NotificationSettingsService.getNotificationsEnabled();

    if (!notificationsEnabled) {
      return;
    }

    final bool soundsEnabled =
    await NotificationSettingsService.getReminderSoundsEnabled();

    await notifications.show(
      id: 0,
      title: 'Persona',
      body: 'This is a test birthday notification! 🎂',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          birthdayChannel.id,
          birthdayChannel.name,
          channelDescription: birthdayChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: soundsEnabled,
        ),
        windows: const WindowsNotificationDetails(),
      ),
    );
  }

  // =========================
  // Schedule Notification
  // =========================

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final bool notificationsEnabled =
    await NotificationSettingsService.getNotificationsEnabled();

    if (!notificationsEnabled) {
      return;
    }

    final bool soundsEnabled =
    await NotificationSettingsService.getReminderSoundsEnabled();

    final tz.TZDateTime notificationDate =
    tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notificationDate,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          birthdayChannel.id,
          birthdayChannel.name,
          channelDescription: birthdayChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: soundsEnabled,
        ),
        windows: const WindowsNotificationDetails(),
      ),
    );
  }

  // =========================
  // Cancel Notification
  // =========================

  static Future<void> cancelNotification(int id) async {
    await notifications.cancel(
      id: id,
    );
  }
}