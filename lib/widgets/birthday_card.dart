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

  static const Color oliveDrab = Color(0xFF6B8E23);

  @override
  Widget build(BuildContext context) {
    final int days = BirthdayService.daysUntilBirthday(
      person.birthday,
    );

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // ---------------- CAKE ICON ----------------
        leading: const Icon(
          Icons.cake,
          size: 40,
          color: oliveDrab,
        ),

        // ---------------- NAME ----------------
        title: Text(
          person.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // ---------------- DETAILS ----------------
        subtitle: Text(
          '${person.birthday.day}/'
              '${person.birthday.month}/'
              '${person.birthday.year}\n'
              '${days == 0 ? 'Birthday today!' : '$days days to go'}'
              '${person.phoneNumber != null ? '\n${person.phoneNumber}' : ''}',
        ),

        // ---------------- MENU ----------------
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ];
          },
        ),
      ),
    );
  }
}