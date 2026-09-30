import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets(
      'displays Persona title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        expect(
          find.text('Persona'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Welcome to Persona text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        expect(
          find.text('Welcome to Persona'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays My Birthdays menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        expect(
          find.text('My Birthdays'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Calendar menu',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

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
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.ensureVisible(
          find.text('Locator'),
        );

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
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.ensureVisible(
          find.text('SOS'),
        );

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
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        expect(
          find.byIcon(Icons.settings_outlined),
          findsOneWidget,
        );
      },
    );
  });
}