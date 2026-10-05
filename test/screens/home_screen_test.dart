import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:persona/screens/home_screen.dart';
import 'package:persona/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp() {
    return ThemeProvider(
      themeService: ThemeService(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(
          loadData: false,
        ),
      ),
    );
  }

  Future<void> pumpHomeScreen(
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      createTestApp(),
    );

    await tester.pump();
  }

  group('HomeScreen', () {
    testWidgets(
      'creates HomeScreen',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(HomeScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays welcome message',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Welcome, Persona User 👋',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays main heading',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Your world,\nall in one place.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays home description',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Birthdays, events, location and emergency support.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Persona logo icons',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byIcon(
            Icons.spa_outlined,
          ),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'displays settings button',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byIcon(
            Icons.settings_outlined,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Your Persona section',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Your Persona',
          ),
          findsOneWidget,
        );

        expect(
          find.text(
            'Stay connected to what matters.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Birthdays card',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Birthdays',
          ),
          findsOneWidget,
        );

        expect(
          find.text(
            'Never miss an important birthday',
          ),
          findsOneWidget,
        );

        expect(
          find.byIcon(
            Icons.cake_outlined,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Calendar card',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Calendar',
          ),
          findsOneWidget,
        );

        expect(
          find.text(
            'Keep track of your important events',
          ),
          findsOneWidget,
        );

        expect(
          find.byIcon(
            Icons.calendar_month_outlined,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Locator card',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Locator',
          ),
          findsOneWidget,
        );

        expect(
          find.text(
            'Find and share your location',
          ),
          findsOneWidget,
        );

        expect(
          find.byIcon(
            Icons.location_on_outlined,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays SOS card',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'SOS',
          ),
          findsOneWidget,
        );

        expect(
          find.text(
            'Emergency assistance when you need it',
          ),
          findsOneWidget,
        );

        expect(
          find.byIcon(
            Icons.sos_outlined,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays all four feature cards',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text('Birthdays'),
          findsOneWidget,
        );

        expect(
          find.text('Calendar'),
          findsOneWidget,
        );

        expect(
          find.text('Locator'),
          findsOneWidget,
        );

        expect(
          find.text('SOS'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays upcoming event heading',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'UPCOMING EVENT',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays nothing coming up',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Nothing coming up',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays upcoming event explanation',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'Your upcoming birthdays and calendar events will appear here.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays four feature card arrows',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byIcon(
            Icons.arrow_forward_ios_rounded,
          ),
          findsNWidgets(4),
        );
      },
    );

    testWidgets(
      'displays bottom Persona branding',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.text(
            'PERSONA',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays anime image',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(Image),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays Scaffold',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(Scaffold),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays SafeArea',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(SafeArea),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets(
      'displays RefreshIndicator',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(RefreshIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays SingleChildScrollView',
          (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(
          find.byType(
            SingleChildScrollView,
          ),
          findsOneWidget,
        );
      },
    );
  });
}