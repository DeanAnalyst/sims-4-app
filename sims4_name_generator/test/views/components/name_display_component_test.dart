import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/providers/character_providers.dart';
import 'package:sims4_name_generator/providers/state_providers.dart';
import 'package:sims4_name_generator/providers/data_providers.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/character_storage_service.dart';
import 'package:sims4_name_generator/views/components/name_display_component.dart';

// Generate mocks
@GenerateMocks([NameRepository, TraitRepository, CharacterStorageService])
import 'name_display_component_test.mocks.dart';

void main() {
  group('NameDisplayComponent', () {
    late MockNameRepository mockNameRepository;
    late MockTraitRepository mockTraitRepository;

    setUp(() {
      mockNameRepository = MockNameRepository();
      mockTraitRepository = MockTraitRepository();
    });

    testWidgets('displays empty state when no name is generated', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nameRepositoryProvider.overrideWithValue(mockNameRepository),
            traitRepositoryProvider.overrideWithValue(mockTraitRepository),
          ],
          child: MaterialApp(home: Scaffold(body: NameDisplayComponent())),
        ),
      );

      expect(find.text('No name generated yet'), findsOneWidget);
      expect(
        find.text('Tap "Generate Name" to create a random name'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('displays loading state during name generation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nameRepositoryProvider.overrideWithValue(mockNameRepository),
            traitRepositoryProvider.overrideWithValue(mockTraitRepository),
            characterGeneratorProvider.overrideWith((ref) {
              return MockCharacterGeneratorNotifier(
                const CharacterGeneratorState(isGeneratingName: true),
              );
            }),
          ],
          child: MaterialApp(home: Scaffold(body: NameDisplayComponent())),
        ),
      );

      expect(find.text('Generating name...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays generated name with details', (tester) async {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nameRepositoryProvider.overrideWithValue(mockNameRepository),
            traitRepositoryProvider.overrideWithValue(mockTraitRepository),
            characterGeneratorProvider.overrideWith((ref) {
              return MockCharacterGeneratorNotifier(
                const CharacterGeneratorState(generatedName: testName),
              );
            }),
          ],
          child: MaterialApp(home: Scaffold(body: NameDisplayComponent())),
        ),
      );

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('First Name:'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Last Name:'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);
      expect(find.text('Region:'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Gender:'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
    });

    testWidgets('displays error state with error message', (tester) async {
      const errorMessage = 'Failed to generate name: Network error';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nameRepositoryProvider.overrideWithValue(mockNameRepository),
            traitRepositoryProvider.overrideWithValue(mockTraitRepository),
            characterGeneratorProvider.overrideWith((ref) {
              return MockCharacterGeneratorNotifier(
                const CharacterGeneratorState(error: errorMessage),
              );
            }),
          ],
          child: MaterialApp(home: Scaffold(body: NameDisplayComponent())),
        ),
      );

      expect(find.text('Error generating name'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('regenerate button calls generateName', (tester) async {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      final mockNotifier = MockCharacterGeneratorNotifier(
        const CharacterGeneratorState(generatedName: testName),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nameRepositoryProvider.overrideWithValue(mockNameRepository),
            traitRepositoryProvider.overrideWithValue(mockTraitRepository),
            characterGeneratorProvider.overrideWith((ref) => mockNotifier),
            selectedRegionProvider.overrideWith((ref) => Region.english),
            selectedGenderProvider.overrideWith((ref) => Gender.male),
          ],
          child: MaterialApp(home: Scaffold(body: NameDisplayComponent())),
        ),
      );

      // Tap the regenerate button
      await tester.tap(find.text('New Name'));
      await tester.pump();

      expect(mockNotifier.generateNameCalled, isTrue);
      expect(mockNotifier.lastRegion, Region.english);
      expect(mockNotifier.lastGender, Gender.male);
    });
  });
}

/// Mock implementation of CharacterGeneratorNotifier for testing
class MockCharacterGeneratorNotifier extends CharacterGeneratorNotifier {
  CharacterGeneratorState _state;
  bool generateNameCalled = false;
  Region? lastRegion;
  Gender? lastGender;

  MockCharacterGeneratorNotifier(this._state)
    : super(
        MockNameRepository(),
        MockTraitRepository(),
        MockCharacterStorageService(),
      );

  @override
  CharacterGeneratorState get state => _state;

  @override
  Future<void> generateName(
    Region region,
    Gender gender, {
    bool avoidDuplicates = true,
  }) async {
    generateNameCalled = true;
    lastRegion = region;
    lastGender = gender;
  }

  @override
  void clearError() {
    _state = _state.copyWith(clearError: true);
  }
}
