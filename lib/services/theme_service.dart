import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_darkModeKey, value);

    notifyListeners();
  }
}

class ThemeProvider extends InheritedNotifier<ThemeService> {
  const ThemeProvider({
    super.key,
    required ThemeService themeService,
    required Widget child,
  }) : super(
    notifier: themeService,
    child: child,
  );

  static ThemeService of(BuildContext context) {
    final provider =
    context.dependOnInheritedWidgetOfExactType<ThemeProvider>();

    assert(
    provider != null,
    'ThemeProvider could not be found in the widget tree.',
    );

    return provider!.notifier!;
  }
}