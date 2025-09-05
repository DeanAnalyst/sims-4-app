import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/providers/character_providers.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/character_storage_service.dart';

// Generate mocks
@GenerateMocks([NameRepository, TraitRepository, CharacterStorageService])
import 'character_providers_comprehensive_test.mocks.dart';

void main() {
  group('CharacterGeneratorState', () {
    test('initial state is correct', () {
      const state = CharacterGeneratorState.initial();

      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, isNull);
    });

    test('loadingName state is correct', () {
      const state = CharacterGeneratorState.loadingName();

      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isTrue);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, isNull);
    });

    test('loadingTraits state is correct', () {
      const state = CharacterGeneratorState.loadingTraits();

      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isTrue);
      expect(state.error, isNull);
    });

    test('error state is correct', () {
      const errorMessage = 'Test error';
      const state = CharacterGeneratorState.error(errorMessage);

      expect(state.generatedName, isNull);
      expect(state.generatedTraits, isEmpty);
      expect(state.isGeneratingName, isFalse);
      expect(state.isGeneratingTraits, isFalse);
      expect(state.error, equals(errorMessage));
    });

    test('copyWith updates state correctly', () {
      const initialState = CharacterGeneratorState.initial();
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      final newState = initialState.copyWith(
        generatedName: testName,
        generatedTraits: testTraits,
        isGeneratingName: true,
        isGeneratingTraits: false,
        error: null,
      );

      expect(newState.generatedName, equals(testName));
      expect(newState.generatedTraits, equals(testTraits));
      expect(newState.isGeneratingName, isTrue);
      expect(newState.isGeneratingTraits, isFalse);
      expect(newState.error, isNull);
    });

    test('copyWith clearName clears name', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const initialState = CharacterGeneratorState(generatedName: testName);

      final newState = initialState.copyWith(clearName: true);

      expect(newState.generatedName, isNull);
    });

    test('copyWith clearTraits clears traits', () {
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];
      const initialState = CharacterGeneratorState(generatedTraits: testTraits);

      final newState = initialState.copyWith(clearTraits: true);

      expect(newState.generatedTraits, isEmpty);
    });

    test('copyWith clearError clears error', () {
      const initialState = CharacterGeneratorState(error: 'Test error');

      final newState = initialState.copyWith(clearError: true);

      expect(newState.error, isNull);
    });

    test('isLoading returns true when generating name', () {
      const state = CharacterGeneratorState(isGeneratingName: true);
      expect(state.isLoading, isTrue);
    });

    test('isLoading returns true when generating traits', () {
      const state = CharacterGeneratorState(isGeneratingTraits: true);
      expect(state.isLoading, isTrue);
    });

    test('isLoading returns false when not generating', () {
      const state = CharacterGeneratorState.initial();
      expect(state.isLoading, isFalse);
    });

    test('hasContent returns true when name is present', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const state = CharacterGeneratorState(generatedName: testName);
      expect(state.hasContent, isTrue);
    });

    test('hasContent returns true when traits are present', () {
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];
      const state = CharacterGeneratorState(generatedTraits: testTraits);
      expect(state.hasContent, isTrue);
    });

    test('hasContent returns false when no content', () {
      const state = CharacterGeneratorState.initial();
      expect(state.hasContent, isFalse);
    });

    test(
      'currentCharacterProfile returns profile when both name and traits present',
      () {
        const testName = Name(
          firstName: 'John',
          lastName: 'Smith',
          gender: Gender.male,
          region: Region.english,
        );
        const testTraits = [
          Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];
        const state = CharacterGeneratorState(
          generatedName: testName,
          generatedTraits: testTraits,
        );

        final profile = state.currentCharacterProfile;
        expect(profile, isNotNull);
        expect(profile!.name, equals(testName));
        expect(profile.traits, equals(testTraits));
      },
    );

    test('currentCharacterProfile returns null when name missing', () {
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];
      const state = CharacterGeneratorState(generatedTraits: testTraits);

      final profile = state.currentCharacterProfile;
      expect(profile, isNull);
    });

    test('currentCharacterProfile returns null when traits missing', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const state = CharacterGeneratorState(generatedName: testName);

      final profile = state.currentCharacterProfile;
      expect(profile, isNull);
    });
  });

  group('CharacterGeneratorNotifier', () {
    late MockNameRepository mockNameRepository;
    late MockTraitRepository mockTraitRepository;
    late MockCharacterStorageService mockStorageService;
    late CharacterGeneratorNotifier notifier;
    late ProviderContainer container;

    setUp(() {
      mockNameRepository = MockNameRepository();
      mockTraitRepository = MockTraitRepository();
      mockStorageService = MockCharacterStorageService();
      notifier = CharacterGeneratorNotifier(
        mockNameRepository,
        mockTraitRepository,
        mockStorageService,
      );
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      expect(notifier.state, const CharacterGeneratorState.initial());
    });

    test('generateName updates state correctly on success', () async {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      when(
        mockNameRepository.generateRandomName(
          Region.english,
          Gender.male,
          avoidDuplicates: true,
        ),
      ).thenAnswer((_) async => testName);

      await notifier.generateName(Region.english, Gender.male);

      expect(notifier.state.generatedName, equals(testName));
      expect(notifier.state.isGeneratingName, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('generateName updates state correctly on error', () async {
      const errorMessage = 'Repository error';
      when(
        mockNameRepository.generateRandomName(
          Region.english,
          Gender.male,
          avoidDuplicates: true,
        ),
      ).thenThrow(Exception(errorMessage));

      await notifier.generateName(Region.english, Gender.male);

      expect(notifier.state.generatedName, isNull);
      expect(notifier.state.isGeneratingName, isFalse);
      expect(notifier.state.error, contains('Failed to generate name'));
      expect(notifier.state.error, contains(errorMessage));
    });

    test('generateTraits updates state correctly on success', () async {
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      when(
        mockTraitRepository.generateRandomTraits(
          maxTraits: 3,
          avoidDuplicates: true,
          preferredCategories: null,
          preferredPacks: null,
        ),
      ).thenAnswer((_) async => testTraits);

      await notifier.generateTraits();

      expect(notifier.state.generatedTraits, equals(testTraits));
      expect(notifier.state.isGeneratingTraits, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('generateTraits updates state correctly on error', () async {
      const errorMessage = 'Repository error';
      when(
        mockTraitRepository.generateRandomTraits(
          maxTraits: 3,
          avoidDuplicates: true,
          preferredCategories: null,
          preferredPacks: null,
        ),
      ).thenThrow(Exception(errorMessage));

      await notifier.generateTraits();

      expect(notifier.state.generatedTraits, isEmpty);
      expect(notifier.state.isGeneratingTraits, isFalse);
      expect(notifier.state.error, contains('Failed to generate traits'));
      expect(notifier.state.error, contains(errorMessage));
    });

    test('generateCompleteCharacter generates both name and traits', () async {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      when(
        mockNameRepository.generateRandomName(
          Region.english,
          Gender.male,
          avoidDuplicates: true,
        ),
      ).thenAnswer((_) async => testName);

      when(
        mockTraitRepository.generateRandomTraits(
          maxTraits: 3,
          avoidDuplicates: true,
          preferredCategories: null,
          preferredPacks: null,
        ),
      ).thenAnswer((_) async => testTraits);

      when(mockStorageService.addToHistory(any)).thenAnswer((_) async {});

      await notifier.generateCompleteCharacter(Region.english, Gender.male);

      expect(notifier.state.generatedName, equals(testName));
      expect(notifier.state.generatedTraits, equals(testTraits));
      expect(notifier.state.error, isNull);
      verify(mockStorageService.addToHistory(any)).called(1);
    });

    test('clearGeneration resets to initial state', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      notifier.state = CharacterGeneratorState(
        generatedName: testName,
        generatedTraits: testTraits,
        error: 'Test error',
      );

      notifier.clearGeneration();

      expect(notifier.state, const CharacterGeneratorState.initial());
    });

    test('clearName clears only name', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      notifier.state = CharacterGeneratorState(
        generatedName: testName,
        generatedTraits: testTraits,
      );

      notifier.clearName();

      expect(notifier.state.generatedName, isNull);
      expect(notifier.state.generatedTraits, equals(testTraits));
    });

    test('clearTraits clears only traits', () {
      const testName = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );
      const testTraits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Test description',
          category: TraitCategory.emotional,
          pack: 'base_game',
        ),
      ];

      notifier.state = CharacterGeneratorState(
        generatedName: testName,
        generatedTraits: testTraits,
      );

      notifier.clearTraits();

      expect(notifier.state.generatedName, equals(testName));
      expect(notifier.state.generatedTraits, isEmpty);
    });

    test('clearError clears only error', () {
      notifier.state = const CharacterGeneratorState(error: 'Test error');

      notifier.clearError();

      expect(notifier.state.error, isNull);
    });

    test('regenerateIndividualTrait replaces specific trait', () async {
      const existingTrait = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'Test description',
        category: TraitCategory.emotional,
        pack: 'base_game',
      );
      const newTrait = Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'New description',
        category: TraitCategory.emotional,
        pack: 'base_game',
      );

      notifier.state = CharacterGeneratorState(
        generatedTraits: [existingTrait],
      );

      // Mock the repository call with an empty list (since we remove the existing trait)
      when(
        mockTraitRepository.generateRandomTraitCompatibleWith([]),
      ).thenAnswer((_) async => newTrait);

      await notifier.regenerateIndividualTrait(existingTrait);

      expect(notifier.state.generatedTraits, contains(newTrait));
      expect(notifier.state.generatedTraits, isNot(contains(existingTrait)));
      expect(notifier.state.isGeneratingTraits, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('regenerateIndividualTrait handles errors', () async {
      const existingTrait = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'Test description',
        category: TraitCategory.emotional,
        pack: 'base_game',
      );

      notifier.state = CharacterGeneratorState(
        generatedTraits: [existingTrait],
      );

      when(
        mockTraitRepository.generateRandomTraitCompatibleWith([existingTrait]),
      ).thenThrow(Exception('Repository error'));

      await notifier.regenerateIndividualTrait(existingTrait);

      expect(notifier.state.generatedTraits, equals([existingTrait]));
      expect(notifier.state.isGeneratingTraits, isFalse);
      expect(notifier.state.error, contains('Failed to regenerate trait'));
    });
  });
}
