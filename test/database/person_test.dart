import 'package:flutter_test/flutter_test.dart';
import 'package:persona/models/person.dart';

void main() {
  group('Person', () {

    test('creates a Person with all required information', () {
      final Person person = Person(
        id: '1',
        name: 'Elizabeth',
        birthday: DateTime(2009, 5, 15),
        phoneNumber: '0123456789',
      );

      expect(person.id, '1');
      expect(person.name, 'Elizabeth');
      expect(person.birthday, DateTime(2009, 5, 15));
      expect(person.phoneNumber, '0123456789');
    });

    test('creates a Person without a phone number', () {
      final Person person = Person(
        id: '2',
        name: 'Test Person',
        birthday: DateTime(2000, 12, 25),
      );

      expect(person.id, '2');
      expect(person.name, 'Test Person');
      expect(person.birthday, DateTime(2000, 12, 25));
      expect(person.phoneNumber, isNull);
    });

    test('stores the correct birthday', () {
      final Person person = Person(
        id: '3',
        name: 'Birthday Test',
        birthday: DateTime(1999, 8, 20),
      );

      expect(person.birthday.year, 1999);
      expect(person.birthday.month, 8);
      expect(person.birthday.day, 20);
    });

    test('stores the correct phone number', () {
      final Person person = Person(
        id: '4',
        name: 'Phone Test',
        birthday: DateTime(2001, 3, 10),
        phoneNumber: '0712345678',
      );

      expect(person.phoneNumber, '0712345678');
    });

    test('phone number can be null', () {
      final Person person = Person(
        id: '5',
        name: 'No Phone',
        birthday: DateTime(2002, 7, 1),
        phoneNumber: null,
      );

      expect(person.phoneNumber, isNull);
    });
  });
}