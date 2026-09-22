import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const WindowsInitializationSettings windowsSettings =
    WindowsInitializationSettings(
        appName: 'Persona',
        appUserModelId: 'com.persona.app',
        guid: '7f4a8c2e-1b63-4d91-9a52-6c8e37f1b204',
    );

    const InitializationSettings settings =
        InitializationSettings(
          android: androidSettings,
          windows: windowsSettings,
        );

    await notifications.initialize(settings: settings);
  }

  static Future<void> showTestNotification() async {
    await notifications.show(
      id: 0,
      title: 'Persona',
      body: 'This is a test birthday!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthday_channel',
          'Birthday Reminders',
          channelDescription: 'Notifications for upcoming birthdays',
          importance: Importance.high,
          priority: Priority.high,
        ),
        windows: WindowsNotificationDetails(),
      ),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(
          scheduledDate,
          tz.local,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'birthday_channel',
            'Birthday Reminders',
            channelDescription: 'Notifications for upcoming birthdays',
            importance: Importance.high,
            priority: Priority.high,
          ),
          windows: WindowsNotificationDetails(),
        ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await notifications.cancel(id: id);
  }
}