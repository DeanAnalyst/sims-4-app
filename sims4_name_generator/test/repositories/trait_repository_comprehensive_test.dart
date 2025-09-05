import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/enums.dart';

import 'trait_repository_comprehensive_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  group('TraitRepository Comprehensive Tests', () {
    late MockDataService mockDataService;
    late TraitRepository traitRepository;

    final sampleTraits = [
      Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'These Sims gain powerful Moodlets from career success.',
        category: TraitCategory.emotional,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      ),
      Trait(
        id: 'lazy',
        name: 'Lazy',
        description: 'These Sims dislike physical activity.',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['ambitious', 'active'],
      ),
      Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'These Sims tend to be Happier than other Sims.',
        category: TraitCategory.emotional,
        pack: 'base_game',
      ),
      Trait(
        id: 'creative',
        name: 'Creative',
        description:
            'These Sims tend to be inspired and enjoy creative activities.',
        category: TraitCategory.hobby,
        pack: 'base_game',
      ),
      Trait(
        id: 'active',
        name: 'Active',
        description: 'These Sims enjoy physical activities.',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      ),
    ];

    setUp(() {
      mockDataService = MockDataService();
      traitRepository = TraitRepository(mockDataService);
    });

    group('getAllTraits', () {
      test('should return traits from data service', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getAllTraits();

        // Assert
        expect(result, equals(sampleTraits));
        verify(mockDataService.loadTraits()).called(1);
      });

      test('should cache traits after first load', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        await traitRepository.getAllTraits();
        await traitRepository.getAllTraits();

        // Assert
        verify(mockDataService.loadTraits()).called(1);
      });

      test('should throw exception when data service fails', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenThrow(Exception('Data service error'));

        // Act & Assert
        expect(() => traitRepository.getAllTraits(), throwsA(isA<Exception>()));
      });
    });

    group('getTraitsByCategory', () {
      test('should return traits filtered by category', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getTraitsByCategory(
          TraitCategory.emotional,
        );

        // Assert
        expect(result, hasLength(2));
        expect(
          result.every((t) => t.category == TraitCategory.emotional),
          isTrue,
        );
        expect(result.map((t) => t.id), containsAll(['ambitious', 'cheerful']));
      });

      test('should return empty list for category with no traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getTraitsByCategory(
          TraitCategory.toddler,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getTraitsByPack', () {
      test('should return traits filtered by pack', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getTraitsByPack('base_game');

        // Assert
        expect(result, hasLength(5));
        expect(result.every((t) => t.pack == 'base_game'), isTrue);
      });

      test('should return empty list for pack with no traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getTraitsByPack(
          'nonexistent_pack',
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('areTraitsCompatible', () {
      test('should return true for compatible traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final compatibleTraits = [
          sampleTraits[0], // ambitious
          sampleTraits[2], // cheerful
          sampleTraits[3], // creative
        ];

        // Act
        final result = await traitRepository.areTraitsCompatible(
          compatibleTraits,
        );

        // Assert
        expect(result, isTrue);
      });

      test('should return false for conflicting traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final conflictingTraits = [
          sampleTraits[0], // ambitious
          sampleTraits[1], // lazy (conflicts with ambitious)
        ];

        // Act
        final result = await traitRepository.areTraitsCompatible(
          conflictingTraits,
        );

        // Assert
        expect(result, isFalse);
      });

      test('should return false for more than max traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final tooManyTraits = [
          sampleTraits[0], // ambitious
          sampleTraits[2], // cheerful
          sampleTraits[3], // creative
          sampleTraits[4], // active
        ];

        // Act
        final result = await traitRepository.areTraitsCompatible(tooManyTraits);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for empty list', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.areTraitsCompatible([]);

        // Assert
        expect(result, isTrue);
      });
    });

    group('generateRandomTraits', () {
      test('should generate valid trait combinations', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.generateRandomTraits();

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, lessThanOrEqualTo(3));
        expect(await traitRepository.areTraitsCompatible(result), isTrue);
      });

      test('should respect maxTraits parameter', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.generateRandomTraits(maxTraits: 2);

        // Assert
        expect(result.length, lessThanOrEqualTo(2));
      });

      test('should throw ArgumentError for invalid maxTraits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act & Assert
        expect(
          () => traitRepository.generateRandomTraits(maxTraits: 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => traitRepository.generateRandomTraits(maxTraits: 4),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should avoid duplicates when requested', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act - Generate multiple trait sets
        final results = <List<Trait>>[];
        for (int i = 0; i < 5; i++) {
          final traits = await traitRepository.generateRandomTraits(
            avoidDuplicates: true,
          );
          results.add(traits);
        }

        // Assert - Should have some variation
        final uniqueResults = results
            .map((list) => list.map((t) => t.id).toSet())
            .toSet();
        expect(uniqueResults.length, greaterThan(1));
      });

      test('should handle case when no compatible traits available', () async {
        // Arrange - Create traits that all conflict with each other
        final conflictingTraits = [
          Trait(
            id: 'trait1',
            name: 'Trait 1',
            description: 'Test trait',
            category: TraitCategory.emotional,
            pack: 'base_game',
            conflictingTraits: ['trait2', 'trait3'],
          ),
          Trait(
            id: 'trait2',
            name: 'Trait 2',
            description: 'Test trait',
            category: TraitCategory.emotional,
            pack: 'base_game',
            conflictingTraits: ['trait1', 'trait3'],
          ),
          Trait(
            id: 'trait3',
            name: 'Trait 3',
            description: 'Test trait',
            category: TraitCategory.emotional,
            pack: 'base_game',
            conflictingTraits: ['trait1', 'trait2'],
          ),
        ];

        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => conflictingTraits);

        // Act
        final result = await traitRepository.generateRandomTraits(maxTraits: 3);

        // Assert - Should still return at least one trait
        expect(result, isNotEmpty);
        expect(result.length, lessThanOrEqualTo(1));
      });
    });

    group('findTraitById', () {
      test('should return trait with matching ID', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.findTraitById('ambitious');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('ambitious'));
        expect(result.name, equals('Ambitious'));
      });

      test('should return null for non-existent ID', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.findTraitById('nonexistent');

        // Assert
        expect(result, isNull);
      });
    });

    group('searchTraits', () {
      test('should find traits by name', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.searchTraits('ambitious');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].name.toLowerCase(), contains('ambitious'));
      });

      test('should find traits by description', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.searchTraits('physical');

        // Assert
        expect(result, hasLength(2)); // lazy and active mention physical
        expect(result.map((t) => t.id), containsAll(['lazy', 'active']));
      });

      test('should return empty list for no matches', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.searchTraits('nonexistent');

        // Assert
        expect(result, isEmpty);
      });

      test('should be case insensitive', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.searchTraits('AMBITIOUS');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('ambitious'));
      });
    });

    group('getCompatibleTraits', () {
      test('should return traits compatible with existing selection', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final existingTraits = [sampleTraits[0]]; // ambitious

        // Act
        final result = await traitRepository.getCompatibleTraits(
          existingTraits,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(
          result.map((t) => t.id),
          isNot(contains('lazy')),
        ); // lazy conflicts with ambitious
        expect(
          result.map((t) => t.id),
          contains('cheerful'),
        ); // cheerful is compatible
      });

      test('should exclude already selected traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final existingTraits = [
          sampleTraits[0],
          sampleTraits[2],
        ]; // ambitious, cheerful

        // Act
        final result = await traitRepository.getCompatibleTraits(
          existingTraits,
        );

        // Assert
        expect(result.map((t) => t.id), isNot(contains('ambitious')));
        expect(result.map((t) => t.id), isNot(contains('cheerful')));
      });
    });

    group('getConflictingTraits', () {
      test('should return traits that conflict with given trait', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final ambitiousTrait = sampleTraits[0]; // ambitious

        // Act
        final result = await traitRepository.getConflictingTraits(
          ambitiousTrait,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('lazy'));
      });

      test('should return empty list for trait with no conflicts', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        final cheerfulTrait = sampleTraits[2]; // cheerful

        // Act
        final result = await traitRepository.getConflictingTraits(
          cheerfulTrait,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getTraitStatistics', () {
      test('should return correct statistics', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getTraitStatistics();

        // Assert
        expect(result['totalTraits'], equals(5));
        expect(result['categoryCounts'][TraitCategory.emotional], equals(2));
        expect(result['categoryCounts'][TraitCategory.lifestyle], equals(2));
        expect(result['categoryCounts'][TraitCategory.hobby], equals(1));
        expect(result['packCounts']['base_game'], equals(5));
      });
    });

    group('getAvailableCategories', () {
      test('should return all categories present in traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getAvailableCategories();

        // Assert
        expect(result, hasLength(3));
        expect(
          result,
          containsAll([
            TraitCategory.emotional,
            TraitCategory.lifestyle,
            TraitCategory.hobby,
          ]),
        );
      });
    });

    group('getAvailablePacks', () {
      test('should return all packs present in traits', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final result = await traitRepository.getAvailablePacks();

        // Assert
        expect(result, hasLength(1));
        expect(result, contains('base_game'));
      });
    });

    group('weighted selection', () {
      test('should set trait weights', () {
        // Arrange
        const traitId = 'ambitious';
        const weight = 2.5;

        // Act
        traitRepository.setTraitWeight(traitId, weight);

        // Assert - No direct way to verify, but should not throw
        expect(
          () => traitRepository.setTraitWeight(traitId, weight),
          returnsNormally,
        );
      });

      test('should set category weights', () {
        // Arrange
        const category = TraitCategory.emotional;
        const weight = 1.5;

        // Act
        traitRepository.setCategoryWeight(category, weight);

        // Assert - No direct way to verify, but should not throw
        expect(
          () => traitRepository.setCategoryWeight(category, weight),
          returnsNormally,
        );
      });

      test('should set pack weights', () {
        // Arrange
        const pack = 'base_game';
        const weight = 1.8;

        // Act
        traitRepository.setPackWeight(pack, weight);

        // Assert - No direct way to verify, but should not throw
        expect(
          () => traitRepository.setPackWeight(pack, weight),
          returnsNormally,
        );
      });
    });

    group('cache management', () {
      test('should clear cache and reload data', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        await traitRepository.getAllTraits(); // Load and cache
        traitRepository.clearCache(); // Clear cache
        await traitRepository.getAllTraits(); // Load again

        // Assert
        verify(mockDataService.loadTraits()).called(2);
      });
    });

    group('generation history', () {
      test('should track generation history', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        final traits1 = await traitRepository.generateRandomTraits();
        final traits2 = await traitRepository.generateRandomTraits();
        final history = traitRepository.getGenerationHistory();

        // Assert
        expect(history, hasLength(2));
        expect(history[0], equals(traits1));
        expect(history[1], equals(traits2));
      });

      test('should clear generation history', () async {
        // Arrange
        when(
          mockDataService.loadTraits(),
        ).thenAnswer((_) async => sampleTraits);

        // Act
        await traitRepository.generateRandomTraits();
        traitRepository.clearGenerationHistory();
        final history = traitRepository.getGenerationHistory();

        // Assert
        expect(history, isEmpty);
      });
    });
  });
}
