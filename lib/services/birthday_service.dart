import '../models/person.dart';

class BirthdayService {
  /// Returns the next occurrence of a birthday.
  static DateTime getNextBirthday(DateTime birthday) {
    final DateTime today = DateTime.now();

    DateTime nextBirthday = DateTime(
      today.year,
      birthday.month,
      birthday.day,
    );

    // If this year's birthday has already passed,
    // use next year's birthday.
    if (nextBirthday.isBefore(
      DateTime(today.year, today.month, today.day),
    )) {
      nextBirthday = DateTime(
        today.year + 1,
        birthday.month,
        birthday.day,
      );
    }

    return nextBirthday;
  }

  /// Returns the number of days until the next birthday.
  static int daysUntilBirthday(DateTime birthday) {
    final DateTime today = DateTime.now();

    final DateTime todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final DateTime nextBirthday = getNextBirthday(birthday);

    return nextBirthday.difference(todayOnly).inDays;
  }

  /// Returns a birthday message for a person.
  static String getBirthdayMessage(Person person) {
    final int days = daysUntilBirthday(person.birthday);

    if (days == 0) {
      return "Today is ${person.name}'s birthday! 🎂";
    }

    if (days == 1) {
      return "Tomorrow is ${person.name}'s birthday! 🎉";
    }

    return "$days days until ${person.name}'s birthday.";
  }
}