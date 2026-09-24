import 'package:flutter_test/flutter_test.dart';
import 'package:persona/models/calendar_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:persona/database/database_helper.dart';
import 'package:persona/models/person.dart';

void main() {
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();

    final db = await databaseHelper.database;

    await db.delete('people');
    await db.delete('calendar_events');
  });

  group('DatabaseHelper', () {

    test('inserts and retrieves a person', () async {
      final Person person = Person(
        id: '1',
        name: 'Elizabeth',
        birthday: DateTime(2009, 5, 15),
        phoneNumber: '0123456789',
      );

      await databaseHelper.insertPerson(person);

      final List<Person> people =
      await databaseHelper.getPeople();

      expect(people.length, 1);
      expect(people[0].id, '1');
      expect(people[0].name, 'Elizabeth');
      expect(people[0].birthday, DateTime(2009, 5, 15));
      expect(people[0].phoneNumber, '0123456789');
    });

    test('updates a person', () async {
      final Person person = Person(
        id: '2',
        name: 'Old Name',
        birthday: DateTime(2000, 1, 1),
        phoneNumber: '0111111111',
      );

      await databaseHelper.insertPerson(person);

      final Person updatedPerson = Person(
        id: '2',
        name: 'New Name',
        birthday: DateTime(2001, 2, 2),
        phoneNumber: '0222222222',
      );

      await databaseHelper.updatePerson(updatedPerson);

      final List<Person> people =
      await databaseHelper.getPeople();

      expect(people.length, 1);
      expect(people[0].id, '2');
      expect(people[0].name, 'New Name');
      expect(people[0].birthday, DateTime(2001, 2, 2));
      expect(people[0].phoneNumber, '0222222222');
    });

    test('deletes a person', () async {
      final Person person = Person(
        id: '3',
        name: 'Delete Test',
        birthday: DateTime(2000, 3, 3),
      );

      await databaseHelper.insertPerson(person);

      await databaseHelper.deletePerson(person.id);

      final List<Person> people =
      await databaseHelper.getPeople();

      expect(people, isEmpty);
    });

    test('returns an empty list when there are no people', () async {
      final List<Person> people =
      await databaseHelper.getPeople();

      expect(people, isEmpty);
    });
  });

  test('inserts and retrieves a calendar event', () async {
    final CalendarEvent event = CalendarEvent(
      id: 'event_001',
      title: 'Study Chinese',
      date: DateTime(2026, 10, 5, 18, 0),
      description: 'Practice HSK vocabulary',
      reminder: true,
    );

    await databaseHelper.insertCalendarEvent(event);

    final List<CalendarEvent> events =
    await databaseHelper.getCalendarEvents();

    expect(events.length, 1);
    expect(events[0].id, 'event_001');
    expect(events[0].title, 'Study Chinese');
    expect(
      events[0].date,
      DateTime(2026, 10, 5, 18, 0),
    );
    expect(
      events[0].description,
      'Practice HSK vocabulary',
    );
    expect(events[0].reminder, true);
  });

  test('updates a calendar event', () async {
    final CalendarEvent event = CalendarEvent(
      id: 'event_002',
      title: 'Old Event',
      date: DateTime(2026, 10, 5, 18, 0),
      description: 'Old description',
      reminder: false,
    );

    await databaseHelper.insertCalendarEvent(event);

    final CalendarEvent updatedEvent = CalendarEvent(
      id: 'event_002',
      title: 'New Event',
      date: DateTime(2026, 10, 6, 19, 0),
      description: 'New description',
      reminder: true,
    );

    await databaseHelper.updateCalendarEvent(updatedEvent);

    final List<CalendarEvent> events =
    await databaseHelper.getCalendarEvents();

    expect(events.length, 1);
    expect(events[0].id, 'event_002');
    expect(events[0].title, 'New Event');
    expect(
      events[0].date,
      DateTime(2026, 10, 6, 19, 0),
    );
    expect(
      events[0].description,
      'New description',
    );
    expect(events[0].reminder, true);
  });

  test('deletes a calendar event', () async {
    final CalendarEvent event = CalendarEvent(
      id: 'event_003',
      title: 'Delete Test',
      date: DateTime(2026, 10, 7, 18, 0),
    );

    await databaseHelper.insertCalendarEvent(event);

    await databaseHelper.deleteCalendarEvent(event.id);

    final List<CalendarEvent> events =
    await databaseHelper.getCalendarEvents();

    expect(events, isEmpty);
  });

  test('returns an empty list when there are no calendar events', () async {
    final List<CalendarEvent> events =
    await databaseHelper.getCalendarEvents();

    expect(events, isEmpty);
  });
}