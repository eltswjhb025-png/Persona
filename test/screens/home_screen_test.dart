import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:persona/screens/home_screen.dart';
import 'package:persona/services/theme_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget createTestApp() {
    final ThemeService themeService = ThemeService();

    return ThemeProvider(
      themeService: themeService,
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets(
      'displays Persona title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('Persona'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Welcome back text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('Welcome back 👋'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Birthdays menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('Birthdays'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Calendar menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('Calendar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Locator menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('Locator'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays SOS menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.text('SOS'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Settings button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pump();

        expect(
          find.byIcon(Icons.settings_outlined),
          findsOneWidget,
        );
      },
    );
  });
}