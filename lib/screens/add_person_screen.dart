import 'package:flutter/material.dart';
import '../models/person.dart';

class AddPersonScreen extends StatefulWidget{
  final Person? person;

  const AddPersonScreen({
    super.key,
    this.person
  });

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen>{
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  DateTime? selectedBirthday;

  Future<void> selectBirthday() async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if(pickedDate != null){
      setState(() {
        selectedBirthday = pickedDate;
      });
    }
  }
  void savePerson(){
    final String name = nameController.text.trim();
    final String phoneNumber = phoneController.text.trim();

    if(name.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:Text('Please enter a name'),
        ),
      );
      return;
    }

    if (selectedBirthday == null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a birthday'),
          ),
    );
      return;
    }

    final Person person = Person(
        id: widget.person?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        birthday: selectedBirthday!,
        phoneNumber: phoneNumber.isEmpty? null : phoneNumber,
    );

    Navigator.pop(context, person);
  }

  @override
  void dispose(){
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.person != null) {
      nameController.text = widget.person!.name;
      phoneController.text = widget.person!.phoneNumber ?? '';
      selectedBirthday = widget.person!.birthday;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.person == null ? 'Add Person' : 'Edit Person',
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: "Enter person's name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: selectBirthday,
              child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    border: OutlineInputBorder(),
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

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                     labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

               ElevatedButton(
                   onPressed: savePerson,
                   child: Text(
                       widget.person == null ? 'Save Person' : 'Update Person',
                   ),
            ),
          ],
        ),
      ),
    );
  }
}