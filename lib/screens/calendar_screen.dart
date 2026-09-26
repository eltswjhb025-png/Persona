import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/calendar_event.dart';
import '../models/person.dart';
import '../services/birthday_service.dart';
import '../services/notification_service.dart';
import 'add_calendar_event_screen.dart';

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

  @override
  void initState() {
    super.initState();
    loadEvents();
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

  @override
  Widget build(BuildContext context) {
    const Color olive = Color.fromRGBO(128, 128, 0, 1);
    const Color oliveDrab = Color.fromRGBO(107, 142, 35, 1);

    return Scaffold(
      backgroundColor: oliveDrab,

      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: olive,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        // CHANGED:
        // Column -> ListView
        child: ListView(
          children: [
            // Calendar
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: SizedBox(
                height: 350,

                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(
                    DateTime.now().year + 10,
                    12,
                    31,
                  ),

                  onDateChanged: (DateTime date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selected date
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

            // Events heading
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

            // CHANGED:
            // Expanded -> Builder
            Builder(
              builder: (context) {
                final List<CalendarEvent> selectedEvents =
                getEventsForSelectedDate();

                final List<Person> selectedBirthdays =
                getBirthdaysForSelectedDate();

                if (selectedEvents.isEmpty &&
                    selectedBirthdays.isEmpty) {
                  return Center(
                    child: Card(
                      color: olive,
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

                // CHANGED:
                // ListView -> Column
                return Column(
                  children: [
                    // Birthdays
                    ...selectedBirthdays.map((Person person) {
                      return Card(
                        color: olive,
                        elevation: 4,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

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
                              fontWeight: FontWeight.bold,
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

                    // Calendar events
                    ...selectedEvents.map((CalendarEvent event) {
                      return Card(
                        color: olive,
                        elevation: 4,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          leading: CircleAvatar(
                            backgroundColor: Colors.white,

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
                              fontWeight: FontWeight.bold,
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
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              if (event.reminder)
                                const Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                ),

                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),

                                onPressed: () async {
                                  final CalendarEvent? updatedEvent =
                                  await Navigator.push<CalendarEvent>(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddCalendarEventScreen(
                                            event: event,
                                          ),
                                    ),
                                  );

                                  if (updatedEvent == null) {
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
                                      id: updatedEvent.id.hashCode,
                                      title: updatedEvent.title,
                                      body: updatedEvent.description ??
                                          'Calendar event reminder',
                                      scheduledDate: updatedEvent.date,
                                    );
                                  }

                                  await loadEvents();
                                },
                              ),

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
                                      return AlertDialog(
                                        title: const Text(
                                          'Delete Event?',
                                        ),

                                        content: Text(
                                          'Are you sure you want to delete '
                                              '"${event.title}"?',
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

      // Add event button
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

          await databaseHelper.insertCalendarEvent(event);

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