import 'package:flutter/material.dart';
import '../models/person.dart';

class AddPersonScreen extends StatefulWidget {
  final Person? person;

  const AddPersonScreen({
    super.key,
    this.person,
  });

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  DateTime? selectedBirthday;

  // Persona colours
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color background = Color(0xFFF4F5E9);

  @override
  void initState() {
    super.initState();

    if (widget.person != null) {
      nameController.text = widget.person!.name;

      phoneController.text =
          widget.person!.phoneNumber ?? '';

      selectedBirthday = widget.person!.birthday;
    }
  }

  Future<void> selectBirthday() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,

      // Use the existing birthday when editing.
      initialDate: selectedBirthday ?? DateTime.now(),

      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedBirthday = pickedDate;
      });
    }
  }

  void savePerson() {
    final String name = nameController.text.trim();

    final String phoneNumber =
    phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a name',
          ),
        ),
      );

      return;
    }

    if (selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a birthday',
          ),
        ),
      );

      return;
    }

    final Person person = Person(
      id: widget.person?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      name: name,

      birthday: selectedBirthday!,

      phoneNumber: phoneNumber.isEmpty
          ? null
          : phoneNumber,
    );

    Navigator.pop(
      context,
      person,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.person != null;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Person'
              : 'Add Person',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oliveDrab,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            // ---------------- NAME ----------------
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText:
                "Enter person's name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- BIRTHDAY ----------------
            InkWell(
              onTap: selectBirthday,

              child: InputDecorator(
                decoration:
                const InputDecoration(
                  labelText: 'Birthday',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.cake_outlined,
                  ),
                ),

                child: Text(
                  selectedBirthday == null
                      ? 'Select birthday'
                      : '${selectedBirthday!.day}/'
                      '${selectedBirthday!.month}/'
                      '${selectedBirthday!.year}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- PHONE ----------------
            TextField(
              controller: phoneController,

              keyboardType:
              TextInputType.phone,

              decoration:
              const InputDecoration(
                labelText: 'Phone Number',
                hintText:
                'Enter phone number',
                border:
                OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- SAVE / UPDATE ----------------
            ElevatedButton(
              onPressed: savePerson,

              style:
              ElevatedButton.styleFrom(
                backgroundColor: olive,
                foregroundColor: Colors.white,

                padding:
                const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),

              child: Text(
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
            ),
          ],
        ),
      ),
    );
  }
}