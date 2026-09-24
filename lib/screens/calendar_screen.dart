import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/calendar_event.dart';
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

  Future<void> loadEvents() async {
    final List<CalendarEvent> savedEvents =
    await databaseHelper.getCalendarEvents();

    if (!mounted) {
      return;
    }

    setState(() {
      events = savedEvents;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            onDateChanged: (DateTime date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),

          const Divider(),

          Text(
            'Selected Date: '
                '${selectedDate.day}/'
                '${selectedDate.month}/'
                '${selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Builder(
              builder: (context) {
                final List<CalendarEvent> selectedEvents =
                getEventsForSelectedDate();

                if (selectedEvents.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events for this date',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final CalendarEvent event = selectedEvents[index];

                    return ListTile(
                      leading: const Icon(Icons.event),

                      title: Text(event.title),

                      subtitle: Text(
                        '${event.date.hour.toString().padLeft(2, '0')}:'
                            '${event.date.minute.toString().padLeft(2, '0')}'
                            '${event.description != null ? '\n${event.description}' : ''}',
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (event.reminder)
                            const Icon(Icons.notifications),

                          IconButton(
                            icon: const Icon(Icons.edit),
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

                              await NotificationService.cancelNotification(
                                event.id.hashCode,
                              );

                              await databaseHelper.updateCalendarEvent(
                                updatedEvent,
                              );

                              if (updatedEvent.reminder) {
                                await NotificationService.scheduleNotification(
                                  id: updatedEvent.id.hashCode,
                                  title: updatedEvent.title,
                                  body: updatedEvent.description ?? 'Calendar event reminder',
                                  scheduledDate: updatedEvent.date,
                                );
                              }

                              await loadEvents();
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final bool? confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Event?'),
                                    content: Text(
                                      'Are you sure you want to delete '
                                          '"${event.title}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('Cancel'),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != true) {
                                return;
                              }

                              await NotificationService.cancelNotification(
                                event.id.hashCode,
                              );

                              await databaseHelper.deleteCalendarEvent(
                                event.id,
                              );

                              await loadEvents();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
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
              body: event.description ?? 'Calendar event reminder',
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