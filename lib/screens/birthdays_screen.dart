import 'package:flutter/material.dart';
import '../models/person.dart';
import 'add_person_screen.dart';
import '../widgets/birthday_card.dart';
import '../database/database_helper.dart';
import '../services/reminder_service.dart';

class BirthdaysScreen extends StatefulWidget {
const BirthdaysScreen({super.key});

@override
State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen> {
final List<Person> people = [];
final DatabaseHelper databaseHelper = DatabaseHelper();

// Olive colour palette
static const Color oliveDrab = Color(0xFF6B8E23);
static const Color olive = Color(0xFF808000);
static const Color lightOlive = Color(0xFFE8ECD5);
static const Color background = Color(0xFFF4F5E9);
static const Color darkOlive = Color(0xFF3F4A16);

Future<void> loadPeople() async {
final List<Person> savedPeople = await databaseHelper.getPeople();

if (!mounted) {
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
today.year + 1,
person.birthday.month,
person.birthday.day,
);
}

return nextBirthday
    .difference(
DateTime(today.year, today.month, today.day),
)
    .inDays;
}

Future<void> addPerson() async {
final Person? person = await Navigator.push<Person>(
context,
MaterialPageRoute(
builder: (context) => AddPersonScreen(),
),
);

if (person != null) {
await databaseHelper.insertPerson(person);

setState(() {
people.add(person);
});

await ReminderService.scheduleBirthdayReminders(person);
}
}

@override
Widget build(BuildContext context) {
final List<Person> sortedPeople = getSortedPeople();

return Scaffold(
backgroundColor: background,

// ---------------- APP BAR ----------------
appBar: AppBar(
title: const Text(
'Birthdays',
style: TextStyle(
fontWeight: FontWeight.bold,
letterSpacing: 0.5,
),
),
backgroundColor: oliveDrab,
foregroundColor: Colors.white,
elevation: 0,

centerTitle: true,
),

// ---------------- BODY ----------------
body: people.isEmpty
? Center(
child: Container(
margin: const EdgeInsets.all(24),
padding: const EdgeInsets.all(30),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: lightOlive,
width: 2,
),
boxShadow: [
BoxShadow(
color: olive.withOpacity(0.12),
blurRadius: 15,
offset: const Offset(0, 6),
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: lightOlive,
shape: BoxShape.circle,
),
child: const Icon(
Icons.cake_outlined,
size: 45,
color: oliveDrab,
),
),

const SizedBox(height: 18),

const Text(
'No birthdays yet',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: darkOlive,
),
),

const SizedBox(height: 8),

const Text(
'Add someone special to your birthday list.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
color: Colors.grey,
),
),
],
),
),
)

// ---------------- BIRTHDAY LIST ----------------
    : ListView.builder(
padding: const EdgeInsets.only(
top: 12,
bottom: 90,
),
itemCount: sortedPeople.length,
itemBuilder: (context, index) {
final Person person = sortedPeople[index];

return Padding(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),

child: BirthdayCard(
person: person,

onEdit: () async {
final Person? updatedPerson =
await Navigator.push<Person>(
context,
MaterialPageRoute(
builder: (context) => AddPersonScreen(
person: person,
),
),
);

if (updatedPerson != null) {
await ReminderService
    .cancelBirthdayReminders(person);

await databaseHelper
    .updatePerson(updatedPerson);

setState(() {
final int index = people.indexWhere(
(p) => p.id == person.id,
);

if (index != -1) {
people[index] = updatedPerson;
}
});

await ReminderService
    .scheduleBirthdayReminders(updatedPerson);
}
},

onDelete: () {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
backgroundColor: background,

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),

title: const Text(
'Delete Person',
style: TextStyle(
color: darkOlive,
fontWeight: FontWeight.bold,
),
),

content: Text(
'Are you sure you want to delete ${person.name}?',
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
'Cancel',
style: TextStyle(
color: oliveDrab,
),
),
),

TextButton(
onPressed: () async {
await ReminderService
    .cancelBirthdayReminders(person);

await databaseHelper
    .deletePerson(person.id);

if (!mounted) {
return;
}

setState(() {
people.remove(person);
});

Navigator.pop(context);
},

child: const Text(
'Delete',
style: TextStyle(
color: Colors.red,
fontWeight: FontWeight.bold,
),
),
),
],
);
},
);
},
),
);
},
),

// ---------------- ADD BUTTON ----------------
floatingActionButton: FloatingActionButton(
onPressed: addPerson,

backgroundColor: olive,
foregroundColor: Colors.white,

elevation: 6,

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),

child: const Icon(
Icons.add,
size: 30,
),
),

floatingActionButtonLocation:
FloatingActionButtonLocation.endFloat,
);
}
}