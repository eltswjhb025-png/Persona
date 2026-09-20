import 'package:flutter/material.dart';

class BirthdaysScreen extends StatelessWidget{
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birthdays'),
      ),
      body: const Center(
        child: Text(
          'No birthdays yet',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        //ADD PERSON SCREEN WILL BE ADDED HERE
      },
        child: const Icon(Icons.add),
      ),
    );
  }
}