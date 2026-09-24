import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class AddCalendarEventScreen extends StatefulWidget {
  final CalendarEvent? event;

  const AddCalendarEventScreen(
      {super.key,
        this.event,
      });

  @override
  State<AddCalendarEventScreen> createState() =>
      _AddCalendarEventScreenState();
}

class _AddCalendarEventScreenState
    extends State<AddCalendarEventScreen> {

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool reminder = false;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      titleController.text = widget.event!.title;

      descriptionController.text =
          widget.event!.description ?? '';

      selectedDate = widget.event!.date;

      selectedTime = TimeOfDay.fromDateTime(
        widget.event!.date,
      );

      reminder = widget.event!.reminder;
    }
  }

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void saveEvent() {
    final String title = titleController.text.trim();
    final String description =
    descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title'),
        ),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
        ),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
        ),
      );
      return;
    }

    final DateTime eventDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (reminder && eventDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder time must be in the future',
          ),
        ),
      );
      return;
    }

    final CalendarEvent event = CalendarEvent(
      id: widget.event?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: eventDateTime,
      description:
      description.isEmpty ? null : description,
      reminder: reminder,
    );

    Navigator.pop(context, event);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null
              ? 'Add Calendar Event'
              : 'Edit Calendar Event',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: selectDate,

              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),

                child: Text(
                  selectedDate == null
                      ? 'Select date'
                      : '${selectedDate!.day}/'
                      '${selectedDate!.month}/'
                      '${selectedDate!.year}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: selectTime,

              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),

                child: Text(
                  selectedTime == null
                      ? 'Select time'
                      : selectedTime!.format(context),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter event description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            CheckboxListTile(
              title: const Text('Reminder'),
              value: reminder,

              onChanged: (bool? value) {
                setState(() {
                  reminder = value ?? false;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveEvent,

              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}