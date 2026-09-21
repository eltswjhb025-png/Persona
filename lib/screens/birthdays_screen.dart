import 'package:flutter/material.dart';
import '../models/person.dart';
import 'add_person_screen.dart';
import '../widgets/birthday_card.dart';

class BirthdaysScreen extends StatefulWidget{
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen>{
  final List<Person> people = [];

  List<Person> getSortedPeople() {
    final List<Person> sortedPeople = List.from(people);

    sortedPeople.sort((a, b) {
      return daysUntilBirthday(a).compareTo(
        daysUntilBirthday(b),
      );
    });

    return sortedPeople;
  }

  int daysUntilBirthday(Person person) {
    final DateTime today = DateTime.now();

    DateTime nextBirthday = DateTime(
      today.year,
      person.birthday.month,
      person.birthday.day,
    );

    if (nextBirthday.isBefore(
      DateTime(today.year, today.month, today.day),
    )) {
      nextBirthday = DateTime(
        today.year  + 1 ,
        person.birthday.month,
        person.birthday.day,
      );
    }

    return nextBirthday
        .difference(
      DateTime(today.year, today.month, today.day),
    ).inDays;
  }

  Future<void> addPerson() async{
    final Person? person = await Navigator.push<Person>(
      context,
      MaterialPageRoute(
          builder: (context) => AddPersonScreen(),
      ),
    );

    if (person != null){
      setState(() {
        people.add(person);
      });
    }
  }

  @override
  Widget build(BuildContext context){
    final List<Person> sortedPeople = getSortedPeople();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Birthdays'),
      ),

      body: people.isEmpty
      ? const Center(
        child: Text(
          'No birthdays yet',
          style: TextStyle(fontSize: 20),
        ),
      )
          : ListView.builder(
            itemCount: sortedPeople.length,
            itemBuilder: (context, index){
              final Person person = sortedPeople[index];

              return BirthdayCard(
                  person: person,
              );
            },
      ),
          floatingActionButton: FloatingActionButton(
             onPressed: addPerson,
             child: const Icon(Icons.add),
          ),
        );
  }
}