import 'package:flutter/material.dart';
import '../models/person.dart';
import 'add_person_screen.dart';
import '../widgets/birthday_card.dart';
import '../database/database_helper.dart';
import '../services/reminder_service.dart';


class BirthdaysScreen extends StatefulWidget{
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen>{
  final List<Person> people = [];
  final DatabaseHelper databaseHelper = DatabaseHelper();

  Future<void> loadPeople() async {
    final List<Person> savedPeople = await databaseHelper.getPeople();
    if (!mounted){
      return;
    }

    setState(() {
      people.clear();
      people.addAll(savedPeople);
    });
  }

  @override
  void initState() {
    super.initState();
    loadPeople();
  }

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
      await databaseHelper.insertPerson(person);

      setState(() {
        people.add(person);
      });
      await ReminderService.scheduleBirthdayReminders(person);
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

                onEdit: () async {
                    final Person? updatedPerson = await Navigator.push<Person>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPersonScreen(
                            person: person,
                          ),
                      ),
                    );
                    if (updatedPerson != null) {
                      await ReminderService.cancelBirthdayReminders(person);

                      await databaseHelper.updatePerson(updatedPerson);

                      setState(() {
                        final int index = people.indexWhere(
                              (p) => p.id == person.id,
                        );

                        if (index != -1) {
                          people[index] = updatedPerson;
                        }
                      });

                      await ReminderService.scheduleBirthdayReminders(updatedPerson);
                    }
                },
                onDelete: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Person'),
                            content: Text('Are you sure you want to delete ${person.name}?',
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                              ),
                              TextButton(
                              onPressed: () async {
                                await ReminderService.cancelBirthdayReminders(person);

                                await databaseHelper.deletePerson(person.id);

                                setState(() {
                                  people.remove(person);
                                });

                                Navigator.pop(context);
                              },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                    );
                }
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