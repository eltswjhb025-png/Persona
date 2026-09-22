import 'package:flutter_test/flutter_test.dart';
import 'package:persona/models/person.dart';
import 'package:persona/services/reminder_service.dart';

void main() {
  group('ReminderService', () {

    test('getNextBirthday returns the correct next birthday', () {
      final Person person = Person(
        id: '1',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final DateTime result =
      ReminderService.getNextBirthday(person);

      expect(result.month, 12);
      expect(result.day, 25);
    });

    test('getReminderDates returns three reminder dates', () {
      final Person person = Person(
        id: '2',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final List<DateTime> reminderDates =
      ReminderService.getReminderDates(person);

      expect(reminderDates.length, 3);
    });

    test('first reminder is 7 days before birthday', () {
      final Person person = Person(
        id: '3',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final DateTime birthday =
      ReminderService.getNextBirthday(person);

      final List<DateTime> reminderDates =
      ReminderService.getReminderDates(person);

      expect(
        reminderDates[0],
        birthday.subtract(const Duration(days: 7)),
      );
    });

    test('second reminder is 1 day before birthday', () {
      final Person person = Person(
        id: '4',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final DateTime birthday =
      ReminderService.getNextBirthday(person);

      final List<DateTime> reminderDates =
      ReminderService.getReminderDates(person);

      expect(
        reminderDates[1],
        birthday.subtract(const Duration(days: 1)),
      );
    });

    test('third reminder is on the birthday', () {
      final Person person = Person(
        id: '5',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final DateTime birthday =
      ReminderService.getNextBirthday(person);

      final List<DateTime> reminderDates =
      ReminderService.getReminderDates(person);

      expect(
        reminderDates[2],
        birthday,
      );
    });

    test('reminder dates are in the correct order', () {
      final Person person = Person(
        id: '6',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      final List<DateTime> reminderDates =
      ReminderService.getReminderDates(person);

      expect(
        reminderDates[0].isBefore(reminderDates[1]),
        true,
      );

      expect(
        reminderDates[1].isBefore(reminderDates[2]),
        true,
      );
    });
  });
}