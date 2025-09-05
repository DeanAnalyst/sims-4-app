import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';

// Manual mock for DataService
class MockDataService implements DataService {
  List<Trait>? _mockTraits;
  Exception? _loadTraitsException;
  bool _shouldThrowException = false;

  void setMockTraits(List<Trait> traits) {
    _mockTraits = traits;
  }

  void setLoadTraitsException(Exception exception) {
    _loadTraitsException = exception;
    _shouldThrowException = true;
  }

  void reset() {
    _mockTraits = null;
    _loadTraitsException = null;
    _shouldThrowException = false;
  }

  @override
  Future<List<Trait>> loadTraits() async {
    if (_shouldThrowException && _loadTraitsException != null) {
      throw _loadTraitsException!;
    }
    return _mockTraits ?? [];
  }

  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    return [];
  }

  @override
  Future<void> initializeData() async {}
}

void main() {
  group('TraitRepository with Mock', () {
    late MockDataService mockDataService;
    late TraitRepository traitRepository;
    late List<Trait> mockTraits;

    setUp(() {
      mockDataService = MockDataService();
      traitRepository = TraitRepository(mockDataService);

      // Create comprehensive mock traits for testing
      mockTraits = [
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
        const Trait(
          id: 'outgoing',
          name: 'Outgoing',
          description: 'These Sims enjoy social interactions.',
          category: TraitCategory.social,
          pack: 'base_game',
          conflictingTraits: ['loner'],
        ),
        const Trait(
          id: 'loner',
          name: 'Loner',
          description: 'These Sims prefer solitude.',
          category: TraitCategory.social,
          pack: 'base_game',
          conflictingTraits: ['outgoing'],
        ),
        const Trait(
          id: 'bookworm',
          name: 'Bookworm',
          description: 'These Sims love to read.',
          category: TraitCategory.hobby,
          pack: 'expansion_pack_1',
          conflictingTraits: [],
        ),
      ];

      mockDataService.setMockTraits(mockTraits);
    });

    tearDown(() {
      mockDataService.reset();
    });

    group('getAllTraits', () {
      test('should return traits from data service on first call', () async {
        // Act
        final result = await traitRepository.getAllTraits();

        // Assert
        expect(result, equals(mockTraits));
        expect(result.length, equals(9));
      });

      test('should return cached traits on subsequent calls', () async {
        // Act
        await traitRepository.getAllTraits(); // First call
        final result = await traitRepository.getAllTraits(); // Second call

        // Assert
        expect(result, equals(mockTraits));
        expect(traitRepository.isTraitsCached, isTrue);
      });

      test('should throw exception when data service fails', () async {
        // Arrange
        mockDataService.setLoadTraitsException(Exception('Load failed'));

        // Act & Assert
        expect(
          () => traitRepository.getAllTraits(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load traits'),
            ),
          ),
        );
      });
    });

    group('trait compatibility validation', () {
      test('should validate compatible trait combinations correctly', () async {
        // Arrange - Select traits that don't conflict
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

      test('should detect single conflict correctly', () async {
        // Arrange - ambitious conflicts with lazy
        final conflictingTraits = [
          mockTraits[0], // ambitious
          mockTraits[1], // lazy
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
        expect(result.errorMessage, contains('1 trait conflict'));
      });

      test('should detect multiple conflicts correctly', () async {
        // Arrange - Create a combination with multiple conflicts
        final multipleConflictTraits = [
          mockTraits[0], // ambitious (conflicts with lazy)
          mockTraits[1], // lazy (conflicts with ambitious and active)
          mockTraits[4], // active (conflicts with lazy)
        ];

        // Act
        final result = await traitRepository.validateTraitCombination(
          multipleConflictTraits,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(
          result.conflicts.length,
          equals(2),
        ); // ambitious-lazy and lazy-active
        expect(result.errorMessage, contains('2 trait conflict'));
      });

      test('should reject combinations with too many traits', () async {
        // Arrange - 4 compatible traits (exceeds limit of 3)
        final tooManyTraits = [
          mockTraits[0], // ambitious
          mockTraits[2], // cheerful
          mockTraits[5], // creative
          mockTraits[8], // bookworm
        ];

        // Act
        final result = await traitRepository.validateTraitCombination(
          tooManyTraits,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(
          result.errorMessage,
          contains('Too many traits: 4. Maximum allowed: 3'),
        );
      });
    });

    group('random trait generation with conflict checking', () {
      test('should generate valid trait combinations', () async {
        // Act
        final result = await traitRepository.generateRandomTraits(maxTraits: 3);

        // Assert
        expect(result.length, lessThanOrEqualTo(3));
        expect(traitRepository.areTraitsCompatible(result), isTrue);

        // Verify no duplicates
        final ids = result.map((t) => t.id).toSet();
        expect(ids.length, equals(result.length));
      });

      test('should respect maxTraits parameter', () async {
        // Act
        final result1 = await traitRepository.generateRandomTraits(
          maxTraits: 1,
        );
        final result2 = await traitRepository.generateRandomTraits(
          maxTraits: 2,
        );

        // Assert
        expect(result1.length, lessThanOrEqualTo(1));
        expect(result2.length, lessThanOrEqualTo(2));
      });

      test(
        'should generate fewer traits when conflicts prevent reaching maxTraits',
        () async {
          // Arrange - Create a scenario with many conflicts
          final highConflictTraits = [
            const Trait(
              id: 'trait1',
              name: 'Trait 1',
              description: 'Description 1',
              category: TraitCategory.emotional,
              pack: 'base_game',
              conflictingTraits: ['trait2', 'trait3', 'trait4'],
            ),
            const Trait(
              id: 'trait2',
              name: 'Trait 2',
              description: 'Description 2',
              category: TraitCategory.emotional,
              pack: 'base_game',
              conflictingTraits: ['trait1', 'trait3', 'trait4'],
            ),
            const Trait(
              id: 'trait3',
              name: 'Trait 3',
              description: 'Description 3',
              category: TraitCategory.emotional,
              pack: 'base_game',
              conflictingTraits: ['trait1', 'trait2', 'trait4'],
            ),
            const Trait(
              id: 'trait4',
              name: 'Trait 4',
              description: 'Description 4',
              category: TraitCategory.emotional,
              pack: 'base_game',
              conflictingTraits: ['trait1', 'trait2', 'trait3'],
            ),
          ];

          mockDataService.setMockTraits(highConflictTraits);

          // Act
          final result = await traitRepository.generateRandomTraits(
            maxTraits: 3,
          );

          // Assert
          expect(
            result.length,
            equals(1),
          ); // Only one trait can be selected due to conflicts
          expect(traitRepository.areTraitsCompatible(result), isTrue);
        },
      );

      test('should throw ArgumentError for invalid maxTraits values', () async {
        // Act & Assert
        expect(
          () => traitRepository.generateRandomTraits(maxTraits: 0),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'message',
              contains('maxTraits must be positive'),
            ),
          ),
        );

        expect(
          () => traitRepository.generateRandomTraits(maxTraits: 4),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'message',
              contains('maxTraits cannot exceed 3'),
            ),
          ),
        );
      });

      test('should throw exception when no traits available', () async {
        // Arrange
        mockDataService.setMockTraits([]);

        // Act & Assert
        expect(
          () => traitRepository.generateRandomTraits(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No traits available'),
            ),
          ),
        );
      });
    });

    group('trait filtering and search functionality', () {
      test('should filter traits by category correctly', () async {
        // Act
        final emotionalTraits = await traitRepository.getTraitsByCategory(
          TraitCategory.emotional,
        );
        final lifestyleTraits = await traitRepository.getTraitsByCategory(
          TraitCategory.lifestyle,
        );
        final hobbyTraits = await traitRepository.getTraitsByCategory(
          TraitCategory.hobby,
        );

        // Assert
        expect(
          emotionalTraits.length,
          equals(3),
        ); // ambitious, cheerful, gloomy
        expect(lifestyleTraits.length, equals(2)); // lazy, active
        expect(hobbyTraits.length, equals(2)); // creative, bookworm

        expect(
          emotionalTraits.every((t) => t.category == TraitCategory.emotional),
          isTrue,
        );
        expect(
          lifestyleTraits.every((t) => t.category == TraitCategory.lifestyle),
          isTrue,
        );
        expect(
          hobbyTraits.every((t) => t.category == TraitCategory.hobby),
          isTrue,
        );
      });

      test('should filter traits by pack correctly', () async {
        // Act
        final baseGameTraits = await traitRepository.getTraitsByPack(
          'base_game',
        );
        final expansionTraits = await traitRepository.getTraitsByPack(
          'expansion_pack_1',
        );

        // Assert
        expect(baseGameTraits.length, equals(8));
        expect(expansionTraits.length, equals(1)); // bookworm

        expect(baseGameTraits.every((t) => t.pack == 'base_game'), isTrue);
        expect(
          expansionTraits.every((t) => t.pack == 'expansion_pack_1'),
          isTrue,
        );
      });

      test('should find compatible traits for existing selection', () async {
        // Arrange
        final existingTraits = [mockTraits[0]]; // ambitious

        // Act
        final compatibleTraits = await traitRepository.getCompatibleTraits(
          existingTraits,
        );

        // Assert
        expect(compatibleTraits, isNotEmpty);
        expect(
          compatibleTraits.any((t) => t.id == 'lazy'),
          isFalse,
        ); // lazy conflicts with ambitious
        expect(
          compatibleTraits.any((t) => t.id == 'ambitious'),
          isFalse,
        ); // ambitious already selected
        expect(
          compatibleTraits.any((t) => t.id == 'cheerful'),
          isTrue,
        ); // cheerful is compatible
      });

      test('should find conflicting traits correctly', () async {
        // Arrange
        final lazyTrait = mockTraits[1]; // lazy

        // Act
        final conflictingTraits = await traitRepository.getConflictingTraits(
          lazyTrait,
        );

        // Assert
        expect(conflictingTraits.length, equals(2)); // ambitious and active
        expect(conflictingTraits.any((t) => t.id == 'ambitious'), isTrue);
        expect(conflictingTraits.any((t) => t.id == 'active'), isTrue);
      });

      test('should search traits by name and description', () async {
        // Act
        final searchResults1 = await traitRepository.searchTraits('ambitious');
        final searchResults2 = await traitRepository.searchTraits('physical');
        final searchResults3 = await traitRepository.searchTraits('');

        // Assert
        expect(searchResults1.length, equals(1));
        expect(searchResults1[0].id, equals('ambitious'));

        expect(
          searchResults2.length,
          equals(2),
        ); // lazy and active mention "physical"

        expect(
          searchResults3.length,
          equals(mockTraits.length),
        ); // empty query returns all
      });
    });

    group('trait statistics and utility methods', () {
      test('should provide accurate trait statistics', () async {
        // Act
        final stats = await traitRepository.getTraitStatistics();

        // Assert
        expect(stats['totalTraits'], equals(9));
        expect(stats['traitsByCategory'], isA<Map<String, int>>());
        expect(stats['traitsByPack'], isA<Map<String, int>>());
        expect(stats['averageConflictsPerTrait'], isA<double>());

        final categoryStats = stats['traitsByCategory'] as Map<String, int>;
        expect(categoryStats['emotional'], equals(3));
        expect(categoryStats['lifestyle'], equals(2));
        expect(categoryStats['hobby'], equals(2));
        expect(categoryStats['social'], equals(2));
      });

      test('should return available categories and packs', () async {
        // Act
        final categories = await traitRepository.getAvailableCategories();
        final packs = await traitRepository.getAvailablePacks();

        // Assert
        expect(categories, contains(TraitCategory.emotional));
        expect(categories, contains(TraitCategory.lifestyle));
        expect(categories, contains(TraitCategory.hobby));
        expect(categories, contains(TraitCategory.social));

        expect(packs, contains('base_game'));
        expect(packs, contains('expansion_pack_1'));
      });

      test('should handle cache operations correctly', () async {
        // Arrange
        expect(traitRepository.isTraitsCached, isFalse);

        // Act
        await traitRepository.getAllTraits();
        expect(traitRepository.isTraitsCached, isTrue);

        traitRepository.clearCache();
        expect(traitRepository.isTraitsCached, isFalse);

        // Assert
        final count = await traitRepository.getTraitCount();
        expect(count, equals(9));
      });
    });

    group('category-specific trait generation', () {
      test('should generate traits from specific category', () async {
        // Act
        final emotionalTraits = await traitRepository
            .generateRandomTraitsByCategory(
              TraitCategory.emotional,
              maxTraits: 2,
            );

        // Assert
        expect(emotionalTraits.length, lessThanOrEqualTo(2));
        expect(
          emotionalTraits.every((t) => t.category == TraitCategory.emotional),
          isTrue,
        );
        expect(traitRepository.areTraitsCompatible(emotionalTraits), isTrue);
      });

      test('should handle category with conflicting traits', () async {
        // Act - emotional category has cheerful/gloomy conflict
        final emotionalTraits = await traitRepository
            .generateRandomTraitsByCategory(
              TraitCategory.emotional,
              maxTraits: 3,
            );

        // Assert
        expect(
          emotionalTraits.length,
          lessThanOrEqualTo(2),
        ); // Can't have all 3 due to conflicts
        expect(traitRepository.areTraitsCompatible(emotionalTraits), isTrue);

        // Should not have both cheerful and gloomy
        final hasCheerful = emotionalTraits.any((t) => t.id == 'cheerful');
        final hasGloomy = emotionalTraits.any((t) => t.id == 'gloomy');
        expect(hasCheerful && hasGloomy, isFalse);
      });

      test('should throw exception for empty category', () async {
        // Act & Assert
        expect(
          () => traitRepository.generateRandomTraitsByCategory(
            TraitCategory.toddler,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No traits available for category'),
            ),
          ),
        );
      });
    });
  });
}
