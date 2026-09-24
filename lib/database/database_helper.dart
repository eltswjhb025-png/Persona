import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';
import '../models/calendar_event.dart';

class DatabaseHelper {
  Future<Database> get database async {
    final String path = join(
      await getDatabasesPath(),
      'persona.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE people (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          birthday TEXT NOT NULL,
          phone_number TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        reminder INTEGER NOT NULL
        )
        ''');
      },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
        CREATE TABLE calendar_events (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT,
          reminder INTEGER NOT NULL
        )
      ''');
      }
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

  Future<void> insertCalendarEvent(CalendarEvent event) async {
    final Database db = await database;

    await db.insert(
      'calendar_events',
      {
        'id': event.id,
        'title': event.title,
        'date': event.date.toIso8601String(),
        'description': event.description,
        'reminder': event.reminder ? 1 : 0,
      },
    );
  }
  Future<List<CalendarEvent>> getCalendarEvents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> rows = await db.query(
      'calendar_events',
    );

    return rows.map((row) {
      return CalendarEvent(
        id: row['id'] as String,
        title: row['title'] as String,
        date: DateTime.parse(row['date'] as String),
        description: row['description'] as String?,
        reminder: (row['reminder'] as int) == 1,
      );
    }).toList();
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    final Database db = await database;

    await db.update(
      'calendar_events',
      {
        'title': event.title,
        'date': event.date.toIso8601String(),
        'description': event.description,
        'reminder': event.reminder ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteCalendarEvent(String id) async {
    final Database db = await database;

    await db.delete(
      'calendar_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}