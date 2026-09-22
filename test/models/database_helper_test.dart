import 'package:flutter_test/flutter_test.dart';
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
}