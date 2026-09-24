class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final bool reminder;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.reminder = false,
  });
}