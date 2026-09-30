import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/calendar_event.dart';
import '../models/person.dart';
import '../services/notification_service.dart';
import 'add_calendar_event_screen.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../services/google_calendar_service.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  final DatabaseHelper databaseHelper = DatabaseHelper();

  List<CalendarEvent> events = [];
  List<Person> people = [];
  List<calendar.Event> googleHolidays = [];

  Future<void> loadEvents() async {
    final List<CalendarEvent> savedEvents =
    await databaseHelper.getCalendarEvents();

    final List<Person> savedPeople =
    await databaseHelper.getPeople();

    if (!mounted) {
      return;
    }

    setState(() {
      events = savedEvents;
      people = savedPeople;
    });
  }

  Future<void> loadGoogleHolidays() async {
    final DateTime startDate = DateTime(
      selectedDate.year,
      1,
      1,
    );

    final DateTime endDate = DateTime(
      selectedDate.year + 1,
      1,
      1,
    );

    final List<calendar.Event> holidays =
    await GoogleCalendarService.getSouthAfricanHolidays(
      startDate: startDate,
      endDate: endDate,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      googleHolidays = holidays;
    });
  }

  @override
  void initState() {
    super.initState();

    loadEvents();
    loadGoogleHolidays();
  }

  List<CalendarEvent> getEventsForSelectedDate() {
    return events.where((CalendarEvent event) {
      return event.date.year == selectedDate.year &&
          event.date.month == selectedDate.month &&
          event.date.day == selectedDate.day;
    }).toList();
  }

  List<Person> getBirthdaysForSelectedDate() {
    return people.where((Person person) {
      return person.birthday.month == selectedDate.month &&
          person.birthday.day == selectedDate.day;
    }).toList();
  }

  List<calendar.Event> getGoogleHolidaysForSelectedDate() {
    return googleHolidays.where((calendar.Event event) {
      final DateTime? holidayDate = event.start?.date;

      if (holidayDate == null) {
        return false;
      }

      return holidayDate.month == selectedDate.month &&
          holidayDate.day == selectedDate.day;
    }).toList();
  }

  bool hasCalendarEvent(DateTime day) {
    return events.any((CalendarEvent event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    });
  }

  bool hasBirthday(DateTime day) {
    return people.any((Person person) {
      return person.birthday.month == day.month &&
          person.birthday.day == day.day;
    });
  }

  bool hasGoogleHoliday(DateTime day) {
    return googleHolidays.any((calendar.Event event) {
      final DateTime? holidayDate = event.start?.date;

      if (holidayDate == null) {
        return false;
      }

      return holidayDate.year == day.year &&
          holidayDate.month == day.month &&
          holidayDate.day == day.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color olive = Color.fromRGBO(128, 128, 0, 1);
    const Color oliveDrab = Color.fromRGBO(107, 142, 35, 1);

    // Check whether Dark Mode is currently enabled.
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    // Background colours change depending on the theme.
    final Color screenBackground = isDarkMode
        ? const Color(0xFF121510)
        : oliveDrab;

    final Color calendarBackground = isDarkMode
        ? const Color(0xFF1E231B)
        : Colors.white;

    final Color calendarTextColor = isDarkMode
        ? Colors.white
        : Colors.black87;

    final Color calendarOutsideTextColor = isDarkMode
        ? Colors.white38
        : Colors.black38;

    return Scaffold(
      backgroundColor: screenBackground,

      // The global AppBar theme from main.dart controls the colour.
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [
            // --------------------------------------------------
            // CALENDAR
            // --------------------------------------------------
            Card(
              color: calendarBackground,
              elevation: 5,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: SizedBox(
                height: 430,

                child: TableCalendar(
                  firstDay: DateTime(1900),

                  lastDay: DateTime(
                    DateTime.now().year + 10,
                    12,
                    31,
                  ),

                  focusedDay: selectedDate,

                  selectedDayPredicate: (day) {
                    return isSameDay(
                      day,
                      selectedDate,
                    );
                  },

                  onDaySelected:
                      (selectedDay, focusedDay) async {
                    final bool yearChanged =
                        selectedDay.year != selectedDate.year;

                    setState(() {
                      selectedDate = selectedDay;
                    });

                    if (yearChanged) {
                      await loadGoogleHolidays();
                    }
                  },

                  // --------------------------------------------------
                  // CALENDAR STYLE
                  // --------------------------------------------------
                  calendarStyle: CalendarStyle(
                    // Today's date.
                    todayDecoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),

                    // Selected date.
                    selectedDecoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),

                    // Normal calendar text.
                    defaultTextStyle: TextStyle(
                      color: calendarTextColor,
                    ),

                    // Weekend text.
                    weekendTextStyle: TextStyle(
                      color: calendarTextColor,
                    ),

                    // Days from another month.
                    outsideTextStyle: TextStyle(
                      color: calendarOutsideTextColor,
                    ),

                    // Disabled dates.
                    disabledTextStyle: TextStyle(
                      color: calendarOutsideTextColor,
                    ),
                  ),

                  // --------------------------------------------------
                  // EVENT / BIRTHDAY / HOLIDAY INDICATORS
                  // --------------------------------------------------
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder:
                        (context, day, focusedDay) {
                      final bool event =
                      hasCalendarEvent(day);

                      final bool birthday =
                      hasBirthday(day);

                      final bool holiday =
                      hasGoogleHoliday(day);

                      if (!event &&
                          !birthday &&
                          !holiday) {
                        return null;
                      }

                      Color backgroundColor;

                      if (holiday) {
                        backgroundColor = Colors.red;
                      } else if (birthday) {
                        backgroundColor = Colors.pink;
                      } else {
                        backgroundColor = Colors.green;
                      }

                      return Container(
                        margin: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          color: backgroundColor,
                          shape: BoxShape.circle,
                        ),

                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // SELECTED DATE
            // --------------------------------------------------
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: olive,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  const Text(
                    'Selected Date',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // EVENTS HEADING
            // --------------------------------------------------
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Events & Birthdays',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // EVENTS
            // --------------------------------------------------
            Builder(
              builder: (context) {
                final List<CalendarEvent> selectedEvents =
                getEventsForSelectedDate();

                final List<Person> selectedBirthdays =
                getBirthdaysForSelectedDate();

                final List<calendar.Event> selectedHolidays =
                getGoogleHolidaysForSelectedDate();

                // --------------------------------------------------
                // NO EVENTS
                // --------------------------------------------------
                if (selectedEvents.isEmpty &&
                    selectedBirthdays.isEmpty &&
                    selectedHolidays.isEmpty) {
                  return Center(
                    child: Card(
                      color: olive,
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(25),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: const [
                            Icon(
                              Icons.event_available,
                              size: 55,
                              color: Colors.white,
                            ),

                            SizedBox(height: 15),

                            Text(
                              'No events for this date',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // --------------------------------------------------
                // EVENT LIST
                // --------------------------------------------------
                return Column(
                  children: [
                    // --------------------------------------------------
                    // GOOGLE HOLIDAYS
                    // --------------------------------------------------
                    ...selectedHolidays
                        .map((calendar.Event holiday) {
                      return Card(
                        color: olive,
                        elevation: 4,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.all(12),

                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,

                            child: Icon(
                              Icons.flag,
                              color: Colors.black,
                            ),
                          ),

                          title: Text(
                            holiday.summary ??
                                'South African Holiday',

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          subtitle: const Text(
                            'South African Holiday',

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }),

                    // --------------------------------------------------
                    // BIRTHDAYS
                    // --------------------------------------------------
                    ...selectedBirthdays
                        .map((Person person) {
                      return Card(
                        color: olive,
                        elevation: 4,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.all(12),

                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,

                            child: Icon(
                              Icons.cake,
                              color: Colors.black,
                            ),
                          ),

                          title: Text(
                            '${person.name}\'s Birthday',

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          subtitle: const Text(
                            'Birthday',

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }),

                    // --------------------------------------------------
                    // CALENDAR EVENTS
                    // --------------------------------------------------
                    ...selectedEvents
                        .map((CalendarEvent event) {
                      return Card(
                        color: olive,
                        elevation: 4,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.all(12),

                          leading: CircleAvatar(
                            backgroundColor:
                            Colors.white,

                            child: Icon(
                              event.reminder
                                  ? Icons.notifications
                                  : Icons.event,
                              color: Colors.black,
                            ),
                          ),

                          title: Text(
                            event.title,

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            '${event.date.hour.toString().padLeft(2, '0')}:'
                                '${event.date.minute.toString().padLeft(2, '0')}'
                                '${event.description != null ? '\n${event.description}' : ''}',

                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          trailing: Row(
                            mainAxisSize:
                            MainAxisSize.min,

                            children: [
                              if (event.reminder)
                                const Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                ),

                              // --------------------------------------------------
                              // EDIT
                              // --------------------------------------------------
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),

                                onPressed: () async {
                                  final CalendarEvent?
                                  updatedEvent =
                                  await Navigator.push<
                                      CalendarEvent>(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddCalendarEventScreen(
                                            event: event,
                                          ),
                                    ),
                                  );

                                  if (updatedEvent ==
                                      null) {
                                    return;
                                  }

                                  await NotificationService
                                      .cancelNotification(
                                    event.id.hashCode,
                                  );

                                  await databaseHelper
                                      .updateCalendarEvent(
                                    updatedEvent,
                                  );

                                  if (updatedEvent.reminder) {
                                    await NotificationService
                                        .scheduleNotification(
                                      id: updatedEvent
                                          .id
                                          .hashCode,

                                      title:
                                      updatedEvent.title,

                                      body: updatedEvent
                                          .description ??
                                          'Calendar event reminder',

                                      scheduledDate:
                                      updatedEvent.date,
                                    );
                                  }

                                  await loadEvents();
                                },
                              ),

                              // --------------------------------------------------
                              // DELETE
                              // --------------------------------------------------
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),

                                onPressed: () async {
                                  final bool? confirmed =
                                  await showDialog<bool>(
                                    context: context,

                                    builder: (context) {
                                      final bool isDarkMode =
                                          Theme.of(context)
                                              .brightness ==
                                              Brightness.dark;

                                      return AlertDialog(
                                        backgroundColor:
                                        isDarkMode
                                            ? const Color(
                                            0xFF1E231B)
                                            : Colors.white,

                                        title: Text(
                                          'Delete Event?',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        content: Text(
                                          'Are you sure you want to delete '
                                              '"${event.title}"?',

                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),

                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                                false,
                                              );
                                            },

                                            child: const Text(
                                              'Cancel',
                                            ),
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                                true,
                                              );
                                            },

                                            child: const Text(
                                              'Delete',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed != true) {
                                    return;
                                  }

                                  await NotificationService
                                      .cancelNotification(
                                    event.id.hashCode,
                                  );

                                  await databaseHelper
                                      .deleteCalendarEvent(
                                    event.id,
                                  );

                                  await loadEvents();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      // --------------------------------------------------
      // ADD EVENT BUTTON
      // --------------------------------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: olive,
        foregroundColor: Colors.white,

        onPressed: () async {
          final CalendarEvent? event =
          await Navigator.push<CalendarEvent>(
            context,

            MaterialPageRoute(
              builder: (context) =>
              const AddCalendarEventScreen(),
            ),
          );

          if (event == null) {
            return;
          }

          await databaseHelper.insertCalendarEvent(
            event,
          );

          if (event.reminder) {
            await NotificationService.scheduleNotification(
              id: event.id.hashCode,

              title: event.title,

              body: event.description ??
                  'Calendar event reminder',

              scheduledDate: event.date,
            );
          }

          await loadEvents();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}