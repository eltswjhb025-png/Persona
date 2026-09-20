class Person {
  final String id;
  final String name;
  final DateTime birthday;
  final String? phoneNumber;

  Person({
    required this.id,
    required this.name,
    required this.birthday,
    this.phoneNumber,
});
}