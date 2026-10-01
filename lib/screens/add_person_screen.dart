import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/person.dart';

class AddPersonScreen extends StatefulWidget {
final Person? person;

const AddPersonScreen({
super.key,
this.person,
});

@override
State<AddPersonScreen> createState() =>
_AddPersonScreenState();
}

class _AddPersonScreenState
extends State<AddPersonScreen> {
final TextEditingController nameController =
TextEditingController();

final TextEditingController phoneController =
TextEditingController();

DateTime? selectedBirthday;

// ============================================================
// PERSONA COLOURS
// ============================================================

static const Color oliveDrab =
Color(0xFF6B8E23);

static const Color olive =
Color(0xFF808000);

static const Color darkOlive =
Color(0xFF3F4A16);

static const Color lightCream =
Color(0xFFF4F5E9);

// ============================================================
// INITIALIZE
// ============================================================

@override
void initState() {
super.initState();

if (widget.person != null) {
nameController.text =
widget.person!.name;

phoneController.text =
widget.person!.phoneNumber ?? '';

selectedBirthday =
widget.person!.birthday;
}
}

// ============================================================
// SELECT BIRTHDAY
// ============================================================

Future<void> selectBirthday() async {
// Remove keyboard before opening the date picker.
FocusScope.of(context).unfocus();

final DateTime? pickedDate =
await showDatePicker(
context: context,
initialDate:
selectedBirthday ?? DateTime.now(),
firstDate:
DateTime(1900),
lastDate:
DateTime.now(),
builder: (context, child) {
return Theme(
data: Theme.of(context).copyWith(
colorScheme:
const ColorScheme.light(
primary: olive,
onPrimary: Colors.white,
surface: lightCream,
onSurface: darkOlive,
),
),
child: child!,
);
},
);

if (!mounted) return;

if (pickedDate != null) {
setState(() {
selectedBirthday =
pickedDate;
});
}
}

// ============================================================
// SAVE PERSON
// ============================================================

Future<void> savePerson() async {
// Remove the keyboard before navigating away.
FocusScope.of(context).unfocus();

final String name =
nameController.text.trim();

final String phoneNumber =
phoneController.text.trim();

// ==========================================================
// VALIDATE NAME
// ==========================================================

if (name.isEmpty) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
backgroundColor:
darkOlive,
behavior:
SnackBarBehavior.floating,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
content: const Text(
'Please enter a name',
style: TextStyle(
color: Colors.white,
),
),
),
);

return;
}

// ==========================================================
// VALIDATE BIRTHDAY
// ==========================================================

if (selectedBirthday == null) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
backgroundColor:
darkOlive,
behavior:
SnackBarBehavior.floating,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
content: const Text(
'Please select a birthday',
style: TextStyle(
color: Colors.white,
),
),
),
);

return;
}

// ==========================================================
// CREATE PERSON
// ==========================================================

final Person person =
Person(
id: widget.person?.id ??
DateTime.now()
    .millisecondsSinceEpoch
    .toString(),

name: name,

birthday:
selectedBirthday!,

phoneNumber:
phoneNumber.isEmpty
? null
    : phoneNumber,
);

// Give Flutter a moment to finish
// removing the keyboard focus before
// navigating away from this screen.
await Future<void>.delayed(
const Duration(milliseconds: 50),
);

if (!mounted) return;

// ==========================================================
// RETURN PERSON TO BIRTHDAYS SCREEN
// ==========================================================

Navigator.pop(
context,
person,
);
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
nameController.dispose();
phoneController.dispose();

super.dispose();
}

// ============================================================
// GLASS INPUT
// ============================================================

InputDecoration glassInputDecoration({
required String label,
required String hint,
required IconData icon,
}) {
return InputDecoration(
filled: true,

fillColor:
Colors.white.withValues(
alpha: 0.14,
),

labelText: label,

labelStyle: TextStyle(
color:
Colors.white.withValues(
alpha: 0.85,
),
),

hintText: hint,

hintStyle: TextStyle(
color:
Colors.white.withValues(
alpha: 0.5,
),
),

prefixIcon: Icon(
icon,
color:
Colors.white.withValues(
alpha: 0.75,
),
),

contentPadding:
const EdgeInsets.symmetric(
horizontal: 18,
vertical: 18,
),

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),

borderSide: BorderSide(
color:
Colors.white.withValues(
alpha: 0.25,
),
),
),

enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),

borderSide: BorderSide(
color:
Colors.white.withValues(
alpha: 0.25,
),
),
),

focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),

borderSide:
const BorderSide(
color: Colors.white,
width: 2,
),
),
);
}

// ============================================================
// GLASS CARD
// ============================================================

Widget glassCard({
required Widget child,
EdgeInsets padding =
const EdgeInsets.all(20),
double borderRadius = 26,
}) {
return ClipRRect(
borderRadius:
BorderRadius.circular(
borderRadius,
),

child: BackdropFilter(
filter: ImageFilter.blur(
sigmaX: 14,
sigmaY: 14,
),

child: Container(
padding: padding,

decoration: BoxDecoration(
color:
Colors.white.withValues(
alpha: 0.14,
),

borderRadius:
BorderRadius.circular(
borderRadius,
),

border: Border.all(
color:
Colors.white.withValues(
alpha: 0.28,
),
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
Widget build(
BuildContext context) {
final bool isEditing =
widget.person != null;

return Scaffold(
backgroundColor:
oliveDrab,

// Allows Flutter to resize the screen
// when the keyboard appears.
resizeToAvoidBottomInset: true,

// ========================================================
// APP BAR
// ========================================================

appBar: AppBar(
backgroundColor:
Colors.transparent,

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
Icons.person_add_alt_1_outlined,
color: Colors.white,
size: 22,
),
),

const SizedBox(width: 12),

Text(
isEditing
? 'Edit Person'
    : 'Add Person',

style:
const TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
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
decoration:
const BoxDecoration(
gradient:
LinearGradient(
begin:
Alignment.topLeft,
end:
Alignment.bottomRight,

colors: [
oliveDrab,
olive,
darkOlive,
],
),
),

child: SafeArea(
top: false,

child:
SingleChildScrollView(
keyboardDismissBehavior:
ScrollViewKeyboardDismissBehavior
    .onDrag,

padding:
const EdgeInsets.fromLTRB(
18,
10,
18,
40,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .stretch,

children: [
// ==================================================
// HEADER
// ==================================================

glassCard(
padding:
const EdgeInsets.all(
20,
),

child: Row(
children: [
Container(
padding:
const EdgeInsets
    .all(13),

decoration:
BoxDecoration(
color: Colors.white
    .withValues(
alpha: 0.16,
),

shape:
BoxShape.circle,

border:
Border.all(
color: Colors
    .white
    .withValues(
alpha: 0.2,
),
),
),

child: const Icon(
Icons.cake_outlined,
color:
Colors.white,
size: 28,
),
),

const SizedBox(
width: 14,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Text(
isEditing
? 'Update Birthday'
    : 'New Birthday',

style:
const TextStyle(
color:
Colors.white,
fontSize: 19,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 5,
),

Text(
isEditing
? 'Update this person’s details.'
    : 'Add someone special to Persona.',

style:
TextStyle(
color: Colors
    .white
    .withValues(
alpha: 0.7,
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
// FORM
// ==================================================

glassCard(
padding:
const EdgeInsets.all(
20,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .stretch,

children: [
// ==========================================
// NAME
// ==========================================

TextField(
controller:
nameController,

style:
const TextStyle(
color: Colors.white,
),

decoration:
glassInputDecoration(
label: 'Name',

hint:
"Enter person's name",

icon:
Icons.person_outline,
),
),

const SizedBox(
height: 18,
),

// ==========================================
// BIRTHDAY
// ==========================================

InkWell(
onTap:
selectBirthday,

borderRadius:
BorderRadius.circular(
18,
),

child:
InputDecorator(
decoration:
glassInputDecoration(
label:
'Birthday',

hint:
'Select birthday',

icon:
Icons.cake_outlined,
),

child: Text(
selectedBirthday ==
null
? 'Select birthday'
    : '${selectedBirthday!.day}/'
'${selectedBirthday!.month}/'
'${selectedBirthday!.year}',

style:
TextStyle(
color:
selectedBirthday ==
null
? Colors
    .white
    .withValues(
alpha: 0.5,
)
    : Colors
    .white,

fontSize: 16,
),
),
),
),

const SizedBox(
height: 18,
),

// ==========================================
// PHONE
// ==========================================

TextField(
controller:
phoneController,

keyboardType:
TextInputType.phone,

style:
const TextStyle(
color: Colors.white,
),

decoration:
glassInputDecoration(
label:
'Phone Number',

hint:
'Enter phone number',

icon:
Icons.phone_outlined,
),
),
],
),
),

const SizedBox(
height: 24,
),

// ==================================================
// SAVE BUTTON
// ==================================================

SizedBox(
height: 56,

child:
ElevatedButton(
onPressed:
savePerson,

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
BorderRadius.circular(
18,
),
),
),

child: Row(
mainAxisAlignment:
MainAxisAlignment
    .center,

children: [
Icon(
isEditing
? Icons
    .check_circle_outline
    : Icons
    .person_add_alt_1_outlined,

size: 21,
),

const SizedBox(
width: 9,
),

Text(
isEditing
? 'Update Person'
    : 'Save Person',

style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
),
),
],
),
),
),

const SizedBox(
height: 20,
),

// ==================================================
// PERSONA BRANDING
// ==================================================

Row(
mainAxisAlignment:
MainAxisAlignment
    .center,

children: [
Icon(
Icons.spa_outlined,
color:
Colors.white
    .withValues(
alpha: 0.65,
),

size: 17,
),

const SizedBox(
width: 7,
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

// Extra space so the keyboard
// does not push the content into
// an overflow.
SizedBox(
height:
MediaQuery.of(context)
    .viewInsets
    .bottom,
),
],
),
),
),
),
);
}
}