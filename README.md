# Persona

Persona is a Flutter mobile application designed to help users manage important people, birthdays, calendar events, reminders, emergency contacts, and personal safety information in one place.

The application combines local data storage, Google Calendar integration, birthday notifications, location services, emergency assistance, authentication, and a customizable interface.

## Features

### 🎂 Birthday Management

* Add, edit, and delete birthdays.
* Store a person's name, birthday, and optional phone number.
* View upcoming birthdays.
* Schedule birthday reminders.
* Support reminders:

  * 7 days before
  * 1 day before
  * On the birthday
* Birthday reminder preferences can be enabled or disabled from Settings.

### 📅 Calendar

* Create and manage local calendar events.
* Store event title, date, description, and reminder settings.
* View upcoming events.
* Integrate with Google Calendar.
* Local calendar events are stored in SQLite.
* Local calendar functionality remains available when Google Calendar cannot connect.

### 🔔 Notifications & Reminders

* Birthday notifications.
* Configurable reminder timing.
* Notification enable/disable setting.
* Reminder sound setting.
* Uses Android notification channels and scheduled notifications.

### 👤 Profile

* View and edit profile information.
* Update name, email, and phone information.
* Upload a profile photo.
* Store the selected profile photo locally.

### 👥 Emergency Contacts

* Add emergency contacts.
* Edit emergency contacts.
* Delete emergency contacts.
* Store emergency contacts persistently using SQLite.

### 🆘 SOS

* Obtain the user's current GPS location.
* Save location information locally.
* Generate a Google Maps location link.
* Prepare an SMS message containing the emergency location.
* Send the emergency message to saved emergency contacts.

### 📍 Locator

* Access the device's location.
* Display location information for safety and assistance features.

### 🔐 Authentication

* Firebase email/password authentication.
* Account creation.
* Login.
* Forgot-password functionality.
* Google authentication support.

### ⚙️ Settings

* Dark/light theme.
* Notification preferences.
* Reminder preferences.
* Emergency contact management.
* Profile access.
* About section.
* Logout.

### 🎨 User Interface

Persona uses a glassmorphism-inspired interface with an olive/cream visual theme.

Main colours include:

* Olive Drab: `#6B8E23`
* Olive: `#808000`
* Dark Olive: `#3F4A16`
* Light Cream: `#F4F5E9`
* Dark Background: `#1E2412`
* Dark Card: `#2B321B`

The application supports both light and dark themes.

---

## Technology Stack

| Technology                  | Purpose                              |
| --------------------------- | ------------------------------------ |
| Flutter                     | Cross-platform application framework |
| Dart                        | Programming language                 |
| Firebase Authentication     | User authentication                  |
| SQLite                      | Local persistent data storage        |
| sqflite                     | SQLite database access               |
| sqflite_common_ffi          | SQLite support for desktop testing   |
| Google Calendar API         | Google Calendar integration          |
| Flutter Local Notifications | Birthday/reminder notifications      |
| SharedPreferences           | Notification preference storage      |
| Geolocator                  | GPS/location services                |
| Google Maps links           | Location sharing                     |
| File Picker                 | Profile photo selection              |

---

## Data Storage

Persona uses **SQLite** for important locally stored application data. The database is named `persona.db`.

The database currently uses **version 6**.

### Database Tables

#### `people`

Stores information about people and their birthdays.

| Field          | Type             | Description           |
| -------------- | ---------------- | --------------------- |
| `id`           | TEXT PRIMARY KEY | Unique person ID      |
| `name`         | TEXT NOT NULL    | Person's name         |
| `birthday`     | TEXT NOT NULL    | Person's birthday     |
| `phone_number` | TEXT             | Optional phone number |

#### `calendar_events`

Stores local Persona calendar events.

| Field             | Type             | Description                                 |
| ----------------- | ---------------- | ------------------------------------------- |
| `id`              | TEXT PRIMARY KEY | Unique event ID                             |
| `title`           | TEXT NOT NULL    | Event title                                 |
| `date`            | TEXT NOT NULL    | Event date and time                         |
| `description`     | TEXT             | Optional event description                  |
| `reminder`        | INTEGER NOT NULL | `1` if a reminder is enabled, otherwise `0` |
| `google_event_id` | TEXT             | Optional Google Calendar event ID           |

#### `locations`

Stores GPS location information used by the Locator and SOS features.

| Field       | Type                              | Description                             |
| ----------- | --------------------------------- | --------------------------------------- |
| `id`        | INTEGER PRIMARY KEY AUTOINCREMENT | Automatically generated location ID     |
| `latitude`  | REAL NOT NULL                     | GPS latitude                            |
| `longitude` | REAL NOT NULL                     | GPS longitude                           |
| `accuracy`  | REAL NOT NULL                     | GPS accuracy                            |
| `timestamp` | TEXT NOT NULL                     | Date and time the location was recorded |

#### `emergency_contacts`

Stores emergency contacts used by the SOS feature.

| Field          | Type                              | Description                        |
| -------------- | --------------------------------- | ---------------------------------- |
| `id`           | INTEGER PRIMARY KEY AUTOINCREMENT | Automatically generated contact ID |
| `name`         | TEXT NOT NULL                     | Emergency contact's name           |
| `phone_number` | TEXT NOT NULL                     | Emergency contact's phone number   |

#### `event_tracking`

Stores important application events for tracking and data engineering purposes.

| Field             | Type                              | Description                           |
| ----------------- | --------------------------------- | ------------------------------------- |
| `id`              | INTEGER PRIMARY KEY AUTOINCREMENT | Automatically generated event ID      |
| `event_type`      | TEXT NOT NULL                     | Type of event that occurred           |
| `event_timestamp` | TEXT NOT NULL                     | Date and time the event occurred      |
| `person_id`       | TEXT                              | Related person ID, when applicable    |
| `metadata`        | TEXT                              | Optional additional event information |

### Database Relationships

The main relationships between the data are:

```text
people
  │
  │ person_id
  ▼
event_tracking

calendar_events
  │
  └── google_event_id
          │
          ▼
   Google Calendar
```

### Data Persistence

| Data                     | Storage             | Feature                   |
| ------------------------ | ------------------- | ------------------------- |
| People and birthdays     | SQLite              | Birthday Management       |
| Local calendar events    | SQLite              | Calendar                  |
| GPS locations            | SQLite              | Locator / SOS             |
| Emergency contacts       | SQLite              | SOS                       |
| Application events       | SQLite              | Event Tracking            |
| Notification preferences | SharedPreferences   | Notifications & Reminders |
| Google Calendar events   | Google Calendar API | Calendar Integration      |

### Database Operations

`DatabaseHelper` handles database creation and CRUD operations.

The main database operations include:

* Creating database tables.
* Inserting records.
* Reading records.
* Updating records.
* Deleting records.
* Deleting stored locations.
* Deleting tracked events.
* Managing database upgrades.

The data flow is:

```text
User Action
     ↓
Screen
     ↓
DatabaseHelper
     ↓
SQLite
     ↓
persona.db
```

### Database Versioning

Persona currently uses **SQLite database version 6**.

The database has evolved to support:

```text
Version 1
   ↓
People
   ↓
Version 2
   ↓
Calendar Events
   ↓
Version 3
   ↓
Google Event IDs + Locations
   ↓
Version 4
   ↓
Emergency Contacts
   ↓
Version 5
   ↓
Location support maintained
   ↓
Version 6
   ↓
Event Tracking
```

Database upgrades are handled using SQLite's `onUpgrade` mechanism.

### Local and External Data

Persona separates locally stored data from external Google Calendar data.

```text
                    Persona
                       │
              ┌────────┴────────┐
              │                 │
         Local Data        External Data
              │                 │
           SQLite         Google Calendar
              │                 │
          persona.db       Google Calendar API
```

This separation allows local Persona data to continue functioning even when the Google Calendar connection is unavailable.

---

## Commands

### Flutter Commands

| Command                   | Purpose                                                        |
| ------------------------- | -------------------------------------------------------------- |
| `flutter doctor`          | Checks the Flutter development environment                     |
| `flutter doctor -v`       | Displays detailed Flutter environment information              |
| `flutter pub get`         | Installs project dependencies                                  |
| `flutter pub upgrade`     | Updates project dependencies                                   |
| `flutter clean`           | Removes previous build files and cached build artifacts        |
| `flutter run`             | Runs the Persona application on a connected device or emulator |
| `flutter devices`         | Lists available connected devices                              |
| `flutter analyze`         | Analyzes the Dart code for errors and warnings                 |
| `flutter test`            | Runs the automated test suite                                  |
| `flutter test --coverage` | Runs tests and generates test coverage information             |
| `flutter build apk`       | Builds an Android APK                                          |
| `flutter build appbundle` | Builds an Android App Bundle                                   |
| `flutter --version`       | Displays the installed Flutter and Dart versions               |

### Running the Application

```bash
flutter pub get
flutter run
```

### Running Tests

Run the complete automated test suite:

```bash
flutter test
```

Persona's current test suite contains **42 passing tests**.

### Code Analysis

Check the project for Dart errors, warnings, and other analyzer issues:

```bash
flutter analyze
```

### Cleaning and Rebuilding

If the application has build or dependency issues:

```bash
flutter clean
flutter pub get
flutter run
```

### Building for Android

Build a standard APK:

```bash
flutter build apk
```

Build a release APK:

```bash
flutter build apk --release
```

Build a release Android App Bundle:

```bash
flutter build appbundle --release
```

### Git Commands

| Command                   | Purpose                                                 |
| ------------------------- | ------------------------------------------------------- |
| `git status`              | Displays changed and untracked files                    |
| `git add .`               | Stages project changes                                  |
| `git commit -m "message"` | Creates a commit                                        |
| `git log --oneline`       | Displays a compact commit history                       |
| `git branch`              | Displays available branches                             |
| `git checkout <branch>`   | Switches to a branch                                    |
| `git pull`                | Retrieves and merges changes from the remote repository |
| `git push`                | Uploads local commits to the remote repository          |
| `git remote -v`           | Displays configured remote repositories                 |

### Typical Git Workflow

```bash
git status
git add .
git commit -m "Describe changes"
git push
```

### Firebase Commands

| Command                     | Purpose                                     |
| --------------------------- | ------------------------------------------- |
| `firebase --version`        | Displays the installed Firebase CLI version |
| `firebase login`            | Logs into Firebase                          |
| `firebase projects:list`    | Lists available Firebase projects           |
| `firebase use <project-id>` | Selects a Firebase project                  |

### Recommended Development Workflow

```text
Make Changes
     ↓
flutter pub get
     ↓
flutter analyze
     ↓
flutter test
     ↓
flutter run
     ↓
Test on Android Device
     ↓
git status
     ↓
git add .
     ↓
git commit
     ↓
git push
```

---

## Project Structure

```text
lib/
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── calendar_event.dart
│   └── person.dart
│
├── screens/
│   ├── add_person_screen.dart
│   ├── birthdays_screen.dart
│   ├── calendar_screen.dart
│   ├── emergency_contacts_screen.dart
│   ├── home_screen.dart
│   ├── locator_screen.dart
│   ├── login_screen.dart
│   ├── notification_settings_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── sos_screen.dart
│
├── services/
│   ├── google_calendar_service.dart
│   ├── notification_service.dart
│   ├── notification_settings_service.dart
│   ├── reminder_service.dart
│   └── theme_service.dart
│
└── main.dart
```
