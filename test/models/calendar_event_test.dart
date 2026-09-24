import 'package:flutter_test/flutter_test.dart';
import 'package:persona/models/calendar_event.dart';

void main() {
  group('CalendarEvent', () {
    test('creates a calendar event with required information', () {
      final DateTime eventDate = DateTime(2026, 10, 5, 18, 0);

      final CalendarEvent event = CalendarEvent(
        id: 'event_001',
        title: 'Study Chinese',
        date: eventDate,
      );

      expect(event.id, 'event_001');
      expect(event.title, 'Study Chinese');
      expect(event.date, eventDate);
      expect(event.description, isNull);
      expect(event.reminder, false);
    });

    test('stores an optional description', () {
      final CalendarEvent event = CalendarEvent(
        id: 'event_002',
        title: 'Study Korean',
        date: DateTime(2026, 10, 6, 18, 0),
        description: 'Practice TOPIK vocabulary',
      );

      expect(
        event.description,
        'Practice TOPIK vocabulary',
      );
    });

    test('can enable a reminder', () {
      final CalendarEvent event = CalendarEvent(
        id: 'event_003',
        title: 'Study Turkish',
        date: DateTime(2026, 10, 7, 18, 0),
        reminder: true,
      );

      expect(event.reminder, true);
    });
  });
}