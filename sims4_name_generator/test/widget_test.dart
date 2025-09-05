import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sims4_name_generator/main.dart';

void main() {
  testWidgets('App should start with correct title', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: Sims4NameGeneratorApp()),
    );

    // Verify that our app has the correct title in the app bar
    expect(find.text('Sims 4 Name Generator'), findsOneWidget);
  });
}
