import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/providers/providers.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/services/character_storage_service.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/enums.dart';

import 'providers_comprehensive_test.mocks.dart';

@GenerateMocks([
  DataService,
  NameRepository,
  TraitRepository,
  CharacterStorageService,
])
void main() {
  group('Providers Comprehensive Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Data Providers', () {
      test('dataServiceProvider should provide LocalDataService instance', () {
        // Act
        final dataService = container.read(dataServiceProvider);

        // Assert
        expect(dataService, isNotNull);
        expect(dataService, isA<DataService>());
      });

      test('nameRepositoryProvider should provide NameRepository instance', () {
        // Act
        final nameRepository = container.read(nameRepositoryProvider);

        // Assert
        expect(nameRepository, isNotNull);
        expect(nameRepository, isA<NameRepository>());
      });

      test(
        'traitRepositoryProvider should provide TraitRepository instance',
        () {
          // Act
          final traitRepository = container.read(traitRepositoryProvider);

          // Assert
          expect(traitRepository, isNotNull);
          expect(traitRepository, isA<TraitRepository>());
        },
      );

      test('should inject data service dependency into repositories', () {
        // Act
        final dataService = container.read(dataServiceProvider);
        final nameRepository = container.read(nameRepositoryProvider);
        final traitRepository = container.read(traitRepositoryProvider);

        // Assert
        expect(dataService, isNotNull);
        expect(nameRepository, isNotNull);
        expect(traitRepository, isNotNull);
      });

      test('should return same instance on multiple reads', () {
        // Act
        final dataService1 = container.read(dataServiceProvider);
        final dataService2 = container.read(dataServiceProvider);
        final nameRepository1 = container.read(nameRepositoryProvider);
        final nameRepository2 = container.read(nameRepositoryProvider);

        // Assert
        expect(identical(dataService1, dataService2), isTrue);
        expect(identical(nameRepository1, nameRepository2), isTrue);
      });

      test('should properly wire dependencies between providers', () {
        // Act
        final nameRepository = container.read(nameRepositoryProvider);
        final traitRepository = container.read(traitRepositoryProvider);

        // Assert - Repositories should be properly initialized
        expect(nameRepository, isA<NameRepository>());
        expect(traitRepository, isA<TraitRepository>());
      });
    });

    group('State Providers', () {
      test(
        'selectedRegionProvider should have default value of Region.english',
        () {
          // Act
          final selectedRegion = container.read(selectedRegionProvider);

          // Assert
          expect(selectedRegion, equals(Region.english));
        },
      );

      test(
        'selectedGenderProvider should have default value of Gender.male',
        () {
          // Act
          final selectedGender = container.read(selectedGenderProvider);

          // Assert
          expect(selectedGender, equals(Gender.male));
        },
      );

      test('generatedNameProvider should have default value of null', () {
        // Act
        final generatedName = container.read(generatedNameProvider);

        // Assert
        expect(generatedName, isNull);
      });

      test(
        'generatedTraitsProvider should have default value of empty list',
        () {
          // Act
          final generatedTraits = container.read(generatedTraitsProvider);

          // Assert
          expect(generatedTraits, isEmpty);
        },
      );

      test('should update when state changes', () {
        // Arrange
        var regionChangeCount = 0;
        var genderChangeCount = 0;
        var nameChangeCount = 0;
        var traitsChangeCount = 0;

        container.listen(
          selectedRegionProvider,
          (_, __) => regionChangeCount++,
        );
        container.listen(
          selectedGenderProvider,
          (_, __) => genderChangeCount++,
        );
        container.listen(generatedNameProvider, (_, __) => nameChangeCount++);
        container.listen(
          generatedTraitsProvider,
          (_, __) => traitsChangeCount++,
        );

        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAsian;
        container.read(selectedGenderProvider.notifier).state = Gender.female;
        container.read(generatedNameProvider.notifier).state = Name(
          firstName: 'Test',
          lastName: 'User',
          gender: Gender.female,
          region: Region.eastAsian,
        );
        container.read(generatedTraitsProvider.notifier).state = [
          Trait(
            id: 'test',
            name: 'Test',
            description: 'Test trait',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        // Assert
        expect(regionChangeCount, equals(1));
        expect(genderChangeCount, equals(1));
        expect(nameChangeCount, equals(1));
        expect(traitsChangeCount, equals(1));

        expect(
          container.read(selectedRegionProvider),
          equals(Region.eastAsian),
        );
        expect(container.read(selectedGenderProvider), equals(Gender.female));
        expect(container.read(generatedNameProvider), isNotNull);
        expect(container.read(generatedTraitsProvider), hasLength(1));
      });

      test('should not affect other providers when one changes', () {
        // Arrange
        var regionChangeCount = 0;
        var genderChangeCount = 0;

        container.listen(
          selectedRegionProvider,
          (_, __) => regionChangeCount++,
        );
        container.listen(
          selectedGenderProvider,
          (_, __) => genderChangeCount++,
        );

        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAsian;

        // Assert
        expect(regionChangeCount, equals(1));
        expect(genderChangeCount, equals(0));
        expect(
          container.read(selectedGenderProvider),
          equals(Gender.male),
        ); // Should remain unchanged
      });

      test('should handle multiple state changes independently', () {
        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAsian;
        container.read(selectedRegionProvider.notifier).state =
            Region.middleEastern;
        container.read(selectedGenderProvider.notifier).state = Gender.female;

        // Assert
        expect(
          container.read(selectedRegionProvider),
          equals(Region.middleEastern),
        );
        expect(container.read(selectedGenderProvider), equals(Gender.female));
      });
    });

    group('Character Generator Provider', () {
      test('should provide CharacterGeneratorNotifier instance', () {
        // Act
        final notifier = container.read(characterGeneratorProvider.notifier);
        final state = container.read(characterGeneratorProvider);

        // Assert
        expect(notifier, isA<CharacterGeneratorNotifier>());
        expect(state, isA<CharacterGeneratorState>());
        expect(state, equals(const CharacterGeneratorState.initial()));
      });

      test('should inject repository dependencies correctly', () {
        // Act
        final notifier = container.read(characterGeneratorProvider.notifier);

        // Assert
        expect(notifier, isA<CharacterGeneratorNotifier>());
      });

      test('should maintain state across multiple reads', () {
        // Act
        final state1 = container.read(characterGeneratorProvider);
        final state2 = container.read(characterGeneratorProvider);

        // Assert
        expect(state1, equals(state2));
      });
    });

    group('Provider Integration', () {
      test('should work together in realistic scenarios', () {
        // Arrange
        var stateChangeCount = 0;
        container.listen<CharacterGeneratorState>(
          characterGeneratorProvider,
          (previous, next) => stateChangeCount++,
        );

        // Act - Simulate user interaction flow
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAsian;
        container.read(selectedGenderProvider.notifier).state = Gender.female;

        final selectedRegion = container.read(selectedRegionProvider);
        final selectedGender = container.read(selectedGenderProvider);
        final generatorState = container.read(characterGeneratorProvider);

        // Assert
        expect(selectedRegion, equals(Region.eastAsian));
        expect(selectedGender, equals(Gender.female));
        expect(generatorState, equals(const CharacterGeneratorState.initial()));
      });

      test('should handle provider disposal correctly', () {
        // Arrange
        final initialState = container.read(characterGeneratorProvider);

        // Act
        container.dispose();

        // Assert - Should not throw
        expect(initialState, isA<CharacterGeneratorState>());
      });

      test('should support provider overrides for testing', () {
        // Arrange
        final mockDataService = MockDataService();
        final testContainer = ProviderContainer(
          overrides: [dataServiceProvider.overrideWithValue(mockDataService)],
        );

        // Act
        final dataService = testContainer.read(dataServiceProvider);

        // Assert
        expect(dataService, equals(mockDataService));

        // Cleanup
        testContainer.dispose();
      });
    });

    group('Provider Error Handling', () {
      test('should handle provider creation errors gracefully', () {
        // This test ensures providers don't throw during creation
        expect(() {
          container.read(dataServiceProvider);
          container.read(nameRepositoryProvider);
          container.read(traitRepositoryProvider);
          container.read(characterGeneratorProvider);
        }, returnsNormally);
      });

      test('should maintain provider state consistency', () {
        // Arrange
        final initialRegion = container.read(selectedRegionProvider);
        final initialGender = container.read(selectedGenderProvider);

        // Act - Make changes and verify consistency
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAsian;
        final updatedRegion = container.read(selectedRegionProvider);
        final unchangedGender = container.read(selectedGenderProvider);

        // Assert
        expect(initialRegion, equals(Region.english));
        expect(initialGender, equals(Gender.male));
        expect(updatedRegion, equals(Region.eastAsian));
        expect(unchangedGender, equals(Gender.male)); // Should remain unchanged
      });
    });

    group('Provider Performance', () {
      test('should not recreate providers unnecessarily', () {
        // Act
        final dataService1 = container.read(dataServiceProvider);
        final dataService2 = container.read(dataServiceProvider);
        final nameRepo1 = container.read(nameRepositoryProvider);
        final nameRepo2 = container.read(nameRepositoryProvider);

        // Assert - Same instances should be returned
        expect(identical(dataService1, dataService2), isTrue);
        expect(identical(nameRepo1, nameRepo2), isTrue);
      });

      test('should handle rapid state changes efficiently', () {
        // Arrange
        var changeCount = 0;
        container.listen(selectedRegionProvider, (_, __) => changeCount++);

        // Act - Rapid state changes
        for (int i = 0; i < 10; i++) {
          final region = Region.values[i % Region.values.length];
          container.read(selectedRegionProvider.notifier).state = region;
        }

        // Assert
        expect(changeCount, equals(10));
        expect(container.read(selectedRegionProvider), isA<Region>());
      });
    });

    group('Provider Lifecycle', () {
      test('should initialize providers correctly', () {
        // Act
        final providers = [
          dataServiceProvider,
          nameRepositoryProvider,
          traitRepositoryProvider,
          selectedRegionProvider,
          selectedGenderProvider,
          generatedNameProvider,
          generatedTraitsProvider,
          characterGeneratorProvider,
        ];

        // Assert - All providers should be readable without errors
        for (final provider in providers) {
          expect(() => container.read(provider as ProviderBase), returnsNormally);
        }
      });

      test('should handle container disposal gracefully', () {
        // Arrange
        container.read(dataServiceProvider);
        container.read(nameRepositoryProvider);
        container.read(characterGeneratorProvider);

        // Act & Assert - Should not throw
        expect(() => container.dispose(), returnsNormally);
      });
    });
  });
}
