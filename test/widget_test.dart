import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona/main.dart';
import 'package:persona/screens/home_screen.dart';

void main() {
  group('PersonaApp', () {

    testWidgets('creates the Persona application', (WidgetTester tester) async {
      await tester.pumpWidget(
        const PersonaApp(),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('displays the HomeScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const PersonaApp(),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}