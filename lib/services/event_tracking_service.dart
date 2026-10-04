import '../database/database_helper.dart';

class EventTrackingService {
  static final DatabaseHelper _databaseHelper =
  DatabaseHelper();

  // =========================
  // EVENT TYPES
  // =========================

  static const String birthdayAdded =
      'BIRTHDAY_ADDED';

  static const String birthdayEdited =
      'BIRTHDAY_EDITED';

  static const String birthdayDeleted =
      'BIRTHDAY_DELETED';

  static const String reminderScheduled =
      'REMINDER_SCHEDULED';

  static const String reminderTriggered =
      'REMINDER_TRIGGERED';

  static const String calendarEventCreated =
      'CALENDAR_EVENT_CREATED';

  static const String calendarEventUpdated =
      'CALENDAR_EVENT_UPDATED';

  static const String calendarEventDeleted =
      'CALENDAR_EVENT_DELETED';

  static const String emergencyContactAdded =
      'EMERGENCY_CONTACT_ADDED';

  static const String emergencyContactUpdated =
      'EMERGENCY_CONTACT_UPDATED';

  static const String emergencyContactDeleted =
      'EMERGENCY_CONTACT_DELETED';

  static const String sosTriggered =
      'SOS_TRIGGERED';

  static const String locationRecorded =
      'LOCATION_RECORDED';

  // =========================
  // RECORD EVENT
  // =========================

  static Future<int> recordEvent({
    required String eventType,
    String? personId,
    String? metadata,
  }) async {
    return await _databaseHelper.insertEvent(
      eventType: eventType,
      timestamp: DateTime.now(),
      personId: personId,
      metadata: metadata,
    );
  }

  // =========================
  // GET ALL EVENTS
  // =========================

  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    return await _databaseHelper.getEvents();
  }

  // =========================
  // DELETE ALL EVENTS
  // =========================

  static Future<void> deleteAllEvents() async {
    await _databaseHelper.deleteAllEvents();
  }

  // =========================
  // BIRTHDAY EVENTS
  // =========================

  static Future<int> recordBirthdayAdded({
    required String personId,
  }) async {
    return await recordEvent(
      eventType: birthdayAdded,
      personId: personId,
    );
  }

  static Future<int> recordBirthdayEdited({
    required String personId,
  }) async {
    return await recordEvent(
      eventType: birthdayEdited,
      personId: personId,
    );
  }

  static Future<int> recordBirthdayDeleted({
    required String personId,
  }) async {
    return await recordEvent(
      eventType: birthdayDeleted,
      personId: personId,
    );
  }

  // =========================
  // REMINDER EVENTS
  // =========================

  static Future<int> recordReminderScheduled({
    String? personId,
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: reminderScheduled,
      personId: personId,
      metadata: metadata,
    );
  }

  static Future<int> recordReminderTriggered({
    String? personId,
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: reminderTriggered,
      personId: personId,
      metadata: metadata,
    );
  }

  // =========================
  // CALENDAR EVENTS
  // =========================

  static Future<int> recordCalendarEventCreated({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: calendarEventCreated,
      metadata: metadata,
    );
  }

  static Future<int> recordCalendarEventUpdated({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: calendarEventUpdated,
      metadata: metadata,
    );
  }

  static Future<int> recordCalendarEventDeleted({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: calendarEventDeleted,
      metadata: metadata,
    );
  }

  // =========================
  // EMERGENCY CONTACT EVENTS
  // =========================

  static Future<int> recordEmergencyContactAdded({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: emergencyContactAdded,
      metadata: metadata,
    );
  }

  static Future<int> recordEmergencyContactUpdated({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: emergencyContactUpdated,
      metadata: metadata,
    );
  }

  static Future<int> recordEmergencyContactDeleted({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: emergencyContactDeleted,
      metadata: metadata,
    );
  }

  // =========================
  // SOS EVENTS
  // =========================

  static Future<int> recordSosTriggered({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: sosTriggered,
      metadata: metadata,
    );
  }

  // =========================
  // LOCATION EVENTS
  // =========================

  static Future<int> recordLocationRecorded({
    String? metadata,
  }) async {
    return await recordEvent(
      eventType: locationRecorded,
      metadata: metadata,
    );
  }
}