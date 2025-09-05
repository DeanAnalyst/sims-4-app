import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sims4_name_generator/main.dart';
import 'package:sims4_name_generator/navigation/app_routes.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('App should start on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: Sims4NameGeneratorApp()));

      // Verify we're on the home screen
      expect(find.text('Sims 4 Name Generator'), findsOneWidget);
      expect(find.text('Select Region'), findsOneWidget);
      expect(find.text('Generate Name'), findsOneWidget);
    });

    testWidgets('Should navigate to settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: Sims4NameGeneratorApp()));

      // Tap settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Default Preferences'), findsOneWidget);
    });

    testWidgets('Should navigate to trait browser screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: Sims4NameGeneratorApp()));

      // Tap trait browser button
      await tester.tap(find.byIcon(Icons.psychology));
      await tester.pumpAndSettle();

      // Verify we're on trait browser screen
      expect(find.text('Trait Browser'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Should navigate back from settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: Sims4NameGeneratorApp()));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('Sims 4 Name Generator'), findsOneWidget);
      expect(find.text('Select Region'), findsOneWidget);
    });

    testWidgets('Should navigate back from trait browser screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: Sims4NameGeneratorApp()));

      // Navigate to trait browser
      await tester.tap(find.byIcon(Icons.psychology));
      await tester.pumpAndSettle();

      // Verify we're on trait browser screen
      expect(find.text('Trait Browser'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('Sims 4 Name Generator'), findsOneWidget);
      expect(find.text('Select Region'), findsOneWidget);
    });

    testWidgets('AppRoutes should provide correct route names', (WidgetTester tester) async {
      expect(AppRoutes.home, equals('/'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.traitBrowser, equals('/trait-browser'));
    });

    testWidgets('AppRoutes should provide route builders', (WidgetTester tester) async {
      final routes = AppRoutes.routes;
      
      expect(routes.containsKey(AppRoutes.home), isTrue);
      expect(routes.containsKey(AppRoutes.settings), isTrue);
      expect(routes.containsKey(AppRoutes.traitBrowser), isTrue);
      
      // Test that route builders return widgets
      final homeBuilder = routes[AppRoutes.home]!;
      final homeWidget = homeBuilder(tester.element(find.byType(MaterialApp)));
      expect(homeWidget, isA<Widget>());
    });
  });
} 