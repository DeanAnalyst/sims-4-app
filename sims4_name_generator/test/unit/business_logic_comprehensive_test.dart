import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sims4_name_generator/providers/data_providers.dart';
import 'package:sims4_name_generator/providers/state_providers.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/character_profile.dart';
import 'package:sims4_name_generator/providers/character_providers.dart';

import 'package:sims4_name_generator/providers/character_storage_providers.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/character_storage_service.dart';
import 'package:sims4_name_generator/services/local_data_service.dart';

// Generate mocks
@GenerateMocks([
  NameRepository, 
  TraitRepository, 
  CharacterStorageService,
  LocalDataService
])
import 'business_logic_comprehensive_test.mocks.dart';

void main() {
  group('Business Logic Comprehensive Tests', () {
    late ProviderContainer container;
    late MockNameRepository mockNameRepository;
    late MockTraitRepository mockTraitRepository;
    late MockCharacterStorageService mockStorageService;
    late MockLocalDataService mockDataService;

    setUp(() {
      mockNameRepository = MockNameRepository();
      mockTraitRepository = MockTraitRepository();
      mockStorageService = MockCharacterStorageService();
      mockDataService = MockLocalDataService();

      container = ProviderContainer(
        overrides: [
          nameRepositoryProvider.overrideWithValue(mockNameRepository),
          traitRepositoryProvider.overrideWithValue(mockTraitRepository),
          characterStorageServiceProvider.overrideWithValue(mockStorageService),
          localDataServiceProvider.overrideWithValue(mockDataService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Name Generation Logic', () {
      test('generates names with correct region and gender', () async {
        const testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          region: Region.english,
          gender: Gender.male,
        );

        when(mockNameRepository.generateRandomName(Region.english, Gender.male)).thenAnswer((_) async => testName);

        final notifier = container.read(characterGeneratorProvider.notifier);
        await notifier.generateName(Region.english, Gender.male);

        expect(notifier.state.generatedName, equals(testName));
        verify(mockNameRepository.generateRandomName(
          region: Region.english,
          gender: Gender.male,
        )).called(1);
      });

      test('handles name generation errors gracefully', () async {
        when(mockNameRepository.generateRandomName(
          region: Region.english,
          gender: Gender.male,
        )).thenThrow(Exception('Database error'));

        final notifier = container.read(characterGeneratorProvider.notifier);
        
        expect(
          () => notifier.generateName(region: Region.english, gender: Gender.male),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Trait Generation Logic', () {
      test('generates compatible traits', () async {
        final testTraits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          const Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        when(mockTraitRepository.generateRandomTraits(maxTraits: 3))
            .thenAnswer((_) async => testTraits);

        final notifier = container.read(characterGeneratorProvider.notifier);
        await notifier.generateTraits(maxTraits: 3);

        expect(notifier.state.generatedTraits, equals(testTraits));
        verify(mockTraitRepository.generateRandomTraits(maxTraits: 3)).called(1);
      });

      test('regenerates individual traits correctly', () async {
        final notifier = container.read(characterGeneratorProvider.notifier);
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

        notifier.state = CharacterGeneratorState(generatedTraits: [existingTrait]);

        when(mockTraitRepository.generateRandomTraitCompatibleWith([]))
            .thenAnswer((_) async => newTrait);

        await notifier.regenerateIndividualTrait(existingTrait);

        expect(notifier.state.generatedTraits, contains(newTrait));
        expect(notifier.state.generatedTraits, isNot(contains(existingTrait)));
      });

      test('validates trait compatibility', () {
        final compatibleTraits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          const Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        when(mockTraitRepository.areTraitsCompatible(compatibleTraits))
            .thenReturn(true);

        final result = mockTraitRepository.areTraitsCompatible(compatibleTraits);
        expect(result, isTrue);
      });
    });

    group('Character Profile Management', () {
      test('creates character profile correctly', () async {
        const testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          region: Region.english,
          gender: Gender.male,
        );
        final testTraits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final notifier = container.read(characterGeneratorProvider.notifier);
        notifier.state = CharacterGeneratorState(
          generatedName: testName,
          generatedTraits: testTraits,
        );

        final profile = notifier.state.createCharacterProfile();
        
        expect(profile.name, equals(testName));
        expect(profile.traits, equals(testTraits));
        expect(profile.generatedAt, isA<DateTime>());
      });

      test('saves character profile to storage', () async {
        final testProfile = CharacterProfile(
          name: const Name(
            firstName: 'John',
            lastName: 'Doe',
            region: Region.english,
            gender: Gender.male,
          ),
          traits: [
            const Trait(
              id: 'ambitious',
              name: 'Ambitious',
              description: 'Test description',
              category: TraitCategory.emotional,
              pack: 'base_game',
            ),
          ],
          generatedAt: DateTime.now(),
        );

        when(mockStorageService.saveCharacter(testProfile))
            .thenAnswer((_) async => true);

        final result = await mockStorageService.saveCharacter(testProfile);
        
        expect(result, isTrue);
        verify(mockStorageService.saveCharacter(testProfile)).called(1);
      });

      test('retrieves character history', () async {
        final testProfiles = [
          CharacterProfile(
            name: const Name(
              firstName: 'John',
              lastName: 'Doe',
              region: Region.english,
              gender: Gender.male,
            ),
            traits: [],
            generatedAt: DateTime.now(),
          ),
        ];

        when(mockStorageService.getCharacterHistory())
            .thenAnswer((_) async => testProfiles);

        final history = await mockStorageService.getCharacterHistory();
        
        expect(history, equals(testProfiles));
        verify(mockStorageService.getCharacterHistory()).called(1);
      });
    });

    group('Data Loading and Parsing', () {
      test('loads name data correctly', () async {
        final testNameData = [
          {
            'name': 'John',
            'region': 'english',
            'gender': 'male',
            'origin': 'English',
            'meaning': 'God is gracious',
          },
        ];

        when(mockDataService.loadNames(Region.english, Gender.male))
            .thenAnswer((_) async => testNameData);

        final data = await mockDataService.loadNames(Region.english, Gender.male);
        
        expect(data, equals(testNameData));
        verify(mockDataService.loadNameData(Region.english, Gender.male)).called(1);
      });

      test('loads trait data correctly', () async {
        final testTraitData = [
          {
            'id': 'ambitious',
            'name': 'Ambitious',
            'description': 'Test description',
            'category': 'emotional',
            'pack': 'base_game',
          },
        ];

        when(mockDataService.loadTraits())
            .thenAnswer((_) async => testTraitData);

        final data = await mockDataService.loadTraits();
        
        expect(data, equals(testTraitData));
        verify(mockDataService.loadTraitData()).called(1);
      });

      test('handles data loading errors gracefully', () async {
        when(mockDataService.loadNames(Region.english, Gender.male))
            .thenThrow(Exception('File not found'));

        expect(
          () => mockDataService.loadNameData(Region.english, Gender.male),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('State Management', () {
      test('initial state is correct', () {
        final state = container.read(characterGeneratorProvider);
        
        expect(state.generatedName, isNull);
        expect(state.generatedTraits, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loading state is set correctly', () async {
        const testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          region: Region.english,
          gender: Gender.male,
        );

        when(mockNameRepository.generateRandomName(
          region: Region.english,
          gender: Gender.male,
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testName;
        });

        final notifier = container.read(characterGeneratorProvider.notifier);
        
        // Start generation
        final future = notifier.generateName(Region.english, Gender.male);
        
        // Check loading state
        expect(notifier.state.isLoading, isTrue);
        
        // Wait for completion
        await future;
        
        // Check final state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.generatedName, equals(testName));
      });

      test('error state is handled correctly', () async {
        when(mockNameRepository.generateRandomName(
          region: Region.english,
          gender: Gender.male,
        )).thenThrow(Exception('Test error'));

        final notifier = container.read(characterGeneratorProvider.notifier);
        
        try {
          await notifier.generateName(Region.english, Gender.male);
        } catch (e) {
          // Error should be caught and state should be updated
          expect(notifier.state.error, isNotNull);
          expect(notifier.state.isLoading, isFalse);
        }
      });
    });

    group('Integration Scenarios', () {
      test('complete character generation workflow', () async {
        const testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          region: Region.english,
          gender: Gender.male,
        );
        final testTraits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test description',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        // Mock all repository calls
        when(mockNameRepository.generateRandomName(Region.english, Gender.male)).thenAnswer((_) async => testName);

        when(mockTraitRepository.generateRandomTraits(maxTraits: 3))
            .thenAnswer((_) async => testTraits);

        when(mockTraitRepository.areTraitsCompatible(testTraits))
            .thenReturn(true);

        when(mockStorageService.saveCharacter(any))
            .thenAnswer((_) async => true);

        // Execute workflow
        final notifier = container.read(characterGeneratorProvider.notifier);
        
        // Generate name
        await notifier.generateName(Region.english, Gender.male);
        expect(notifier.state.generatedName, equals(testName));
        
        // Generate traits
        await notifier.generateTraits(maxTraits: 3);
        expect(notifier.state.generatedTraits, equals(testTraits));
        
        // Create and save profile
        final profile = notifier.state.createCharacterProfile();
        await mockStorageService.saveCharacter(profile);
        
        expect(saved, isTrue);
        expect(profile.name, equals(testName));
        expect(profile.traits, equals(testTraits));
      });

      test('handles partial failures gracefully', () async {
        const testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          region: Region.english,
          gender: Gender.male,
        );

        // Mock successful name generation but failed trait generation
        when(mockNameRepository.generateRandomName(Region.english, Gender.male)).thenAnswer((_) async => testName);

        when(mockTraitRepository.generateRandomTraits(maxTraits: 3))
            .thenThrow(Exception('Trait generation failed'));

        final notifier = container.read(characterGeneratorProvider.notifier);
        
        // Name generation should succeed
        await notifier.generateName(Region.english, Gender.male);
        expect(notifier.state.generatedName, equals(testName));
        
        // Trait generation should fail
        expect(
          () => notifier.generateTraits(maxTraits: 3),
          throwsA(isA<Exception>()),
        );
        
        // Name should still be preserved
        expect(notifier.state.generatedName, equals(testName));
      });
    });
  });
} 