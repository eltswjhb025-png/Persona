import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/birthday_service.dart';

class BirthdayCard extends StatelessWidget {
  final Person person;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BirthdayCard({
    super.key,
    required this.person,
    required this.onDelete,
    required this.onEdit,
  });

  // ============================================================
  // PERSONA COLOURS
  // ============================================================

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);

  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  @override
  Widget build(BuildContext context) {
    final int days = BirthdayService.daysUntilBirthday(
      person.birthday,
    );

    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final Color titleColor =
    isDarkMode ? Colors.white : darkOlive;

    final Color subtitleColor =
    isDarkMode
        ? Colors.white70
        : darkOlive.withValues(alpha: 0.75);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        // ======================================================
        // GLASSMORPHISM BLUR
        // ======================================================

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),

          child: Container(
            decoration: BoxDecoration(
              // =================================================
              // GLASS BACKGROUND
              // =================================================

              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.16),

              borderRadius: BorderRadius.circular(20),

              // =================================================
              // GLASS BORDER
              // =================================================

              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.45),
                width: 1.2,
              ),

              // =================================================
              // SUBTLE SHADOW
              // =================================================

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDarkMode ? 0.20 : 0.10,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              // ==================================================
              // CAKE ICON
              // ==================================================

              leading: Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: isDarkMode
                      ? oliveDrab.withValues(alpha: 0.20)
                      : oliveDrab.withValues(alpha: 0.16),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: oliveDrab.withValues(
                      alpha: isDarkMode ? 0.45 : 0.35,
                    ),
                  ),
                ),

                child: const Icon(
                  Icons.cake,
                  size: 30,
                  color: oliveDrab,
                ),
              ),

              // ==================================================
              // NAME
              // ==================================================

              title: Text(
                person.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),

              // ==================================================
              // DETAILS
              // ==================================================

              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                ),

                child: Text(
                  '${person.birthday.day}/'
                      '${person.birthday.month}/'
                      '${person.birthday.year}\n'
                      '${days == 0 ? 'Birthday today 🎂🎉!' : '$days days to go'}'
                      '${person.phoneNumber != null ? '\n${person.phoneNumber}' : ''}',

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: subtitleColor,
                  ),
                ),
              ),

              // ==================================================
              // EDIT / DELETE MENU
              // ==================================================

              trailing: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDarkMode
                      ? Colors.white70
                      : darkOlive,
                ),

                color: isDarkMode
                    ? darkCard
                    : const Color(0xFFF4F5E9),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                elevation: 8,

                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },

                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',

                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: isDarkMode
                                ? oliveDrab
                                : darkOlive,
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Edit',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : darkOlive,
                            ),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'delete',

                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: isDarkMode
                                ? Colors.redAccent
                                : Colors.red.shade700,
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Delete',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : darkOlive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}