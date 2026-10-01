import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/person.dart';
import 'add_person_screen.dart';
import '../widgets/birthday_card.dart';
import '../database/database_helper.dart';
import '../services/reminder_service.dart';
import '../services/birthday_service.dart';

class BirthdaysScreen extends StatefulWidget {
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen> {
  final List<Person> people = [];
  final DatabaseHelper databaseHelper = DatabaseHelper();

  // ============================================================
  // PERSONA COLOURS
  // ============================================================

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color lightOlive = Color(0xFFE8ECD5);
  static const Color background = Color(0xFFF4F5E9);
  static const Color darkOlive = Color(0xFF3F4A16);

  // ============================================================
  // LOAD PEOPLE
  // ============================================================

  Future<void> loadPeople() async {
    final List<Person> savedPeople =
    await databaseHelper.getPeople();

    if (!mounted) {
      return;
    }

    setState(() {
      people.clear();
      people.addAll(savedPeople);
    });
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadPeople();
  }

  // ============================================================
  // SORT PEOPLE BY NEXT BIRTHDAY
  // ============================================================

  List<Person> getSortedPeople() {
    final List<Person> sortedPeople =
    List.from(people);

    sortedPeople.sort((a, b) {
      return BirthdayService.daysUntilBirthday(
        a.birthday,
      ).compareTo(
        BirthdayService.daysUntilBirthday(
          b.birthday,
        ),
      );
    });

    return sortedPeople;
  }

  // ============================================================
  // ADD PERSON
  // ============================================================

  Future<void> addPerson() async {
    final Person? person =
    await Navigator.push<Person>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AddPersonScreen(),
      ),
    );

    if (person != null) {
      await databaseHelper.insertPerson(person);

      if (!mounted) {
        return;
      }

      setState(() {
        people.add(person);
      });

      await ReminderService
          .scheduleBirthdayReminders(person);
    }
  }

  // ============================================================
  // GLASS CARD
  // ============================================================

  Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
    double borderRadius = 24,
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(borderRadius),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.15,
            ),

            borderRadius:
            BorderRadius.circular(
              borderRadius,
            ),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.28,
              ),

              width: 1,
            ),
          ),

          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<Person> sortedPeople =
    getSortedPeople();

    return Scaffold(
      backgroundColor: oliveDrab,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Row(
          children: [
            Container(
              padding:
              const EdgeInsets.all(9),

              decoration: BoxDecoration(
                color:
                Colors.white.withValues(
                  alpha: 0.16,
                ),

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

                border: Border.all(
                  color:
                  Colors.white.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),

              child: const Icon(
                Icons.cake_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'Birthdays',
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

          child: people.isEmpty
              ? _buildEmptyState()

              : ListView.builder(
            padding:
            const EdgeInsets.only(
              top: 12,
              bottom: 100,
            ),

            itemCount:
            sortedPeople.length,

            itemBuilder:
                (context, index) {
              final Person person =
              sortedPeople[index];

              return Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),

                child: _buildBirthdayItem(
                  person,
                ),
              );
            },
          ),
        ),
      ),

      // ========================================================
      // ADD BUTTON
      // ========================================================

      floatingActionButton:
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color:
              darkOlive.withValues(
                alpha: 0.35,
              ),

              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),

        child: FloatingActionButton(
          onPressed: addPerson,

          backgroundColor:
          Colors.white,

          foregroundColor:
          darkOlive,

          elevation: 4,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),

          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation
          .endFloat,
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: glassCard(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),

          borderRadius: 26,

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Container(
                padding:
                const EdgeInsets.all(
                  18,
                ),

                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.15,
                  ),

                  shape:
                  BoxShape.circle,

                  border: Border.all(
                    color:
                    Colors.white.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),

                child: const Icon(
                  Icons.cake_outlined,
                  size: 45,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'No birthdays yet',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add someone special to your '
                    'birthday list.',

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  color:
                  Colors.white.withValues(
                    alpha: 0.7,
                  ),

                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // Small visual hint toward the
              // floating action button.
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Add a birthday',
                      style: TextStyle(
                        color:
                        Colors.white
                            .withValues(
                          alpha: 0.85,
                        ),

                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BIRTHDAY ITEM
  // ============================================================

  Widget _buildBirthdayItem(
      Person person,
      ) {
    return glassCard(
      padding:
      const EdgeInsets.all(6),

      borderRadius: 24,

      child: BirthdayCard(
        person: person,

        // ======================================================
        // EDIT
        // ======================================================

        onEdit: () async {
          final Person? updatedPerson =
          await Navigator.push<Person>(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  AddPersonScreen(
                    person: person,
                  ),
            ),
          );

          if (updatedPerson != null) {
            await ReminderService
                .cancelBirthdayReminders(
              person,
            );

            await databaseHelper
                .updatePerson(
              updatedPerson,
            );

            if (!mounted) {
              return;
            }

            setState(() {
              final int index =
              people.indexWhere(
                    (p) => p.id == person.id,
              );

              if (index != -1) {
                people[index] =
                    updatedPerson;
              }
            });

            await ReminderService
                .scheduleBirthdayReminders(
              updatedPerson,
            );
          }
        },

        // ======================================================
        // DELETE
        // ======================================================

        onDelete: () {
          showDialog(
            context: context,

            builder: (context) {
              return AlertDialog(
                backgroundColor:
                const Color(0xFFF4F5E9),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),
                ),

                title: const Text(
                  'Delete Person',

                  style: TextStyle(
                    color: darkOlive,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                content: Text(
                  'Are you sure you want '
                      'to delete ${person.name}?',

                  style: const TextStyle(
                    color: darkOlive,
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child: const Text(
                      'Cancel',

                      style: TextStyle(
                        color: oliveDrab,
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
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    onPressed: () async {
                      await ReminderService
                          .cancelBirthdayReminders(
                        person,
                      );

                      await databaseHelper
                          .deletePerson(
                        person.id,
                      );

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        people.remove(
                          person,
                        );
                      });

                      Navigator.pop(
                        context,
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
        },
      ),
    );
  }
}