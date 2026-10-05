import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../database/database_helper.dart';
import '../models/person.dart';
import '../models/calendar_event.dart';
import '../services/google_calendar_service.dart';
import '../services/theme_service.dart';

import 'sos_screen.dart';
import 'birthdays_screen.dart';
import 'calendar_screen.dart';
import 'locator_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool loadData;

  const HomeScreen({
    super.key,
    this.loadData = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);
  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  final DatabaseHelper databaseHelper = DatabaseHelper();

  String _profileName = 'Persona User';

  bool isLoadingUpcoming = true;

  List<UpcomingEvent> upcomingEvents = [];

  final PageController _upcomingPageController =
  PageController();

  int _currentUpcomingPage = 0;

  @override
  void initState() {
    super.initState();

    if (widget.loadData) {
      loadProfileName();
      loadUpcomingEvent();
    } else {
      isLoadingUpcoming = false;
    }
  }

  @override
  void dispose() {
    _upcomingPageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // PROFILE NAME
  // ==========================================================

  Future<void> loadProfileName() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    final String name =
        user?.displayName?.trim() ?? '';

    if (!mounted) return;

    setState(() {
      _profileName =
      name.isNotEmpty ? name : 'Persona User';
    });
  }

  // ==========================================================
  // UPCOMING EVENTS
  // ==========================================================

  Future<void> loadUpcomingEvent() async {
    if (mounted) {
      setState(() {
        isLoadingUpcoming = true;
      });
    }

    try {
      final DateTime now = DateTime.now();

      final DateTime today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final DateTime threeDaysFromNow =
      today.add(
        const Duration(days: 3),
      );

      final DateTime endDate = DateTime(
        threeDaysFromNow.year,
        threeDaysFromNow.month,
        threeDaysFromNow.day,
        23,
        59,
        59,
      );

      final List<UpcomingEvent> possibleEvents =
      [];

      // ========================================================
      // BIRTHDAYS
      // ========================================================

      final List<Person> people =
      await databaseHelper.getPeople();

      for (final Person person in people) {
        final UpcomingEvent? birthday =
        _getNextBirthday(
          person,
          today,
          threeDaysFromNow,
        );

        if (birthday != null) {
          possibleEvents.add(birthday);
        }
      }

      // ========================================================
      // LOCAL CALENDAR EVENTS
      // ========================================================

      final List<CalendarEvent> localEvents =
      await databaseHelper.getCalendarEvents();

      for (final CalendarEvent event in localEvents) {
        final DateTime eventDate = event.date;

        if (eventDate.isBefore(now) ||
            eventDate.isAfter(endDate)) {
          continue;
        }

        possibleEvents.add(
          UpcomingEvent(
            title: event.title,
            date: eventDate,
            icon: Icons.calendar_month_outlined,
            isBirthday: false,
          ),
        );
      }

      // ========================================================
      // GOOGLE CALENDAR EVENTS
      // ========================================================

      try {
        final List<calendar.Event> googleEvents =
        await GoogleCalendarService
            .getUpcomingEvents(
          startDate: today,
          endDate: endDate,
        );

        for (final calendar.Event event
        in googleEvents) {
          final DateTime? eventDate =
          _getGoogleEventDate(event);

          if (eventDate == null) {
            continue;
          }

          if (event.start?.date != null) {
            final DateTime eventDay =
            DateTime(
              eventDate.year,
              eventDate.month,
              eventDate.day,
            );

            if (eventDay.isBefore(today) ||
                eventDay.isAfter(
                  threeDaysFromNow,
                )) {
              continue;
            }
          } else {
            if (eventDate.isBefore(now) ||
                eventDate.isAfter(endDate)) {
              continue;
            }
          }

          possibleEvents.add(
            UpcomingEvent(
              title:
              event.summary ??
                  'Calendar Event',
              date: eventDate,
              icon:
              Icons.calendar_month_outlined,
              isBirthday: false,
            ),
          );
        }
      } catch (e) {
        debugPrint(
          'GOOGLE CALENDAR ERROR: $e',
        );
      }

      // ========================================================
      // SORT EVENTS
      // ========================================================

      possibleEvents.sort(
            (UpcomingEvent a, UpcomingEvent b) =>
            a.date.compareTo(b.date),
      );

      if (!mounted) return;

      setState(() {
        upcomingEvents = possibleEvents;

        isLoadingUpcoming = false;

        if (upcomingEvents.isEmpty) {
          _currentUpcomingPage = 0;
        } else if (_currentUpcomingPage >=
            upcomingEvents.length) {
          _currentUpcomingPage =
              upcomingEvents.length - 1;
        }
      });
    } catch (e) {
      debugPrint(
        'HOME UPCOMING EVENT ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        upcomingEvents = [];
        isLoadingUpcoming = false;
        _currentUpcomingPage = 0;
      });
    }
  }

  // ==========================================================
  // NEXT BIRTHDAY
  // ==========================================================

  UpcomingEvent? _getNextBirthday(
      Person person,
      DateTime today,
      DateTime threeDaysFromNow,
      ) {
    DateTime birthdayThisYear;

    try {
      birthdayThisYear = DateTime(
        today.year,
        person.birthday.month,
        person.birthday.day,
      );
    } catch (_) {
      return null;
    }

    if (birthdayThisYear.isBefore(today)) {
      birthdayThisYear = DateTime(
        today.year + 1,
        person.birthday.month,
        person.birthday.day,
      );
    }

    if (birthdayThisYear.isAfter(
      threeDaysFromNow,
    )) {
      return null;
    }

    return UpcomingEvent(
      title:
      "${person.name}'s Birthday",
      date: birthdayThisYear,
      icon: Icons.cake_outlined,
      isBirthday: true,
    );
  }

  // ==========================================================
  // GOOGLE EVENT DATE
  // ==========================================================

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

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
      isDarkMode
          ? darkBackground
          : lightCream,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
            isDarkMode
                ? const [
              darkOlive,
              darkCard,
              darkBackground,
            ]
                : const [
              olive,
              oliveDrab,
              Color(0xFF556B2F),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await loadProfileName();
              await loadUpcomingEvent();
            },
            color: oliveDrab,
            child: SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(
                parent:
                AlwaysScrollableScrollPhysics(),
              ),
              padding:
              const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),

                  const SizedBox(
                    height: 25,
                  ),

                  _buildUpcomingEvent(
                    isDarkMode,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildEventIndicators(),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildAnimeGif(),

                  const SizedBox(
                    height: 28,
                  ),

                  _buildSectionTitle(
                    title: 'Your Persona',
                    subtitle:
                    'Stay connected to what matters.',
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  _buildFeatureCard(
                    context,
                    isDarkMode:
                    isDarkMode,
                    icon:
                    Icons.cake_outlined,
                    title: 'Birthdays',
                    subtitle:
                    'Never miss an important birthday',
                    iconColor: oliveDrab,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                          const BirthdaysScreen(),
                        ),
                      );

                      if (mounted) {
                        await loadUpcomingEvent();
                      }
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildFeatureCard(
                    context,
                    isDarkMode:
                    isDarkMode,
                    icon:
                    Icons.calendar_month_outlined,
                    title: 'Calendar',
                    subtitle:
                    'Keep track of your important events',
                    iconColor: olive,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                          const CalendarScreen(),
                        ),
                      );

                      if (mounted) {
                        await loadUpcomingEvent();
                      }
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildFeatureCard(
                    context,
                    isDarkMode:
                    isDarkMode,
                    icon:
                    Icons.location_on_outlined,
                    title: 'Locator',
                    subtitle:
                    'Find and share your location',
                    iconColor: darkOlive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                          const LocatorScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildFeatureCard(
                    context,
                    isDarkMode:
                    isDarkMode,
                    icon:
                    Icons.sos_outlined,
                    title: 'SOS',
                    subtitle:
                    'Emergency assistance when you need it',
                    iconColor:
                    const Color(
                      0xFFB94A48,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                          const SOSScreen(),
                        ),
                      );
                    },
                    isEmergency: true,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  _buildBottomBranding(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // APP BAR
  // ==========================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 6,
        ),
        child: _buildPersonaLogo(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 20,
            top: 6,
          ),
          child: _buildGlassIconButton(
            icon:
            Icons.settings_outlined,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const SettingsScreen(),
                ),
              );

              if (mounted) {
                await loadProfileName();
                await loadUpcomingEvent();
              }
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PERSONA LOGO
  // ==========================================================

  Widget _buildPersonaLogo() {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(
          alpha: 0.15,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color:
          Colors.white.withValues(
            alpha: 0.25,
          ),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.spa_outlined,
        color: Colors.white,
        size: 23,
      ),
    );
  }

  // ==========================================================
  // WELCOME SECTION
  // ==========================================================

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $_profileName 👋',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

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

        const SizedBox(
          height: 12,
        ),

        Text(
          'Birthdays, events, location and emergency support.',
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.78,
            ),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // UPCOMING EVENT CARD
  // ==========================================================

  Widget _buildUpcomingEvent(
      bool isDarkMode,
      ) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20,
          ),
          decoration: BoxDecoration(
            color:
            isDarkMode
                ? Colors.black.withValues(
              alpha: 0.22,
            )
                : Colors.white.withValues(
              alpha: 0.16,
            ),
            borderRadius:
            BorderRadius.circular(26),
            border: Border.all(
              color:
              Colors.white.withValues(
                alpha:
                isDarkMode
                    ? 0.18
                    : 0.25,
              ),
              width: 1,
            ),
          ),
          child:
          isLoadingUpcoming
              ? const SizedBox(
            height: 135,
            child: Center(
              child:
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
              : upcomingEvents.isEmpty
              ? _buildNoUpcomingEvent()
              : _buildUpcomingEventCarousel(),
        ),
      ),
    );
  }

  // ==========================================================
  // UPCOMING EVENT CAROUSEL
  // ==========================================================

  Widget _buildUpcomingEventCarousel() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING EVENT',
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.68,
            ),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        SizedBox(
          height: 215,
          child: PageView.builder(
            controller:
            _upcomingPageController,
            itemCount:
            upcomingEvents.length,
            onPageChanged:
                (int index) {
              if (!mounted) return;

              setState(() {
                _currentUpcomingPage =
                    index;
              });
            },
            itemBuilder:
                (
                BuildContext context,
                int index,
                ) {
              return _buildUpcomingEventTile(
                upcomingEvents[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // UPCOMING EVENT TILE
  // ==========================================================

  Widget _buildUpcomingEventTile(
      UpcomingEvent event,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        right: 4,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  event.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  softWrap: true,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.2,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                height: 31,
                width: 31,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  _formatDate(
                    event.date,
                  ),
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    color:
                    Colors.white
                        .withValues(
                      alpha: 0.88,
                    ),
                    fontSize: 14,
                    height: 1.3,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          if (!event.isBirthday &&
              _hasTime(event.date)) ...[
            const SizedBox(
              height: 9,
            ),

            Row(
              children: [
                Container(
                  height: 31,
                  width: 31,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white
                        .withValues(
                      alpha: 0.16,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child:
                  const Icon(
                    Icons
                        .access_time_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    _formatTime(
                      event.date,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      Colors.white
                          .withValues(
                        alpha: 0.88,
                      ),
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // ANIME GIF
  // ==========================================================

  Widget _buildAnimeGif() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(26),
          border: Border.all(
            color:
            Colors.white.withValues(
              alpha: 0.20,
            ),
            width: 1,
          ),
        ),
        child: Image.asset(
          'images/persona_anime_butterflies.png',
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  // ==========================================================
  // NO UPCOMING EVENT
  // ==========================================================

  Widget _buildNoUpcomingEvent() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING EVENT',
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.68,
            ),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        const Row(
          children: [
            Icon(
              Icons
                  .event_available_outlined,
              color: Colors.white,
              size: 30,
            ),

            SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                'Nothing coming up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          'Your upcoming birthdays and calendar '
              'events will appear here.',
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.75,
            ),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(
      DateTime date,
      ) {
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

  // ==========================================================
  // TIME FORMAT
  // ==========================================================

  String _formatTime(
      DateTime date,
      ) {
    final int hour =
    date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final String minute =
    date.minute
        .toString()
        .padLeft(2, '0');

    final String period =
    date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ==========================================================
  // HAS TIME
  // ==========================================================

  bool _hasTime(
      DateTime date,
      ) {
    return date.hour != 0 ||
        date.minute != 0 ||
        date.second != 0;
  }

  // ==========================================================
  // EVENT INDICATORS
  // ==========================================================

  Widget _buildEventIndicators() {
    if (upcomingEvents.length <= 1) {
      return const SizedBox(
        height: 7,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: List.generate(
          upcomingEvents.length,
              (int index) {
            return Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 3.5,
              ),
              child: _buildIndicator(
                active:
                index ==
                    _currentUpcomingPage,
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // INDICATOR
  // ==========================================================

  Widget _buildIndicator({
    required bool active,
  }) {
    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 250,
      ),
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
        active
            ? Colors.white
            : Colors.white.withValues(
          alpha: 0.35,
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

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
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          subtitle,
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.70,
            ),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FEATURE CARD
  // ==========================================================

  Widget _buildFeatureCard(
      BuildContext context, {
        required bool isDarkMode,
        required IconData icon,
        required String title,
        required String subtitle,
        required Color iconColor,
        required VoidCallback onTap,
        bool isEmergency = false,
      }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color:
          isEmergency
              ? const Color(
            0xFF8F3535,
          ).withValues(
            alpha: 0.35,
          )
              : isDarkMode
              ? Colors.black.withValues(
            alpha: 0.20,
          )
              : Colors.white.withValues(
            alpha: 0.15,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius:
            BorderRadius.circular(25),
            child: Container(
              padding:
              const EdgeInsets.all(17),
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(25),
                border: Border.all(
                  color:
                  Colors.white.withValues(
                    alpha:
                    isDarkMode
                        ? 0.18
                        : 0.22,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration:
                    BoxDecoration(
                      color:
                      isEmergency
                          ? const Color(
                        0xFFB94A48,
                      ).withValues(
                        alpha: 0.85,
                      )
                          : Colors.white
                          .withValues(
                        alpha: 0.90,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color:
                      isEmergency
                          ? Colors.white
                          : iconColor,
                      size: 29,
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          title,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          subtitle,
                          style: TextStyle(
                            color:
                            Colors.white
                                .withValues(
                              alpha: 0.70,
                            ),
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Container(
                    height: 36,
                    width: 36,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white
                          .withValues(
                        alpha: 0.12,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child:
                    const Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      color:
                      Colors.white,
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

  // ==========================================================
  // GLASS SETTINGS BUTTON
  // ==========================================================

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
          color:
          Colors.white.withValues(
            alpha: 0.15,
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 44,
              width: 44,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                border: Border.all(
                  color:
                  Colors.white
                      .withValues(
                    alpha: 0.25,
                  ),
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

  // ==========================================================
  // BOTTOM BRANDING
  // ==========================================================

  Widget _buildBottomBranding() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
            BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.12,
              ),
              shape:
              BoxShape.circle,
              border: Border.all(
                color:
                Colors.white.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.spa_outlined,
              color:
              Colors.white70,
              size: 23,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            'PERSONA',
            style: TextStyle(
              color:
              Colors.white.withValues(
                alpha: 0.55,
              ),
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
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