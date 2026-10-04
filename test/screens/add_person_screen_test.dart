import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:persona/models/person.dart';
import 'package:persona/screens/add_person_screen.dart';
import 'package:persona/services/theme_service.dart';

void main() {
  group('AddPersonScreen', () {
    testWidgets(
      'displays Add Person screen',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const MaterialApp(
              home: AddPersonScreen(),
            ),
          ),
        );

        expect(
          find.text('Add Person'),
          findsOneWidget,
        );

        expect(
          find.text('Save Person'),
          findsOneWidget,
        );

        expect(
          find.text('Enter person\'s name'),
          findsOneWidget,
        );

        expect(find.text('Select birthday'), findsWidgets);

        expect(
          find.text('Enter phone number'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows error when name is empty',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const MaterialApp(
              home: AddPersonScreen(),
            ),
          ),
        );

        await tester.tap(
          find.text('Save Person'),
        );

        await tester.pump();

        expect(
          find.text('Please enter a name'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows error when birthday is not selected',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const MaterialApp(
              home: AddPersonScreen(),
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField).first,
          'Elizabeth',
        );

        await tester.tap(
          find.text('Save Person'),
        );

        await tester.pump();

        expect(find.text('Select birthday'), findsWidgets);
      },
    );

    testWidgets(
      'allows the user to enter a name',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const MaterialApp(
              home: AddPersonScreen(),
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField).first,
          'Elizabeth',
        );

        expect(
          find.text('Elizabeth'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'allows the user to enter a phone number',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: const MaterialApp(
              home: AddPersonScreen(),
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField).last,
          '0123456789',
        );

        expect(
          find.text('0123456789'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'loads existing person in edit mode',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        final Person person = Person(
          id: '1',
          name: 'Elizabeth',
          birthday: DateTime(2009, 5, 15),
          phoneNumber: '0123456789',
        );

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: MaterialApp(
              home: AddPersonScreen(
                person: person,
              ),
            ),
          ),
        );

        expect(
          find.text('Edit Person'),
          findsOneWidget,
        );

        expect(
          find.text('Update Person'),
          findsOneWidget,
        );

        expect(
          find.text('Elizabeth'),
          findsOneWidget,
        );

        expect(
          find.text('0123456789'),
          findsOneWidget,
        );

        expect(
          find.text('15/5/2009'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'returns an updated Person when saving valid information',
          (WidgetTester tester) async {
        final ThemeService themeService = ThemeService();

        final Person person = Person(
          id: '1',
          name: 'Elizabeth',
          birthday: DateTime(2009, 5, 15),
          phoneNumber: '0123456789',
        );

        Person? returnedPerson;

        await tester.pumpWidget(
          ThemeProvider(
            themeService: themeService,
            child: MaterialApp(
              home: Builder(
                builder: (BuildContext context) {
                  return ElevatedButton(
                    onPressed: () async {
                      returnedPerson =
                      await Navigator.push<Person>(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return AddPersonScreen(
                              person: person,
                            );
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Open Add Person',
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(
          find.text('Open Add Person'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Edit Person'),
          findsOneWidget,
        );

        expect(
          find.text('Update Person'),
          findsOneWidget,
        );

        expect(
          find.text('Elizabeth'),
          findsOneWidget,
        );

        expect(
          find.text('0123456789'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byType(TextField).first,
          'Elizabeth Updated',
        );

        await tester.tap(
          find.text('Update Person'),
        );

        await tester.pumpAndSettle();

        expect(
          returnedPerson,
          isNotNull,
        );

        expect(
          returnedPerson!.id,
          '1',
        );

        expect(
          returnedPerson!.name,
          'Elizabeth Updated',
        );

        expect(
          returnedPerson!.birthday,
          DateTime(2009, 5, 15),
        );

        expect(
          returnedPerson!.phoneNumber,
          '0123456789',
        );

        expect(
          find.text('Edit Person'),
          findsNothing,
        );
      },
    );
  });
}