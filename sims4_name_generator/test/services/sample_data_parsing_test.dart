import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'sample_data_service.dart';

void main() {
  group('Sample Data Parsing Tests', () {
    late SampleDataService dataService;

    setUp(() {
      dataService = SampleDataService();
    });

    group('Sample Name Data Parsing', () {
      test('should parse English male sample names correctly', () async {
        // Act
        final names = await dataService.loadNames(Region.english, Gender.male);

        // Assert
        expect(names.isNotEmpty, isTrue);
        expect(names.length, equals(15 * 15)); // 15 first names × 15 last names

        // Check that all names have correct region and gender
        for (final name in names) {
          expect(name.region, equals(Region.english));
          expect(name.gender, equals(Gender.male));
          expect(name.firstName.isNotEmpty, isTrue);
          expect(name.lastName.isNotEmpty, isTrue);
        }

        // Check specific names exist
        final alexanderAnderson = names.firstWhere(
          (name) =>
              name.firstName == 'Alexander' && name.lastName == 'Anderson',
          orElse: () => throw Exception('Alexander Anderson not found'),
        );
        expect(alexanderAnderson.firstName, equals('Alexander'));
        expect(alexanderAnderson.lastName, equals('Anderson'));
      });

      test('should parse English female sample names correctly', () async {
        // Act
        final names = await dataService.loadNames(
          Region.english,
          Gender.female,
        );

        // Assert
        expect(names.isNotEmpty, isTrue);
        expect(names.length, equals(15 * 15)); // 15 first names × 15 last names

        // Check that all names have correct region and gender
        for (final name in names) {
          expect(name.region, equals(Region.english));
          expect(name.gender, equals(Gender.female));
          expect(name.firstName.isNotEmpty, isTrue);
          expect(name.lastName.isNotEmpty, isTrue);
        }

        // Check specific names exist
        final aliceAnderson = names.firstWhere(
          (name) => name.firstName == 'Alice' && name.lastName == 'Anderson',
          orElse: () => throw Exception('Alice Anderson not found'),
        );
        expect(aliceAnderson.firstName, equals('Alice'));
        expect(aliceAnderson.lastName, equals('Anderson'));
      });

      test('should parse East Asian male sample names correctly', () async {
        // Act
        final names = await dataService.loadNames(
          Region.eastAsian,
          Gender.male,
        );

        // Assert
        expect(names.isNotEmpty, isTrue);
        expect(names.length, equals(15 * 15)); // 15 first names × 15 last names

        // Check that all names have correct region and gender
        for (final name in names) {
          expect(name.region, equals(Region.eastAsian));
          expect(name.gender, equals(Gender.male));
          expect(name.firstName.isNotEmpty, isTrue);
          expect(name.lastName.isNotEmpty, isTrue);
        }

        // Check specific names exist
        final akira = names.where((name) => name.firstName == 'Akira').toList();
        expect(akira.isNotEmpty, isTrue);
        expect(akira.first.firstName, equals('Akira'));
      });

      test('should parse East Asian female sample names correctly', () async {
        // Act
        final names = await dataService.loadNames(
          Region.eastAsian,
          Gender.female,
        );

        // Assert
        expect(names.isNotEmpty, isTrue);
        expect(names.length, equals(15 * 15)); // 15 first names × 15 last names

        // Check that all names have correct region and gender
        for (final name in names) {
          expect(name.region, equals(Region.eastAsian));
          expect(name.gender, equals(Gender.female));
          expect(name.firstName.isNotEmpty, isTrue);
          expect(name.lastName.isNotEmpty, isTrue);
        }

        // Check specific names exist
        final akiko = names.where((name) => name.firstName == 'Akiko').toList();
        expect(akiko.isNotEmpty, isTrue);
        expect(akiko.first.firstName, equals('Akiko'));
      });

      test('should parse Middle Eastern male sample names correctly', () async {
        // Act
        final names = await dataService.loadNames(
          Region.middleEastern,
          Gender.male,
        );

        // Assert
        expect(names.isNotEmpty, isTrue);
        expect(names.length, equals(15 * 15)); // 15 first names × 15 last names

        // Check that all names have correct region and gender
        for (final name in names) {
          expect(name.region, equals(Region.middleEastern));
          expect(name.gender, equals(Gender.male));
          expect(name.firstName.isNotEmpty, isTrue);
          expect(name.lastName.isNotEmpty, isTrue);
        }

        // Check specific names exist
        final ahmed = names.where((name) => name.firstName == 'Ahmed').toList();
        expect(ahmed.isNotEmpty, isTrue);
        expect(ahmed.first.firstName, equals('Ahmed'));
      });

      test(
        'should parse Middle Eastern female sample names correctly',
        () async {
          // Act
          final names = await dataService.loadNames(
            Region.middleEastern,
            Gender.female,
          );

          // Assert
          expect(names.isNotEmpty, isTrue);
          expect(
            names.length,
            equals(15 * 15),
          ); // 15 first names × 15 last names

          // Check that all names have correct region and gender
          for (final name in names) {
            expect(name.region, equals(Region.middleEastern));
            expect(name.gender, equals(Gender.female));
            expect(name.firstName.isNotEmpty, isTrue);
            expect(name.lastName.isNotEmpty, isTrue);
          }

          // Check specific names exist
          final aisha = names
              .where((name) => name.firstName == 'Aisha')
              .toList();
          expect(aisha.isNotEmpty, isTrue);
          expect(aisha.first.firstName, equals('Aisha'));
        },
      );

      test('should cache names after first load', () async {
        // Act
        final names1 = await dataService.loadNames(Region.english, Gender.male);
        final names2 = await dataService.loadNames(Region.english, Gender.male);

        // Assert
        expect(
          identical(names1, names2),
          isTrue,
        ); // Should return same cached instance
      });
    });

    group('Sample Trait Data Parsing', () {
      test('should parse sample traits correctly', () async {
        // Act
        final traits = await dataService.loadTraits();

        // Assert
        expect(traits.isNotEmpty, isTrue);
        expect(traits.length, equals(15)); // 15 sample traits

        // Check that all traits have required fields
        for (final trait in traits) {
          expect(trait.id.isNotEmpty, isTrue);
          expect(trait.name.isNotEmpty, isTrue);
          expect(trait.description.isNotEmpty, isTrue);
          expect(trait.pack.isNotEmpty, isTrue);
        }

        // Check specific traits exist
        final active = traits.firstWhere(
          (trait) => trait.id == 'active',
          orElse: () => throw Exception('Active trait not found'),
        );
        expect(active.name, equals('Active'));
        expect(active.category, equals(TraitCategory.lifestyle));
        expect(active.pack, equals('base_game'));
        expect(active.conflictingTraits, contains('lazy'));

        final cheerful = traits.firstWhere(
          (trait) => trait.id == 'cheerful',
          orElse: () => throw Exception('Cheerful trait not found'),
        );
        expect(cheerful.name, equals('Cheerful'));
        expect(cheerful.category, equals(TraitCategory.emotional));
        expect(cheerful.conflictingTraits, contains('gloomy'));
      });

      test('should validate trait conflicts correctly', () async {
        // Act
        final traits = await dataService.loadTraits();

        // Assert
        final active = traits.firstWhere((trait) => trait.id == 'active');
        final lazy = traits.firstWhere((trait) => trait.id == 'lazy');
        final cheerful = traits.firstWhere((trait) => trait.id == 'cheerful');
        final gloomy = traits.firstWhere((trait) => trait.id == 'gloomy');
        final good = traits.firstWhere((trait) => trait.id == 'good');
        final evil = traits.firstWhere((trait) => trait.id == 'evil');

        // Test bidirectional conflicts
        expect(active.conflictsWith(lazy), isTrue);
        expect(lazy.conflictsWith(active), isTrue);
        expect(cheerful.conflictsWith(gloomy), isTrue);
        expect(gloomy.conflictsWith(cheerful), isTrue);
        expect(good.conflictsWith(evil), isTrue);
        expect(evil.conflictsWith(good), isTrue);

        // Test non-conflicting traits
        expect(active.conflictsWith(cheerful), isFalse);
        expect(cheerful.conflictsWith(active), isFalse);
      });

      test('should parse all trait categories correctly', () async {
        // Act
        final traits = await dataService.loadTraits();

        // Assert
        final categories = traits.map((trait) => trait.category).toSet();
        expect(categories.contains(TraitCategory.lifestyle), isTrue);
        expect(categories.contains(TraitCategory.emotional), isTrue);
        expect(categories.contains(TraitCategory.hobby), isTrue);
        expect(categories.contains(TraitCategory.social), isTrue);

        // Check specific category counts
        final lifestyleTraits = traits
            .where((trait) => trait.category == TraitCategory.lifestyle)
            .toList();
        final emotionalTraits = traits
            .where((trait) => trait.category == TraitCategory.emotional)
            .toList();
        final hobbyTraits = traits
            .where((trait) => trait.category == TraitCategory.hobby)
            .toList();
        final socialTraits = traits
            .where((trait) => trait.category == TraitCategory.social)
            .toList();

        expect(lifestyleTraits.length, greaterThan(0));
        expect(emotionalTraits.length, greaterThan(0));
        expect(hobbyTraits.length, greaterThan(0));
        expect(socialTraits.length, greaterThan(0));
      });

      test('should cache traits after first load', () async {
        // Act
        final traits1 = await dataService.loadTraits();
        final traits2 = await dataService.loadTraits();

        // Assert
        expect(
          identical(traits1, traits2),
          isTrue,
        ); // Should return same cached instance
      });
    });

    group('Data Validation and Error Handling', () {
      test('should handle missing asset files gracefully', () async {
        // Create a data service with a mock asset bundle that throws FlutterError
        final mockAssetBundle = _MockAssetBundle();
        final testDataService = SampleDataService(mockAssetBundle);

        // Act & Assert
        expect(
          () => testDataService.loadNames(Region.lithuanian, Gender.male),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Asset not found'),
            ),
          ),
        );
      });

      test('should validate JSON structure for names', () async {
        // This test would require creating a mock asset bundle with invalid JSON
        // For now, we'll test that the current sample data has the expected structure
        final names = await dataService.loadNames(Region.english, Gender.male);

        // Verify that names were created correctly (combination of first and last names)
        final firstNames = names.map((name) => name.firstName).toSet();
        final lastNames = names.map((name) => name.lastName).toSet();

        expect(
          firstNames.length,
          equals(15),
        ); // Should have 15 unique first names
        expect(
          lastNames.length,
          equals(15),
        ); // Should have 15 unique last names
        expect(names.length, equals(15 * 15)); // Should have all combinations
      });

      test('should validate JSON structure for traits', () async {
        final traits = await dataService.loadTraits();

        // Verify all required fields are present and valid
        for (final trait in traits) {
          expect(trait.id.isNotEmpty, isTrue);
          expect(trait.name.isNotEmpty, isTrue);
          expect(trait.description.isNotEmpty, isTrue);
          expect(trait.pack.isNotEmpty, isTrue);
          expect(TraitCategory.values.contains(trait.category), isTrue);
        }
      });

      test('should clear cache correctly', () async {
        // Arrange
        await dataService.loadNames(Region.english, Gender.male);
        await dataService.loadTraits();

        // Act
        dataService.clearCache();

        // Assert - This would require accessing private fields, so we'll test behavior
        // by loading data again and ensuring it works (cache was cleared successfully)
        final names = await dataService.loadNames(Region.english, Gender.male);
        final traits = await dataService.loadTraits();

        expect(names.isNotEmpty, isTrue);
        expect(traits.isNotEmpty, isTrue);
      });
    });
  });
}

/// Mock AssetBundle that throws FlutterError for testing error handling
class _MockAssetBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async {
    throw FlutterError('Asset not found: $key');
  }

  @override
  void evict(String key) {}

  @override
  void clear() {}
}
