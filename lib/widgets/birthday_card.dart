import 'package:flutter/material.dart';
import '../models/person.dart';

class BirthdayCard extends StatelessWidget {
  final Person person;

  const BirthdayCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
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
              '${person.birthday.year}',
        ),
      ),
    );
  }
}