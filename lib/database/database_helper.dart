import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';

class DatabaseHelper {
  Future<Database> get database async {
    final String path = join(
      await getDatabasesPath(),
      'persona.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE people (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          birthday TEXT NOT NULL,
          phone_number TEXT
        )
        ''');
      },
    );
  }

  Future<void> insertPerson(Person person) async {
    final Database db = await database;

    await db.insert(
        'people',
      {
        'id' : person.id,
        'name' : person.name,
        'birthday' : person.birthday.toIso8601String(),
        'phone_number' : person.phoneNumber,
      },
    );
  }

  Future<List<Person>> getPeople() async {
    final Database db = await database;

    final List<Map<String, dynamic>> rows = await db.query(
      'people',
    );

    return rows.map((row) {
      return Person(
        id: row['id'] as String,
        name: row['name'] as String,
        birthday: DateTime.parse(row['birthday'] as String),
        phoneNumber: row['phone_number'] as String?,
      );
    }).toList();
  }

  Future<void> updatePerson(Person person) async {
    final Database db = await database;

    await db.update(
      'people',
      {
        'name' : person.name,
        'birthday' : person.birthday.toIso8601String(),
        'phone_number' : person.phoneNumber,
      },
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<void> deletePerson(String id) async {
    final Database db = await database;

    await db.delete(
      'people',
      where: 'id = ?',
      whereArgs:  [id],
    );
  }
}