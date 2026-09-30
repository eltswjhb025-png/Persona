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
  static const Color oliveDrab =
  Color(0xFF6B8E23);

  static const Color olive =
  Color(0xFF808000);

  static const Color background =
  Color(0xFFF4F5E9);

  // Dark Mode colours
  static const Color darkBackground =
  Color(0xFF121510);

  static const Color darkField =
  Color(0xFF1E231B);

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

  Future<void> selectBirthday() async {
    final DateTime? pickedDate =
    await showDatePicker(
      context: context,

      // Use the existing birthday when editing.
      initialDate:
      selectedBirthday ??
          DateTime.now(),

      firstDate:
      DateTime(1900),

      lastDate:
      DateTime.now(),

      // Make the date picker follow
      // the current application theme.
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedBirthday =
            pickedDate;
      });
    }
  }

  void savePerson() {
    final String name =
    nameController.text.trim();

    final String phoneNumber =
    phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a name',
          ),
        ),
      );

      return;
    }

    if (selectedBirthday == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a birthday',
          ),
        ),
      );

      return;
    }

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
  Widget build(
      BuildContext context) {
    final bool isEditing =
        widget.person != null;

    // Check the current theme.
    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    // ---------------- COLORS ----------------

    final Color screenBackground =
    isDarkMode
        ? darkBackground
        : background;

    final Color fieldBackground =
    isDarkMode
        ? darkField
        : Colors.white;

    // Black text in Light Mode.
    // White text in Dark Mode.
    final Color textColor =
    isDarkMode
        ? Colors.white
        : Colors.black;

    final Color hintColor =
    isDarkMode
        ? Colors.white60
        : Colors.black54;

    final Color iconColor =
    isDarkMode
        ? Colors.white70
        : Colors.black54;

    final Color borderColor =
    isDarkMode
        ? Colors.white54
        : Colors.black54;

    return Scaffold(
      // ---------------- BACKGROUND ----------------
      backgroundColor:
      screenBackground,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Person'
              : 'Add Person',

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        // Uses the current app theme.
        centerTitle: true,
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [
            // ---------------- NAME ----------------

            TextField(
              controller:
              nameController,

              // Input text.
              style: TextStyle(
                color: textColor,
              ),

              decoration:
              InputDecoration(
                filled: true,

                fillColor:
                fieldBackground,

                labelText: 'Name',

                labelStyle:
                TextStyle(
                  color: textColor,
                ),

                hintText:
                "Enter person's name",

                hintStyle:
                TextStyle(
                  color: hintColor,
                ),

                border:
                const OutlineInputBorder(),

                enabledBorder:
                OutlineInputBorder(
                  borderSide:
                  BorderSide(
                    color:
                    borderColor,
                  ),
                ),

                focusedBorder:
                const OutlineInputBorder(
                  borderSide:
                  BorderSide(
                    color: olive,
                    width: 2,
                  ),
                ),

                prefixIcon:
                Icon(
                  Icons
                      .person_outline,
                  color: iconColor,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ---------------- BIRTHDAY ----------------

            InkWell(
              onTap:
              selectBirthday,

              child:
              InputDecorator(
                decoration:
                InputDecoration(
                  filled: true,

                  fillColor:
                  fieldBackground,

                  labelText:
                  'Birthday',

                  labelStyle:
                  TextStyle(
                    color:
                    textColor,
                  ),

                  border:
                  const OutlineInputBorder(),

                  enabledBorder:
                  OutlineInputBorder(
                    borderSide:
                    BorderSide(
                      color:
                      borderColor,
                    ),
                  ),

                  focusedBorder:
                  const OutlineInputBorder(
                    borderSide:
                    BorderSide(
                      color: olive,
                      width: 2,
                    ),
                  ),

                  prefixIcon:
                  Icon(
                    Icons
                        .cake_outlined,
                    color:
                    iconColor,
                  ),
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
                        ? hintColor
                        : textColor,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ---------------- PHONE ----------------

            TextField(
              controller:
              phoneController,

              keyboardType:
              TextInputType.phone,

              // Input text.
              style: TextStyle(
                color: textColor,
              ),

              decoration:
              InputDecoration(
                filled: true,

                fillColor:
                fieldBackground,

                labelText:
                'Phone Number',

                labelStyle:
                TextStyle(
                  color: textColor,
                ),

                hintText:
                'Enter phone number',

                hintStyle:
                TextStyle(
                  color: hintColor,
                ),

                border:
                const OutlineInputBorder(),

                enabledBorder:
                OutlineInputBorder(
                  borderSide:
                  BorderSide(
                    color:
                    borderColor,
                  ),
                ),

                focusedBorder:
                const OutlineInputBorder(
                  borderSide:
                  BorderSide(
                    color: olive,
                    width: 2,
                  ),
                ),

                prefixIcon:
                Icon(
                  Icons
                      .phone_outlined,
                  color: iconColor,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ---------------- SAVE / UPDATE ----------------

            ElevatedButton(
              onPressed:
              savePerson,

              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                olive,

                foregroundColor:
                Colors.white,

                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 16,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
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

                  color:
                  Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}