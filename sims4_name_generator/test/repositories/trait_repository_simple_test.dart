import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';

// Simple mock data service for testing
class MockDataService implements DataService {
  final List<Trait> mockTraits = [
    const Trait(
      id: 'ambitious',
      name: 'Ambitious',
      description: 'These Sims gain powerful Moodlets from career success.',
      category: TraitCategory.emotional,
      pack: 'base_game',
      conflictingTraits: ['lazy'],
    ),
    const Trait(
      id: 'lazy',
      name: 'Lazy',
      description: 'These Sims dislike physical activity.',
      category: TraitCategory.lifestyle,
      pack: 'base_game',
      conflictingTraits: ['ambitious', 'active'],
    ),
    const Trait(
      id: 'cheerful',
      name: 'Cheerful',
      description: 'These Sims tend to be Happier than other Sims.',
      category: TraitCategory.emotional,
      pack: 'base_game',
      conflictingTraits: ['gloomy'],
    ),
    const Trait(
      id: 'gloomy',
      name: 'Gloomy',
      description: 'These Sims tend to be Sadder than other Sims.',
      category: TraitCategory.emotional,
      pack: 'base_game',
      conflictingTraits: ['cheerful'],
    ),
    const Trait(
      id: 'active',
      name: 'Active',
      description: 'These Sims enjoy physical activity.',
      category: TraitCategory.lifestyle,
      pack: 'base_game',
      conflictingTraits: ['lazy'],
    ),
    const Trait(
      id: 'creative',
      name: 'Creative',
      description: 'These Sims enjoy creative activities.',
      category: TraitCategory.hobby,
      pack: 'base_game',
      conflictingTraits: [],
    ),
  ];

  @override
  Future<List<Trait>> loadTraits() async {
    return mockTraits;
  }

  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    // Not needed for trait repository tests
    return [];
  }

  @override
  Future<void> initializeData() async {
    // Not needed for trait repository tests
  }
}

void main() {
  group('TraitRepository Compatibility Logic Tests', () {
    late TraitRepository traitRepository;
    late List<Trait> mockTraits;

    setUp(() {
      final mockDataService = MockDataService();
      traitRepository = TraitRepository(mockDataService);
      mockTraits = mockDataService.mockTraits;
    });

    group('areTraitsCompatible', () {
      test('should return true for compatible traits', () {
        // Arrange
        final compatibleTraits = [
          mockTraits[0], // ambitious
          mockTraits[2], // cheerful
          mockTraits[5], // creative
        ];

        // Act
        final result = traitRepository.areTraitsCompatible(compatibleTraits);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for conflicting traits', () {
        // Arrange
        final conflictingTraits = [
          mockTraits[0], // ambitious
          mockTraits[1], // lazy (conflicts with ambitious)
        ];

        // Act
        final result = traitRepository.areTraitsCompatible(conflictingTraits);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for too many traits', () {
        // Arrange
        final tooManyTraits = [
          mockTraits[0], // ambitious
          mockTraits[2], // cheerful
          mockTraits[4], // active
          mockTraits[5], // creative (4 traits, max is 3)
        ];

        // Act
        final result = traitRepository.areTraitsCompatible(tooManyTraits);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for empty list', () {
        // Act
        final result = traitRepository.areTraitsCompatible([]);

        // Assert
        expect(result, isTrue);
      });

      test('should return true for single trait', () {
        // Arrange
        final singleTrait = [mockTraits[0]];

        // Act
        final result = traitRepository.areTraitsCompatible(singleTrait);

        // Assert
        expect(result, isTrue);
      });
    });

    group('generateRandomTraits', () {
      test('should generate up to maxTraits compatible traits', () async {
        // Act
        final result = await traitRepository.generateRandomTraits(maxTraits: 3);

        // Assert
        expect(result.length, lessThanOrEqualTo(3));
        expect(traitRepository.areTraitsCompatible(result), isTrue);
      });

      test(
        'should generate fewer traits if not enough compatible ones available',
        () async {
          // This test uses the existing mock data where some traits conflict
          // Act
          final result = await traitRepository.generateRandomTraits(
            maxTraits: 3,
          );

          // Assert
          expect(result.length, lessThanOrEqualTo(3));
          expect(traitRepository.areTraitsCompatible(result), isTrue);

          // Verify no conflicts exist in the result
          for (int i = 0; i < result.length; i++) {
            for (int j = i + 1; j < result.length; j++) {
              expect(
                result[i].conflictsWith(result[j]),
                isFalse,
                reason:
                    '${result[i].name} should not conflict with ${result[j].name}',
              );
            }
          }
        },
      );

      test('should throw ArgumentError for invalid maxTraits', () async {
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
    });

    group('validateTraitCombination', () {
      test('should return valid result for compatible traits', () async {
        // Arrange
        final compatibleTraits = [
          mockTraits[0], // ambitious
          mockTraits[2], // cheerful
          mockTraits[5], // creative
        ];

        // Act
        final result = await traitRepository.validateTraitCombination(
          compatibleTraits,
        );

        // Assert
        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
        expect(result.errorMessage, isNull);
      });

      test('should return invalid result for conflicting traits', () async {
        // Arrange
        final conflictingTraits = [
          mockTraits[0], // ambitious
          mockTraits[1], // lazy (conflicts with ambitious)
        ];

        // Act
        final result = await traitRepository.validateTraitCombination(
          conflictingTraits,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.conflicts.length, equals(1));
        expect(result.conflicts[0].trait1.id, equals('ambitious'));
        expect(result.conflicts[0].trait2.id, equals('lazy'));
        expect(result.errorMessage, contains('trait conflict'));
      });

      test('should return invalid result for too many traits', () async {
        // Arrange
        final tooManyTraits = [
          mockTraits[0], // ambitious
          mockTraits[2], // cheerful
          mockTraits[4], // active
          mockTraits[5], // creative (4 traits, max is 3)
        ];

        // Act
        final result = await traitRepository.validateTraitCombination(
          tooManyTraits,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Too many traits'));
      });
    });

    group('trait compatibility edge cases', () {
      test('should handle bidirectional conflicts correctly', () {
        // Test that ambitious conflicts with lazy and vice versa
        final ambitious = mockTraits[0];
        final lazy = mockTraits[1];

        expect(ambitious.conflictsWith(lazy), isTrue);
        expect(lazy.conflictsWith(ambitious), isTrue);
      });

      test('should handle multiple conflicts per trait', () {
        // lazy conflicts with both ambitious and active
        final lazy = mockTraits[1];
        final ambitious = mockTraits[0];
        final active = mockTraits[4];

        expect(lazy.conflictsWith(ambitious), isTrue);
        expect(lazy.conflictsWith(active), isTrue);
      });

      test('should handle traits with no conflicts', () {
        final creative = mockTraits[5];
        final ambitious = mockTraits[0];

        expect(creative.conflictsWith(ambitious), isFalse);
        expect(ambitious.conflictsWith(creative), isFalse);
      });
    });

    group('trait filtering and search', () {
      test('should filter traits by category', () async {
        // Act
        final emotionalTraits = await traitRepository.getTraitsByCategory(
          TraitCategory.emotional,
        );

        // Assert
        expect(
          emotionalTraits.length,
          equals(3),
        ); // ambitious, cheerful, gloomy
        expect(
          emotionalTraits.every(
            (trait) => trait.category == TraitCategory.emotional,
          ),
          isTrue,
        );
      });

      test('should filter traits by pack', () async {
        // Act
        final baseGameTraits = await traitRepository.getTraitsByPack(
          'base_game',
        );

        // Assert
        expect(
          baseGameTraits.length,
          equals(6),
        ); // All mock traits are base_game
        expect(
          baseGameTraits.every((trait) => trait.pack == 'base_game'),
          isTrue,
        );
      });

      test('should find trait by ID', () async {
        // Act
        final trait = await traitRepository.getTraitById('ambitious');

        // Assert
        expect(trait, isNotNull);
        expect(trait!.id, equals('ambitious'));
        expect(trait.name, equals('Ambitious'));
      });

      test('should return null for non-existent trait ID', () async {
        // Act
        final trait = await traitRepository.getTraitById('nonexistent');

        // Assert
        expect(trait, isNull);
      });
    });

    group('caching behavior', () {
      test('should cache traits after first load', () async {
        // Act
        await traitRepository.getAllTraits(); // First call
        expect(traitRepository.isTraitsCached, isTrue);

        // Second call should use cache
        final traits = await traitRepository.getAllTraits();
        expect(traits.length, equals(6));
      });

      test('should clear cache when requested', () async {
        // Arrange
        await traitRepository.getAllTraits(); // Load and cache
        expect(traitRepository.isTraitsCached, isTrue);

        // Act
        traitRepository.clearCache();

        // Assert
        expect(traitRepository.isTraitsCached, isFalse);
      });
    });
  });
}
