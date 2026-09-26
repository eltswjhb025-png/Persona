import 'package:googleapis/calendar/v3.dart' as calendar;
import 'google_auth_service.dart';

class GoogleCalendarService {
  static Future<calendar.CalendarApi?> getCalendarApi() async {
    final client = await GoogleAuthService.authenticatedClient;

    if (client == null) {
      print('GOOGLE CALENDAR: No authenticated client.');
      return null;
    }

    return calendar.CalendarApi(client);
  }

  static Future<void> getCalendars() async {
    final calendarApi = await getCalendarApi();

    if (calendarApi == null) {
      return;
    }

    try {
      final calendars = await calendarApi.calendarList.list();

      print('========== GOOGLE CALENDARS ==========');

      for (final item in calendars.items ?? []) {
        print(
          'ID: ${item.id} | '
              'NAME: ${item.summary}',
        );
      }

      print('======================================');
    } catch (e) {
      print('GOOGLE CALENDAR ERROR: $e');
    }
  }

  static Future<List<calendar.Event>> getSouthAfricanHolidays({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final calendarApi = await getCalendarApi();

    if (calendarApi == null) {
      return [];
    }

    try {
      final holidays = await calendarApi.events.list(
        'en.sa#holiday@group.v.calendar.google.com',
        timeMin: startDate.toUtc(),
        timeMax: endDate.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      print(
        'GOOGLE HOLIDAYS: '
            '${holidays.items?.length ?? 0} events found.',
      );

      for (final event in holidays.items ?? []) {
        print(
          'HOLIDAY: ${event.summary} | '
              'DATE: ${event.start?.date ?? event.start?.dateTime}',
        );
      }

      return holidays.items ?? [];
    } catch (e) {
      print('GOOGLE HOLIDAY ERROR: $e');
      return [];
    }
  }
}