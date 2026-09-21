import 'package:flutter/material.dart';
import '../models/person.dart';

class BirthdayCard extends StatelessWidget {
  final Person person;

  const BirthdayCard({
    super.key,
    required this.person,
  });

  int daysUntilBirthday() {
    final DateTime today = DateTime.now();

    DateTime nextBirthday = DateTime(
      today.year,
      person.birthday.month,
      person.birthday.day,
    );

    if (nextBirthday.isBefore(
      DateTime(today.year, today.month, today.day),
    )){
      nextBirthday = DateTime(
        today.year + 1,
        person.birthday.month,
        person.birthday.day,
      );
    }

    return nextBirthday
        .difference(
      DateTime(today.year, today.month, today.day),
    ).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final int days = daysUntilBirthday();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: const Icon(
          Icons.cake,
          size: 40,
        ),
        title: Text(
          person.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${person.birthday.day}/'
              '${person.birthday.month}/'
              '${person.birthday.year}\n'
          '${days == 0 ? 'Birthday today!' : '$days days to go'}',
        ),
      ),
    );
  }
}