import 'package:flutter/material.dart';
import '../models/person.dart';
import 'add_person_screen.dart';

class BirthdaysScreen extends StatefulWidget{
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen>{
  final List<Person> people = [];

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
            itemCount: people.length,
            itemBuilder: (context, index){
              final Person person = people[index];

              return ListTile(
                leading: const Icon(Icons.cake),
                title: Text(person.name),
                subtitle: Text(
                  '${person.birthday.day}/'
                      '${person.birthday.month}/'
                      '${person.birthday.year}',
                ),
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