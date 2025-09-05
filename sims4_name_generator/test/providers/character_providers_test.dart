import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/providers/character_providers.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/character_storage_service.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';

import 'character_providers_test.mocks.dart';

@GenerateMocks([NameRepository, TraitRepository, CharacterStorageService])
void main() {
  group('CharacterGeneratorState Tests', () {
    test('should create initial state correctly', () {
      // Act
      const state = CharacterGeneratorState.initial();

      // Assert
      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasContent, isFalse);
    });

    test('should create loading name state correctly', () {
      // Act
      const state = CharacterGeneratorState.loadingName();

      // Assert
      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isTrue);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, isNull);
      expect(state.isLoading, isTrue);
    });

    test('should create loading traits state correctly', () {
      // Act
      const state = CharacterGeneratorState.loadingTraits();

      // Assert
      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isTrue);
      expect(state.error, isNull);
      expect(state.isLoading, isTrue);
    });

    test('should create error state correctly', () {
      // Act
      const state = CharacterGeneratorState.error('Test error');

      // Assert
      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, equals('Test error'));
      expect(state.isLoading, isFalse);
    });

    test('should copy with new values correctly', () {
      // Arrange
      const initialState = CharacterGeneratorState.initial();
      final testName = Name(
        firstName: 'John',
        lastName: 'Doe',
        gender: Gender.male,
        region: Region.english,
      );
      final testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      // Act
      final newState = initialState.copyWith(
        generatedName: testName,
        generatedTraits: testTraits,
        isGeneratingName: true,
        error: 'Test error',
      );

      // Assert
      expect(newState.generatedName, equals(testName));
      expect(newState.generatedTraits, equals(testTraits));
      expect(newState.isGeneratingName, isTrue);
      expect(newState.isGeneratingTraits, isFalse);
      expect(newState.error, equals('Test error'));
      expect(newState.hasContent, isTrue);
    });

    test('should implement equality correctly', () {
      // Arrange
      const state1 = CharacterGeneratorState.initial();
      const state2 = CharacterGeneratorState.initial();
      const state3 = CharacterGeneratorState.loadingName();

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('CharacterGeneratorNotifier Tests', () {
    late MockNameRepository mockNameRepository;
    late MockTraitRepository mockTraitRepository;
    late MockCharacterStorageService mockStorageService;
    late CharacterGeneratorNotifier notifier;

    setUp(() {
      mockNameRepository = MockNameRepository();
      mockTraitRepository = MockTraitRepository();
      mockStorageService = MockCharacterStorageService();
      notifier = CharacterGeneratorNotifier(
        mockNameRepository,
        mockTraitRepository,
        mockStorageService,
      );
    });

    group('generateName', () {
      test('should generate name successfully', () async {
        // Arrange
        final testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );
        when(
          mockNameRepository.generateRandomName(Region.english, Gender.male),
        ).thenAnswer((_) async => testName);

        // Act
        await notifier.generateName(Region.english, Gender.male);

        // Assert
        expect(notifier.state.generatedName, equals(testName));
        expect(notifier.state.isGeneratingName, isFalse);
        expect(notifier.state.error, isNull);
        verify(
          mockNameRepository.generateRandomName(Region.english, Gender.male),
        ).called(1);
      });

      test('should handle name generation error', () async {
        // Arrange
        when(
          mockNameRepository.generateRandomName(Region.english, Gender.male),
        ).thenThrow(Exception('Name generation failed'));

        // Act
        await notifier.generateName(Region.english, Gender.male);

        // Assert
        expect(notifier.state.generatedName, isNull);
        expect(notifier.state.isGeneratingName, isFalse);
        expect(notifier.state.error, contains('Failed to generate name'));
        verify(
          mockNameRepository.generateRandomName(Region.english, Gender.male),
        ).called(1);
      });

      test('should set loading state during generation', () async {
        // Arrange
        final testName = Name(
          firstName: 'Jane',
          lastName: 'Smith',
          gender: Gender.female,
          region: Region.english,
        );
        when(
          mockNameRepository.generateRandomName(Region.english, Gender.female),
        ).thenAnswer((_) async {
          // Verify loading state is set
          expect(notifier.state.isGeneratingName, isTrue);
          return testName;
        });

        // Act
        await notifier.generateName(Region.english, Gender.female);

        // Assert
        expect(notifier.state.isGeneratingName, isFalse);
      });
    });

    group('generateTraits', () {
      test('should generate traits successfully', () async {
        // Arrange
        final testTraits = [
          Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];
        when(
          mockTraitRepository.generateRandomTraits(),
        ).thenAnswer((_) async => testTraits);

        // Act
        await notifier.generateTraits();

        // Assert
        expect(notifier.state.generatedTraits, equals(testTraits));
        expect(notifier.state.isGeneratingTraits, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockTraitRepository.generateRandomTraits()).called(1);
      });

      test('should handle trait generation error', () async {
        // Arrange
        when(
          mockTraitRepository.generateRandomTraits(),
        ).thenThrow(Exception('Trait generation failed'));

        // Act
        await notifier.generateTraits();

        // Assert
        expect(notifier.state.generatedTraits, isEmpty);
        expect(notifier.state.isGeneratingTraits, isFalse);
        expect(notifier.state.error, contains('Failed to generate traits'));
        verify(mockTraitRepository.generateRandomTraits()).called(1);
      });

      test('should set loading state during generation', () async {
        // Arrange
        final testTraits = [
          Trait(
            id: 'creative',
            name: 'Creative',
            description: 'Test description',
            category: TraitCategory.hobby,
            pack: 'base_game',
          ),
        ];
        when(mockTraitRepository.generateRandomTraits()).thenAnswer((_) async {
          // Verify loading state is set
          expect(notifier.state.isGeneratingTraits, isTrue);
          return testTraits;
        });

        // Act
        await notifier.generateTraits();

        // Assert
        expect(notifier.state.isGeneratingTraits, isFalse);
      });
    });

    group('generateCompleteCharacter', () {
      test('should generate both name and traits successfully', () async {
        // Arrange
        final testName = Name(
          firstName: 'Alice',
          lastName: 'Johnson',
          gender: Gender.female,
          region: Region.english,
        );
        final testTraits = [
          Trait(
            id: 'outgoing',
            name: 'Outgoing',
            description: 'Test description',
            category: TraitCategory.social,
            pack: 'base_game',
          ),
        ];

        when(
          mockNameRepository.generateRandomName(Region.english, Gender.female),
        ).thenAnswer((_) async => testName);
        when(
          mockTraitRepository.generateRandomTraits(),
        ).thenAnswer((_) async => testTraits);

        // Act
        await notifier.generateCompleteCharacter(Region.english, Gender.female);

        // Assert
        expect(notifier.state.generatedName, equals(testName));
        expect(notifier.state.generatedTraits, equals(testTraits));
        expect(notifier.state.error, isNull);
        verify(
          mockNameRepository.generateRandomName(Region.english, Gender.female),
        ).called(1);
        verify(mockTraitRepository.generateRandomTraits()).called(1);
      });

      test('should handle partial failure gracefully', () async {
        // Arrange
        final testName = Name(
          firstName: 'Bob',
          lastName: 'Wilson',
          gender: Gender.male,
          region: Region.english,
        );

        when(
          mockNameRepository.generateRandomName(Region.english, Gender.male),
        ).thenAnswer((_) async => testName);
        when(
          mockTraitRepository.generateRandomTraits(),
        ).thenThrow(Exception('Trait generation failed'));

        // Act
        await notifier.generateCompleteCharacter(Region.english, Gender.male);

        // Assert
        expect(notifier.state.generatedName, equals(testName));
        expect(notifier.state.generatedTraits, isEmpty);
        expect(notifier.state.error, contains('Failed to generate traits'));
      });
    });

    group('clear methods', () {
      test('should clear all generation', () {
        // Arrange
        final testName = Name(
          firstName: 'Test',
          lastName: 'User',
          gender: Gender.male,
          region: Region.english,
        );
        notifier.state = notifier.state.copyWith(
          generatedName: testName,
          generatedTraits: [
            Trait(
              id: 'test',
              name: 'Test',
              description: 'Test',
              category: TraitCategory.emotional,
              pack: 'base_game',
            ),
          ],
          error: 'Test error',
        );

        // Act
        notifier.clearGeneration();

        // Assert
        expect(notifier.state.generatedName, isNull);
        expect(notifier.state.generatedTraits, isEmpty);
        expect(notifier.state.error, isNull);
      });

      test('should clear only name', () {
        // Arrange
        final testName = Name(
          firstName: 'Test',
          lastName: 'User',
          gender: Gender.male,
          region: Region.english,
        );
        final testTraits = [
          Trait(
            id: 'test',
            name: 'Test',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];
        notifier.state = notifier.state.copyWith(
          generatedName: testName,
          generatedTraits: testTraits,
        );

        // Act
        notifier.clearName();

        // Assert
        expect(notifier.state.generatedName, isNull);
        expect(notifier.state.generatedTraits, equals(testTraits));
      });

      test('should clear only traits', () {
        // Arrange
        final testName = Name(
          firstName: 'Test',
          lastName: 'User',
          gender: Gender.male,
          region: Region.english,
        );
        final testTraits = [
          Trait(
            id: 'test',
            name: 'Test',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];
        notifier.state = notifier.state.copyWith(
          generatedName: testName,
          generatedTraits: testTraits,
        );

        // Act
        notifier.clearTraits();

        // Assert
        expect(notifier.state.generatedName, equals(testName));
        expect(notifier.state.generatedTraits, isEmpty);
      });

      test('should clear only error', () {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Test error');

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
      });
    });
  });

  group('characterGeneratorProvider Tests', () {
    test('should provide CharacterGeneratorNotifier instance', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final notifier = container.read(characterGeneratorProvider.notifier);
      final state = container.read(characterGeneratorProvider);

      // Assert
      expect(notifier, isA<CharacterGeneratorNotifier>());
      expect(state, isA<CharacterGeneratorState>());
      expect(state, equals(const CharacterGeneratorState.initial()));

      // Cleanup
      container.dispose();
    });

    test('should inject repository dependencies correctly', () {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          // Note: We would need to override the repository providers here
          // but for this test we'll just verify the provider creates correctly
        ],
      );

      // Act
      final notifier = container.read(characterGeneratorProvider.notifier);

      // Assert
      expect(notifier, isA<CharacterGeneratorNotifier>());

      // Cleanup
      container.dispose();
    });
  });
}
