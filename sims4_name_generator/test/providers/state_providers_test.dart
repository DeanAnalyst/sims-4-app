import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sims4_name_generator/providers/state_providers.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';

void main() {
  group('State Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('selectedRegionProvider', () {
      test('should have default value of Region.english', () {
        // Act
        final selectedRegion = container.read(selectedRegionProvider);

        // Assert
        expect(selectedRegion, equals(Region.english));
      });

      test('should update when state changes', () {
        // Arrange
        final notifier = container.read(selectedRegionProvider.notifier);

        // Act
        notifier.state = Region.eastAsian;

        // Assert
        expect(
          container.read(selectedRegionProvider),
          equals(Region.eastAsian),
        );
      });

      test('should notify listeners when state changes', () {
        // Arrange
        bool wasNotified = false;
        container.listen(selectedRegionProvider, (previous, next) {
          wasNotified = true;
        });

        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.middleEastern;

        // Assert
        expect(wasNotified, isTrue);
      });
    });

    group('selectedGenderProvider', () {
      test('should have default value of Gender.male', () {
        // Act
        final selectedGender = container.read(selectedGenderProvider);

        // Assert
        expect(selectedGender, equals(Gender.male));
      });

      test('should update when state changes', () {
        // Arrange
        final notifier = container.read(selectedGenderProvider.notifier);

        // Act
        notifier.state = Gender.female;

        // Assert
        expect(container.read(selectedGenderProvider), equals(Gender.female));
      });

      test('should notify listeners when state changes', () {
        // Arrange
        bool wasNotified = false;
        container.listen(selectedGenderProvider, (previous, next) {
          wasNotified = true;
        });

        // Act
        container.read(selectedGenderProvider.notifier).state = Gender.female;

        // Assert
        expect(wasNotified, isTrue);
      });
    });

    group('themeProvider', () {
      test('should have default value of ThemeMode.system', () {
        // Act
        final theme = container.read(themeProvider);

        // Assert
        expect(theme, equals(ThemeMode.system));
      });

      test('should update when state changes', () {
        // Arrange
        final notifier = container.read(themeProvider.notifier);

        // Act
        notifier.state = ThemeMode.dark;

        // Assert
        expect(container.read(themeProvider), equals(ThemeMode.dark));
      });

      test('should notify listeners when state changes', () {
        // Arrange
        bool wasNotified = false;
        container.listen(themeProvider, (previous, next) {
          wasNotified = true;
        });

        // Act
        container.read(themeProvider.notifier).state = ThemeMode.light;

        // Assert
        expect(wasNotified, isTrue);
      });
    });

    group('generatedNameProvider', () {
      test('should have default value of null', () {
        // Act
        final generatedName = container.read(generatedNameProvider);

        // Assert
        expect(generatedName, isNull);
      });

      test('should update when state changes', () {
        // Arrange
        final testName = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );
        final notifier = container.read(generatedNameProvider.notifier);

        // Act
        notifier.state = testName;

        // Assert
        final result = container.read(generatedNameProvider);
        expect(result, equals(testName));
        expect(result?.firstName, equals('John'));
        expect(result?.lastName, equals('Doe'));
      });

      test('should notify listeners when state changes', () {
        // Arrange
        bool wasNotified = false;
        final testName = Name(
          firstName: 'Jane',
          lastName: 'Smith',
          gender: Gender.female,
          region: Region.english,
        );

        container.listen(generatedNameProvider, (previous, next) {
          wasNotified = true;
        });

        // Act
        container.read(generatedNameProvider.notifier).state = testName;

        // Assert
        expect(wasNotified, isTrue);
      });
    });

    group('generatedTraitsProvider', () {
      test('should have default value of empty list', () {
        // Act
        final generatedTraits = container.read(generatedTraitsProvider);

        // Assert
        expect(generatedTraits, isEmpty);
        expect(generatedTraits, isA<List<Trait>>());
      });

      test('should update when state changes', () {
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
        final notifier = container.read(generatedTraitsProvider.notifier);

        // Act
        notifier.state = testTraits;

        // Assert
        final result = container.read(generatedTraitsProvider);
        expect(result, equals(testTraits));
        expect(result.length, equals(2));
        expect(result[0].name, equals('Ambitious'));
        expect(result[1].name, equals('Cheerful'));
      });

      test('should notify listeners when state changes', () {
        // Arrange
        bool wasNotified = false;
        final testTraits = [
          Trait(
            id: 'creative',
            name: 'Creative',
            description: 'Test description',
            category: TraitCategory.hobby,
            pack: 'base_game',
          ),
        ];

        container.listen(generatedTraitsProvider, (previous, next) {
          wasNotified = true;
        });

        // Act
        container.read(generatedTraitsProvider.notifier).state = testTraits;

        // Assert
        expect(wasNotified, isTrue);
      });
    });

    group('Provider Independence', () {
      test('should not affect other providers when one changes', () {
        // Arrange
        final initialGender = container.read(selectedGenderProvider);
        final initialTheme = container.read(themeProvider);

        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.southAsian;

        // Assert
        expect(
          container.read(selectedRegionProvider),
          equals(Region.southAsian),
        );
        expect(container.read(selectedGenderProvider), equals(initialGender));
        expect(container.read(themeProvider), equals(initialTheme));
      });

      test('should handle multiple state changes independently', () {
        // Act
        container.read(selectedRegionProvider.notifier).state =
            Region.eastAfrican;
        container.read(selectedGenderProvider.notifier).state = Gender.female;
        container.read(themeProvider.notifier).state = ThemeMode.dark;

        // Assert
        expect(
          container.read(selectedRegionProvider),
          equals(Region.eastAfrican),
        );
        expect(container.read(selectedGenderProvider), equals(Gender.female));
        expect(container.read(themeProvider), equals(ThemeMode.dark));
      });
    });
  });
}
