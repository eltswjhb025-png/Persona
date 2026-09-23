import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:persona/screens/birthdays_screen.dart';
import 'package:persona/database/database_helper.dart';

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

  group('BirthdaysScreen', () {
    testWidgets(
      'displays Birthdays title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: BirthdaysScreen(),
          ),
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
          const MaterialApp(
            home: BirthdaysScreen(),
          ),
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
          const MaterialApp(
            home: BirthdaysScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(FloatingActionButton),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.add),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Add Person screen when add button is pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: BirthdaysScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(
          find.byIcon(Icons.add),
        );

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