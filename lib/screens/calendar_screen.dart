import 'dart:ui';

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

  // ============================================================
  // PERSONA COLOURS
  // ============================================================

  static const Color olive = Color(0xFF808000);
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  // ============================================================
  // LOAD LOCAL EVENTS
  // ============================================================

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

  // ============================================================
  // LOAD GOOGLE HOLIDAYS
  // ============================================================

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

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadEvents();
    loadGoogleHolidays();
  }

  // ============================================================
  // GET EVENTS FOR SELECTED DATE
  // ============================================================

  List<CalendarEvent> getEventsForSelectedDate() {
    return events.where((CalendarEvent event) {
      return event.date.year == selectedDate.year &&
          event.date.month == selectedDate.month &&
          event.date.day == selectedDate.day;
    }).toList();
  }

  // ============================================================
  // GET BIRTHDAYS FOR SELECTED DATE
  // ============================================================

  List<Person> getBirthdaysForSelectedDate() {
    return people.where((Person person) {
      return person.birthday.month == selectedDate.month &&
          person.birthday.day == selectedDate.day;
    }).toList();
  }

  // ============================================================
  // GET HOLIDAYS FOR SELECTED DATE
  // ============================================================

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

  // ============================================================
  // CHECK FOR CALENDAR EVENT
  // ============================================================

  bool hasCalendarEvent(DateTime day) {
    return events.any((CalendarEvent event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    });
  }

  // ============================================================
  // CHECK FOR BIRTHDAY
  // ============================================================

  bool hasBirthday(DateTime day) {
    return people.any((Person person) {
      return person.birthday.month == day.month &&
          person.birthday.day == day.day;
    });
  }

  // ============================================================
  // CHECK FOR HOLIDAY
  // ============================================================

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

  // ============================================================
  // GLASS CARD
  // ============================================================

  Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 22,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // EVENT CARD
  // ============================================================

  Widget buildEventCard({
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return glassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final Color calendarBackground = isDarkMode
        ? const Color(0xFF1E231B)
        : Colors.white;

    final Color calendarTextColor =
    isDarkMode ? Colors.white : darkOlive;

    final Color calendarOutsideTextColor =
    isDarkMode ? Colors.white38 : darkOlive.withValues(alpha: 0.35);

    return Scaffold(
      backgroundColor: oliveDrab,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'Calendar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              oliveDrab,
              olive,
              darkOlive,
            ],
          ),
        ),

        child: SafeArea(
          top: false,

          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              100,
            ),

            children: [
              // ==================================================
              // CALENDAR GLASS CARD
              // ==================================================

              glassCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                borderRadius: 26,

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

                    // ==================================================
                    // CALENDAR HEADER
                    // ==================================================

                    headerStyle: HeaderStyle(
                      titleCentered: true,

                      titleTextStyle: TextStyle(
                        color: calendarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: calendarTextColor,
                      ),

                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: calendarTextColor,
                      ),

                      formatButtonVisible: false,
                    ),

                    // ==================================================
                    // DAYS OF WEEK
                    // ==================================================

                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: calendarTextColor.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                      ),

                      weekendStyle: TextStyle(
                        color: calendarTextColor.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // ==================================================
                    // CALENDAR STYLE
                    // ==================================================

                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: oliveDrab,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),

                      selectedDecoration: const BoxDecoration(
                        color: darkOlive,
                        shape: BoxShape.circle,
                      ),

                      defaultTextStyle: TextStyle(
                        color: calendarTextColor,
                        fontWeight: FontWeight.w500,
                      ),

                      weekendTextStyle: TextStyle(
                        color: calendarTextColor,
                        fontWeight: FontWeight.w500,
                      ),

                      outsideTextStyle: TextStyle(
                        color: calendarOutsideTextColor,
                      ),

                      disabledTextStyle: TextStyle(
                        color: calendarOutsideTextColor,
                      ),

                      markerDecoration: const BoxDecoration(
                        color: olive,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // ==================================================
                    // EVENT INDICATORS
                    // ==================================================

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
                          backgroundColor = Colors.red.shade400;
                        } else if (birthday) {
                          backgroundColor = Colors.pink.shade300;
                        } else {
                          backgroundColor = oliveDrab;
                        }

                        return Container(
                          margin: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: backgroundColor
                                    .withValues(alpha: 0.35),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
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

              // ==================================================
              // SELECTED DATE
              // ==================================================

              glassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: 22,

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.today_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '${selectedDate.day}/'
                              '${selectedDate.month}/'
                              '${selectedDate.year}',

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // EVENTS HEADING
              // ==================================================

              const Text(
                'Events & Birthdays',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Everything happening on this date',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // EVENT LIST
              // ==================================================

              Builder(
                builder: (context) {
                  final List<CalendarEvent> selectedEvents =
                  getEventsForSelectedDate();

                  final List<Person> selectedBirthdays =
                  getBirthdaysForSelectedDate();

                  final List<calendar.Event> selectedHolidays =
                  getGoogleHolidaysForSelectedDate();

                  // ==================================================
                  // NO EVENTS
                  // ==================================================

                  if (selectedEvents.isEmpty &&
                      selectedBirthdays.isEmpty &&
                      selectedHolidays.isEmpty) {
                    return glassCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      borderRadius: 22,

                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.event_available,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'No events for this date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Your calendar is clear.',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // ==================================================
                      // GOOGLE HOLIDAYS
                      // ==================================================

                      ...selectedHolidays.map(
                            (calendar.Event holiday) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),

                            child: buildEventCard(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.white,

                                child: Icon(
                                  Icons.flag_outlined,
                                  color: darkOlive,
                                ),
                              ),

                              title: holiday.summary ??
                                  'South African Holiday',

                              subtitle:
                              'South African Holiday',
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // BIRTHDAYS
                      // ==================================================

                      ...selectedBirthdays.map(
                            (Person person) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),

                            child: buildEventCard(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.white,

                                child: Icon(
                                  Icons.cake_outlined,
                                  color: darkOlive,
                                ),
                              ),

                              title:
                              '${person.name}\'s Birthday',

                              subtitle: 'Birthday',
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // CALENDAR EVENTS
                      // ==================================================

                      ...selectedEvents.map(
                            (CalendarEvent event) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),

                            child: buildEventCard(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,

                                child: Icon(
                                  event.reminder
                                      ? Icons.notifications_outlined
                                      : Icons.event_outlined,

                                  color: darkOlive,
                                ),
                              ),

                              title: event.title,

                              subtitle:
                              '${event.date.hour.toString().padLeft(2, '0')}:'
                                  '${event.date.minute.toString().padLeft(2, '0')}'
                                  '${event.description != null ? '\n${event.description}' : ''}',

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  if (event.reminder)
                                    const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),

                                  // ======================================
                                  // EDIT
                                  // ======================================

                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
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

                                  // ======================================
                                  // DELETE
                                  // ======================================

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),

                                    onPressed: () async {
                                      final bool? confirmed =
                                      await showDialog<bool>(
                                        context: context,

                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor:
                                            lightCream,

                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                22,
                                              ),
                                            ),

                                            title: const Text(
                                              'Delete Event?',
                                              style: TextStyle(
                                                color: darkOlive,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),

                                            content: Text(
                                              'Are you sure you want '
                                                  'to delete '
                                                  '"${event.title}"?',

                                              style: const TextStyle(
                                                color: darkOlive,
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
                                                  style: TextStyle(
                                                    color: darkOlive,
                                                  ),
                                                ),
                                              ),

                                              ElevatedButton(
                                                style:
                                                ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  olive,

                                                  foregroundColor:
                                                  Colors.white,

                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                      12,
                                                    ),
                                                  ),
                                                ),

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
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // ADD EVENT BUTTON
      // ============================================================

      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: darkOlive.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),

        child: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: darkOlive,

          elevation: 4,

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

          child: const Icon(
            Icons.add,
            size: 28,
          ),
        ),
      ),
    );
  }
}