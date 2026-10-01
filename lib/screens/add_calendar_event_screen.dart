import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/theme_service.dart';

class AddCalendarEventScreen extends StatefulWidget {
  final CalendarEvent? event;

  const AddCalendarEventScreen({
    super.key,
    this.event,
  });

  @override
  State<AddCalendarEventScreen> createState() =>
      _AddCalendarEventScreenState();
}

class _AddCalendarEventScreenState
    extends State<AddCalendarEventScreen> {
  // ============================================================
  // Persona Colours
  // ============================================================

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  // ============================================================
  // Event State
  // ============================================================

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool reminder = false;

  // ============================================================
  // Initialize
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      titleController.text = widget.event!.title;

      descriptionController.text =
          widget.event!.description ?? '';

      selectedDate = widget.event!.date;

      selectedTime = TimeOfDay.fromDateTime(
        widget.event!.date,
      );

      reminder = widget.event!.reminder;
    }
  }

  // ============================================================
  // Select Date
  // ============================================================

  Future<void> selectDate() async {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    final DateTime? pickedDate =
    await showDatePicker(
      context: context,
      initialDate:
      selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
              primary: oliveDrab,
              onPrimary: Colors.white,
              surface: darkCard,
              onSurface: Colors.white,
            )
                : const ColorScheme.light(
              primary: oliveDrab,
              onPrimary: Colors.white,
              surface: lightCream,
              onSurface: darkOlive,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // Select Time
  // ============================================================

  Future<void> selectTime() async {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    final TimeOfDay? pickedTime =
    await showTimePicker(
      context: context,
      initialTime:
      selectedTime ?? TimeOfDay.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
              primary: oliveDrab,
              onPrimary: Colors.white,
              surface: darkCard,
              onSurface: Colors.white,
            )
                : const ColorScheme.light(
              primary: oliveDrab,
              onPrimary: Colors.white,
              surface: lightCream,
              onSurface: darkOlive,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // ============================================================
  // Save Event
  // ============================================================

  void saveEvent() {
    final String title =
    titleController.text.trim();

    final String description =
    descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Please enter an event title',
      );
      return;
    }

    if (selectedDate == null) {
      _showMessage(
        'Please select a date',
      );
      return;
    }

    if (selectedTime == null) {
      _showMessage(
        'Please select a time',
      );
      return;
    }

    final DateTime eventDateTime =
    DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (reminder &&
        eventDateTime.isBefore(
          DateTime.now(),
        )) {
      _showMessage(
        'Reminder time must be in the future',
      );
      return;
    }

    final CalendarEvent event =
    CalendarEvent(
      id: widget.event?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      title: title,

      date: eventDateTime,

      description:
      description.isEmpty
          ? null
          : description,

      reminder: reminder,
    );

    Navigator.pop(
      context,
      event,
    );
  }

  // ============================================================
  // Snackbar
  // ============================================================

  void _showMessage(String message) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        backgroundColor: isDarkMode
            ? darkOlive
            : darkOlive,

        behavior:
        SnackBarBehavior.floating,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // Glass Input Decoration
  // ============================================================

  InputDecoration glassInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final Color secondaryText =
    Colors.white.withValues(
      alpha: 0.85,
    );

    final Color hintText =
    Colors.white.withValues(
      alpha: 0.45,
    );

    final Color fillColor = isDarkMode
        ? Colors.black.withValues(
      alpha: 0.18,
    )
        : Colors.white.withValues(
      alpha: 0.12,
    );

    final Color borderColor =
    Colors.white.withValues(
      alpha: isDarkMode
          ? 0.20
          : 0.25,
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: secondaryText,
      ),

      labelStyle: TextStyle(
        color: secondaryText,
      ),

      hintStyle: TextStyle(
        color: hintText,
      ),

      filled: true,
      fillColor: fillColor,

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(18),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),

      focusedBorder:
      const OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(18),
        ),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // Glass Card
  // ============================================================

  Widget glassCard({
    required Widget child,
    required bool isDarkMode,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(20),
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(24),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withValues(
              alpha: 0.20,
            )
                : Colors.white.withValues(
              alpha: 0.13,
            ),

            borderRadius:
            BorderRadius.circular(24),

            border: Border.all(
              color:
              Colors.white.withValues(
                alpha: isDarkMode
                    ? 0.18
                    : 0.25,
              ),
            ),
          ),

          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // Date Card
  // ============================================================

  Widget buildDateSelector(
      bool isDarkMode,
      ) {
    return InkWell(
      onTap: selectDate,

      borderRadius:
      BorderRadius.circular(18),

      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black.withValues(
            alpha: 0.18,
          )
              : Colors.white.withValues(
            alpha: 0.12,
          ),

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color:
            Colors.white.withValues(
              alpha: isDarkMode
                  ? 0.20
                  : 0.25,
            ),
          ),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'Date',

                    style: TextStyle(
                      color:
                      Colors.white.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    selectedDate == null
                        ? 'Select date'
                        : '${selectedDate!.day}/'
                        '${selectedDate!.month}/'
                        '${selectedDate!.year}',

                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,

              color:
              Colors.white.withValues(
                alpha: 0.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Time Card
  // ============================================================

  Widget buildTimeSelector(
      bool isDarkMode,
      ) {
    return InkWell(
      onTap: selectTime,

      borderRadius:
      BorderRadius.circular(18),

      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black.withValues(
            alpha: 0.18,
          )
              : Colors.white.withValues(
            alpha: 0.12,
          ),

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color:
            Colors.white.withValues(
              alpha: isDarkMode
                  ? 0.20
                  : 0.25,
            ),
          ),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: Colors.white,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'Time',

                    style: TextStyle(
                      color:
                      Colors.white.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    selectedTime == null
                        ? 'Select time'
                        : selectedTime!
                        .format(context),

                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,

              color:
              Colors.white.withValues(
                alpha: 0.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isEditing =
        widget.event != null;

    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),

          onPressed: () =>
              Navigator.pop(context),
        ),

        title: Text(
          isEditing
              ? 'Edit Calendar Event'
              : 'Add Calendar Event',

          style: const TextStyle(
            color: Colors.white,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: isDarkMode
                ? const [
              darkOlive,
              darkCard,
              darkBackground,
            ]
                : const [
              oliveDrab,
              olive,
              darkOlive,
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                // ==================================================
                // Header
                // ==================================================

                glassCard(
                  isDarkMode:
                  isDarkMode,

                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,

                        decoration:
                        BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: isDarkMode
                                ? 0.12
                                : 0.18,
                          ),

                          shape:
                          BoxShape.circle,

                          border:
                          Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: isDarkMode
                                  ? 0.20
                                  : 0.25,
                            ),
                          ),
                        ),

                        child: const Icon(
                          Icons
                              .event_note_outlined,
                          color:
                          Colors.white,
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
                              isEditing
                                  ? 'Update your event'
                                  : 'Create a new event',

                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 19,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              isEditing
                                  ? 'Make changes to your calendar event.'
                                  : 'Add something important to your calendar.',

                              style: TextStyle(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.70,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // Event Details
                // ==================================================

                glassCard(
                  isDarkMode:
                  isDarkMode,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                    children: [
                      const Text(
                        'Event Details',

                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      TextField(
                        controller:
                        titleController,

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),

                        decoration:
                        glassInputDecoration(
                          label:
                          'Event Title',
                          hint:
                          'Enter event title',
                          icon:
                          Icons.title_outlined,
                          isDarkMode:
                          isDarkMode,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      buildDateSelector(
                        isDarkMode,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      buildTimeSelector(
                        isDarkMode,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                        descriptionController,

                        maxLines: 4,

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),

                        decoration:
                        glassInputDecoration(
                          label:
                          'Description',
                          hint:
                          'Enter event description',
                          icon: Icons
                              .description_outlined,
                          isDarkMode:
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // Reminder
                // ==================================================

                glassCard(
                  isDarkMode:
                  isDarkMode,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  child:
                  CheckboxListTile(
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 4,
                    ),

                    title: const Text(
                      'Reminder',

                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),

                    subtitle: Text(
                      reminder
                          ? 'You will receive a reminder for this event.'
                          : 'No reminder will be scheduled.',

                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: 0.65,
                        ),
                        fontSize: 12,
                      ),
                    ),

                    secondary:
                    Container(
                      width: 42,
                      height: 42,

                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: isDarkMode
                              ? 0.10
                              : 0.15,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          13,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons
                            .notifications_none,
                        color:
                        Colors.white,
                      ),
                    ),

                    activeColor:
                    Colors.white,

                    checkColor:
                    oliveDrab,

                    value: reminder,

                    onChanged:
                        (bool? value) {
                      setState(() {
                        reminder =
                            value ?? false;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  height: 26,
                ),

                // ==================================================
                // Save Button
                // ==================================================

                SizedBox(
                  height: 56,

                  child:
                  ElevatedButton.icon(
                    onPressed:
                    saveEvent,

                    icon: Icon(
                      isEditing
                          ? Icons.check
                          : Icons.add,

                      color:
                      darkOlive,
                    ),

                    label: Text(
                      isEditing
                          ? 'UPDATE EVENT'
                          : 'SAVE EVENT',

                      style:
                      const TextStyle(
                        color:
                        darkOlive,
                        fontWeight:
                        FontWeight
                            .bold,
                        letterSpacing:
                        0.8,
                      ),
                    ),

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      Colors.white,

                      foregroundColor:
                      darkOlive,

                      elevation: 4,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // Persona Branding
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    Icon(
                      Icons.spa_outlined,

                      color: Colors.white
                          .withValues(
                        alpha: 0.65,
                      ),

                      size: 18,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      'PERSONA',

                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: 0.65,
                        ),

                        fontSize: 12,

                        fontWeight:
                        FontWeight.bold,

                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}