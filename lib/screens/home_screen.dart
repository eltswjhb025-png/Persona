import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../database/database_helper.dart';
import '../models/person.dart';
import '../services/google_calendar_service.dart';

import 'sos_screen.dart';
import 'birthdays_screen.dart';
import 'calendar_screen.dart';
import 'locator_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  // ============================================================
  // Database
  // ============================================================

  final DatabaseHelper databaseHelper = DatabaseHelper();

  // ============================================================
  // Upcoming Event State
  // ============================================================

  bool isLoadingUpcoming = true;

  UpcomingEvent? upcomingEvent;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadUpcomingEvent();
  }

  // ============================================================
  // LOAD UPCOMING EVENT
  // ============================================================

  Future<void> loadUpcomingEvent() async {
    try {
      final DateTime now = DateTime.now();

      // ----------------------------------------------------------
      // Load Persona birthdays
      // ----------------------------------------------------------

      final List<Person> people =
      await databaseHelper.getPeople();

      final List<UpcomingEvent> possibleEvents = [];

      for (final Person person in people) {
        final UpcomingEvent? birthday =
        _getNextBirthday(person, now);

        if (birthday != null) {
          possibleEvents.add(birthday);
        }
      }

      // ----------------------------------------------------------
      // Load Google Calendar events
      // ----------------------------------------------------------

      final DateTime calendarEnd =
      now.add(const Duration(days: 365));

      final List<calendar.Event> googleEvents =
      await GoogleCalendarService.getUpcomingEvents(
        startDate: now,
        endDate: calendarEnd,
      );

      for (final calendar.Event event in googleEvents) {
        final DateTime? eventDate =
        _getGoogleEventDate(event);

        if (eventDate == null) {
          continue;
        }

        if (eventDate.isBefore(now)) {
          continue;
        }

        possibleEvents.add(
          UpcomingEvent(
            title: event.summary ?? 'Calendar Event',
            date: eventDate,
            icon: Icons.calendar_month_outlined,
            isBirthday: false,
          ),
        );
      }

      // ----------------------------------------------------------
      // Find nearest event
      // ----------------------------------------------------------

      possibleEvents.sort(
            (UpcomingEvent a, UpcomingEvent b) =>
            a.date.compareTo(b.date),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        upcomingEvent =
        possibleEvents.isEmpty ? null : possibleEvents.first;

        isLoadingUpcoming = false;
      });
    } catch (e) {
      debugPrint(
        'HOME UPCOMING EVENT ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        upcomingEvent = null;
        isLoadingUpcoming = false;
      });
    }
  }

  // ============================================================
  // NEXT BIRTHDAY
  // ============================================================

  UpcomingEvent? _getNextBirthday(
      Person person,
      DateTime now,
      ) {
    DateTime birthdayThisYear;

    try {
      birthdayThisYear = DateTime(
        now.year,
        person.birthday.month,
        person.birthday.day,
      );
    } catch (_) {
      return null;
    }

    DateTime nextBirthday = birthdayThisYear;

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(
        now.year + 1,
        person.birthday.month,
        person.birthday.day,
      );
    }

    return UpcomingEvent(
      title: "${person.name}'s Birthday",
      date: nextBirthday,
      icon: Icons.cake_outlined,
      isBirthday: true,
    );
  }

  // ============================================================
  // GOOGLE EVENT DATE
  // ============================================================

  DateTime? _getGoogleEventDate(
      calendar.Event event,
      ) {
    final calendar.EventDateTime? start =
        event.start;

    if (start == null) {
      return null;
    }

    if (start.dateTime != null) {
      return start.dateTime!.toLocal();
    }

    if (start.date != null) {
      return DateTime(
        start.date!.year,
        start.date!.month,
        start.date!.day,
      );
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
      isDarkMode ? const Color(0xFF202414) : lightCream,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? const [
              Color(0xFF252B17),
              Color(0xFF3F4A16),
              Color(0xFF202414),
            ]
                : const [
              Color(0xFF808000),
              Color(0xFF6B8E23),
              Color(0xFF556B2F),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadUpcomingEvent,
            color: oliveDrab,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // --------------------------------------------------
                  // WELCOME
                  // --------------------------------------------------

                  _buildWelcomeSection(),

                  const SizedBox(height: 25),

                  // --------------------------------------------------
                  // UPCOMING EVENT
                  // --------------------------------------------------

                  _buildUpcomingEvent(),

                  const SizedBox(height: 10),

                  // --------------------------------------------------
                  // EVENT INDICATORS
                  // --------------------------------------------------

                  _buildEventIndicators(),

                  const SizedBox(height: 28),

                  // --------------------------------------------------
                  // YOUR PERSONA
                  // --------------------------------------------------

                  _buildSectionTitle(
                    title: 'Your Persona',
                    subtitle:
                    'Stay connected to what matters.',
                  ),

                  const SizedBox(height: 15),

                  // --------------------------------------------------
                  // BIRTHDAYS
                  // --------------------------------------------------

                  _buildFeatureCard(
                    context,
                    icon: Icons.cake_outlined,
                    title: 'Birthdays',
                    subtitle:
                    'Never miss an important birthday',
                    iconColor: oliveDrab,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const BirthdaysScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // --------------------------------------------------
                  // CALENDAR
                  // --------------------------------------------------

                  _buildFeatureCard(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'Calendar',
                    subtitle:
                    'Keep track of your important events',
                    iconColor: olive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CalendarScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // --------------------------------------------------
                  // LOCATOR
                  // --------------------------------------------------

                  _buildFeatureCard(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Locator',
                    subtitle:
                    'Find and share your location',
                    iconColor: darkOlive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const LocatorScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // --------------------------------------------------
                  // SOS
                  // --------------------------------------------------

                  _buildFeatureCard(
                    context,
                    icon: Icons.sos_outlined,
                    title: 'SOS',
                    subtitle:
                    'Emergency assistance when you need it',
                    iconColor:
                    const Color(0xFFB94A48),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const SOSScreen(),
                        ),
                      );
                    },
                    isEmergency: true,
                  ),

                  const SizedBox(height: 28),

                  // --------------------------------------------------
                  // BRANDING
                  // --------------------------------------------------

                  _buildBottomBranding(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
              ),
            ),
            child: const Icon(
              Icons.spa_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Persona',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _buildGlassIconButton(
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const SettingsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME SECTION
  // ============================================================

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back 👋',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Your world,\nall in one place.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Birthdays, events, location and emergency support.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UPCOMING EVENT
  // ============================================================

  Widget _buildUpcomingEvent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: isLoadingUpcoming
              ? const SizedBox(
            height: 135,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
              : upcomingEvent == null
              ? _buildNoUpcomingEvent()
              : _buildUpcomingEventContent(),
        ),
      ),
    );
  }

  // ============================================================
  // UPCOMING EVENT CONTENT
  // ============================================================

  Widget _buildUpcomingEventContent() {
    final UpcomingEvent event =
    upcomingEvent!;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING EVENT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.16),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                event.icon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // --------------------------------------------------------
        // DATE
        // --------------------------------------------------------

        Row(
          children: [
            Container(
              height: 31,
              width: 31,
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.16),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _formatDate(event.date),
                style: TextStyle(
                  color:
                  Colors.white.withOpacity(0.88),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // --------------------------------------------------------
        // TIME
        // --------------------------------------------------------

        if (!event.isBirthday &&
            _hasTime(event.date)) ...[
          const SizedBox(height: 9),

          Row(
            children: [
              Container(
                height: 31,
                width: 31,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(0.16),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                _formatTime(event.date),
                style: TextStyle(
                  color:
                  Colors.white.withOpacity(0.88),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================
  // NO UPCOMING EVENT
  // ============================================================

  Widget _buildNoUpcomingEvent() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING EVENT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),

        const SizedBox(height: 16),

        const Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: Colors.white,
              size: 30,
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Nothing coming up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Your upcoming birthdays and calendar events '
              'will appear here.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  String _formatDate(DateTime date) {
    const List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final int hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final String minute =
    date.minute.toString().padLeft(2, '0');

    final String period =
    date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  bool _hasTime(DateTime date) {
    return date.hour != 0 ||
        date.minute != 0 ||
        date.second != 0;
  }

  // ============================================================
  // EVENT INDICATORS
  // ============================================================

  Widget _buildEventIndicators() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          _buildIndicator(active: true),
          const SizedBox(width: 7),
          _buildIndicator(active: false),
          const SizedBox(width: 7),
          _buildIndicator(active: false),
          const SizedBox(width: 7),
          _buildIndicator(active: false),
        ],
      ),
    );
  }

  // ============================================================
  // INDICATOR
  // ============================================================

  Widget _buildIndicator({
    required bool active,
  }) {
    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 250),
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Colors.white
            : Colors.white.withOpacity(0.35),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.70),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEATURE CARD
  // ============================================================

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color iconColor,
        required VoidCallback onTap,
        bool isEmergency = false,
      }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color: isEmergency
              ? const Color(0xFF8F3535)
              .withOpacity(0.35)
              : Colors.white.withOpacity(0.15),
          child: InkWell(
            onTap: onTap,
            borderRadius:
            BorderRadius.circular(25),
            child: Container(
              padding:
              const EdgeInsets.all(17),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(25),
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.22),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // ------------------------------------------
                  // ICON
                  // ------------------------------------------

                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: isEmergency
                          ? const Color(0xFFB94A48)
                          .withOpacity(0.85)
                          : Colors.white
                          .withOpacity(0.90),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: isEmergency
                          ? Colors.white
                          : iconColor,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ------------------------------------------
                  // TEXT
                  // ------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.70),
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ------------------------------------------
                  // ARROW
                  // ------------------------------------------

                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GLASS SETTINGS BUTTON
  // ============================================================

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Material(
          color: Colors.white.withOpacity(0.15),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.25),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BRANDING
  // ============================================================

  Widget _buildBottomBranding() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                Colors.white.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.spa_outlined,
              color: Colors.white70,
              size: 23,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'PERSONA',
            style: TextStyle(
              color:
              Colors.white.withOpacity(0.55),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UPCOMING EVENT MODEL
// ============================================================

class UpcomingEvent {
  final String title;
  final DateTime date;
  final IconData icon;
  final bool isBirthday;

  UpcomingEvent({
    required this.title,
    required this.date,
    required this.icon,
    required this.isBirthday,
  });
}