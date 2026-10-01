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
      version: 5,

      // =========================
      // CREATE DATABASE
      // =========================

      onCreate: (Database db, int version) async {
        // PEOPLE
        await db.execute('''
        CREATE TABLE people (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          birthday TEXT NOT NULL,
          phone_number TEXT
        )
        ''');

        // CALENDAR EVENTS
        await db.execute('''
        CREATE TABLE calendar_events (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT,
          reminder INTEGER NOT NULL,
          google_event_id TEXT
        )
        ''');

        // LOCATIONS
        await db.execute('''
        CREATE TABLE locations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          accuracy REAL NOT NULL,
          timestamp TEXT NOT NULL
        )
        ''');

        // EMERGENCY CONTACTS
        await db.execute('''
        CREATE TABLE emergency_contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone_number TEXT NOT NULL
        )
        ''');
      },

      // =========================
      // DATABASE UPGRADES
      // =========================

      onUpgrade: (
          Database db,
          int oldVersion,
          int newVersion,
          ) async {
        // =========================
        // VERSION 1 → VERSION 2
        // =========================

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

        // =========================
        // VERSION 2 → VERSION 3
        // =========================

        if (oldVersion < 3) {
          await db.execute('''
          ALTER TABLE calendar_events
          ADD COLUMN google_event_id TEXT
          ''');

          await db.execute('''
          CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL NOT NULL,
            timestamp TEXT NOT NULL
          )
          ''');
        }

        // =========================
        // VERSION 3 → VERSION 4
        // =========================

        if (oldVersion < 4) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS emergency_contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone_number TEXT NOT NULL
          )
          ''');
        }

        // =========================
        // VERSION 4 → VERSION 5
        // =========================

        if (oldVersion < 5) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL NOT NULL,
            timestamp TEXT NOT NULL
          )
          ''');
        }
      },
    );
  }

  // =========================
  // PEOPLE
  // =========================

  Future<void> insertPerson(Person person) async {
    final Database db = await database;

    await db.insert(
      'people',
      {
        'id': person.id,
        'name': person.name,
        'birthday': person.birthday.toIso8601String(),
        'phone_number': person.phoneNumber,
      },
    );
  }

  Future<List<Person>> getPeople() async {
    final Database db = await database;

    final List<Map<String, dynamic>> rows =
    await db.query('people');

    return rows.map((row) {
      return Person(
        id: row['id'] as String,
        name: row['name'] as String,
        birthday: DateTime.parse(
          row['birthday'] as String,
        ),
        phoneNumber: row['phone_number'] as String?,
      );
    }).toList();
  }

  Future<void> updatePerson(Person person) async {
    final Database db = await database;

    await db.update(
      'people',
      {
        'name': person.name,
        'birthday': person.birthday.toIso8601String(),
        'phone_number': person.phoneNumber,
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
      whereArgs: [id],
    );
  }

  // =========================
  // CALENDAR EVENTS
  // =========================

  Future<void> insertCalendarEvent(
      CalendarEvent event,
      ) async {
    final Database db = await database;

    await db.insert(
      'calendar_events',
      {
        'id': event.id,
        'title': event.title,
        'date': event.date.toIso8601String(),
        'description': event.description,
        'reminder': event.reminder ? 1 : 0,
        'google_event_id': event.googleEventId,
      },
    );
  }

  Future<List<CalendarEvent>> getCalendarEvents() async {
    final Database db = await database;

    final List<Map<String, dynamic>> rows =
    await db.query('calendar_events');

    return rows.map((row) {
      return CalendarEvent(
        id: row['id'] as String,
        title: row['title'] as String,
        date: DateTime.parse(
          row['date'] as String,
        ),
        description: row['description'] as String?,
        reminder: (row['reminder'] as int) == 1,
        googleEventId: row['google_event_id'] as String?,
      );
    }).toList();
  }

  Future<void> updateCalendarEvent(
      CalendarEvent event,
      ) async {
    final Database db = await database;

    await db.update(
      'calendar_events',
      {
        'title': event.title,
        'date': event.date.toIso8601String(),
        'description': event.description,
        'reminder': event.reminder ? 1 : 0,
        'google_event_id': event.googleEventId,
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteCalendarEvent(
      String id,
      ) async {
    final Database db = await database;

    await db.delete(
      'calendar_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // LOCATIONS
  // =========================

  Future<int> insertLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required DateTime timestamp,
  }) async {
    final Database db = await database;

    return await db.insert(
      'locations',
      {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final Database db = await database;

    return await db.query(
      'locations',
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> deleteAllLocations() async {
    final Database db = await database;

    await db.delete('locations');
  }

  // =========================
  // EMERGENCY CONTACTS
  // =========================

  Future<int> insertEmergencyContact({
    required String name,
    required String phoneNumber,
  }) async {
    final Database db = await database;

    return await db.insert(
      'emergency_contacts',
      {
        'name': name,
        'phone_number': phoneNumber,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final Database db = await database;

    return await db.query(
      'emergency_contacts',
      orderBy: 'id DESC',
    );
  }

  Future<void> updateEmergencyContact({
    required int id,
    required String name,
    required String phoneNumber,
  }) async {
    final Database db = await database;

    await db.update(
      'emergency_contacts',
      {
        'name': name,
        'phone_number': phoneNumber,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEmergencyContact(int id) async {
    final Database db = await database;

    await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}