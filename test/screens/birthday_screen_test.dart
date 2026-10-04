import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:persona/screens/birthdays_screen.dart';
import 'package:persona/database/database_helper.dart';
import 'package:persona/services/theme_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final DatabaseHelper databaseHelper = DatabaseHelper();

  setUp(() async {
    final db = await databaseHelper.database;
    await db.delete('people');
  });

  Widget createTestApp() {
    final ThemeService themeService = ThemeService();

    return ThemeProvider(
      themeService: themeService,
      child: const MaterialApp(
        home: BirthdaysScreen(),
      ),
    );
  }

  group('BirthdaysScreen', () {
    testWidgets(
      'displays Birthdays title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Birthdays'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays No birthdays yet when there are no people',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('No birthdays yet'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays the add button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(FloatingActionButton),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byType(FloatingActionButton),
            matching: find.byIcon(Icons.add),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Add Person screen when add button is pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(),
        );

        await tester.pumpAndSettle();

        final Finder addButton = find.byType(
          FloatingActionButton,
        );

        expect(
          addButton,
          findsOneWidget,
        );

        await tester.tap(addButton);

        await tester.pumpAndSettle();

        expect(
          find.text('Add Person'),
          findsOneWidget,
        );

        expect(
          find.text('Save Person'),
          findsOneWidget,
        );
      },
    );
  });
}