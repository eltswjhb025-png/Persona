import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('displays the Persona title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Persona'), findsOneWidget);
    });

    testWidgets('displays Birthday Reminder text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Birthday Reminder'), findsOneWidget);
    });

    testWidgets(
        'displays the My Birthdays button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('My Birthdays'), findsOneWidget);
    });

    testWidgets(
        'displays the Test Notification button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Test Notification'), findsOneWidget);
    });

    testWidgets('displays the Test Scheduled Notification button',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: HomeScreen(),
            ),
          );

          expect(
            find.text('Test Scheduled Notification'),
            findsOneWidget,
          );
        });

    testWidgets('contains the cake icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byIcon(Icons.cake), findsOneWidget);
    });
  });
}