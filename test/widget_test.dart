import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:persona/main.dart';
import 'package:persona/screens/login_screen.dart';
import 'package:persona/services/theme_service.dart';

void main() {
  group('PersonaApp', () {
    testWidgets(
      'creates the Persona application',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const PersonaApp(),
          ),
        );

        expect(
          find.byType(MaterialApp),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays the LoginScreen',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const PersonaApp(),
          ),
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );
      },
    );
  });
}