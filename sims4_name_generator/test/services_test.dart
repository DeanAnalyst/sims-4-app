import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/models.dart';
import 'package:sims4_name_generator/services/local_data_service.dart';

/// Mock AssetBundle for testing
class MockAssetBundle extends AssetBundle {
  final Map<String, String> _assets = {};

  void addAsset(String key, String content) {
    _assets[key] = content;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final string = await loadString(key);
    return ByteData.sublistView(Uint8List.fromList(string.codeUnits));
  }

  @override
  void evict(String key) {
    _assets.remove(key);
  }
}

void main() {
  group('LocalDataService Tests', () {
    late MockAssetBundle mockAssetBundle;
    late LocalDataService dataService;

    setUp(() {
      mockAssetBundle = MockAssetBundle();
      dataService = LocalDataService(mockAssetBundle);
    });

    group('Name Loading Tests', () {
      test('should load names successfully from valid JSON', () async {
        // Arrange
        final nameData = {
          'region': 'english',
          'gender': 'male',
          'firstNames': ['John', 'James', 'William'],
          'lastNames': ['Smith', 'Johnson', 'Brown'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/english_male.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(Region.english, Gender.male);

        // Assert
        expect(names.length, equals(9)); // 3 first names × 3 last names
        expect(names.first.firstName, equals('John'));
        expect(names.first.lastName, equals('Smith'));
        expect(names.first.gender, equals(Gender.male));
        expect(names.first.region, equals(Region.english));

        // Verify all combinations are created
        final johnSmith = names.firstWhere(
          (name) => name.firstName == 'John' && name.lastName == 'Smith',
        );
        expect(johnSmith, isNotNull);

        final williamBrown = names.firstWhere(
          (name) => name.firstName == 'William' && name.lastName == 'Brown',
        );
        expect(williamBrown, isNotNull);
      });

      test(
        'should cache loaded names and return cached data on subsequent calls',
        () async {
          // Arrange
          final nameData = {
            'region': 'english',
            'gender': 'female',
            'firstNames': ['Mary', 'Patricia'],
            'lastNames': ['Wilson', 'Davis'],
          };
          mockAssetBundle.addAsset(
            'assets/data/names/english_female.json',
            json.encode(nameData),
          );

          // Act - First call
          final names1 = await dataService.loadNames(
            Region.english,
            Gender.female,
          );

          // Remove asset to test caching
          mockAssetBundle.evict('assets/data/names/english_female.json');

          // Act - Second call (should use cache)
          final names2 = await dataService.loadNames(
            Region.english,
            Gender.female,
          );

          // Assert
          expect(names1.length, equals(names2.length));
          expect(names1.first.firstName, equals(names2.first.firstName));
          expect(identical(names1, names2), isTrue); // Same object reference
        },
      );

      test('should throw exception when asset file is not found', () async {
        // Act & Assert
        expect(
          () => dataService.loadNames(Region.lithuanian, Gender.male),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Asset not found'),
            ),
          ),
        );
      });

      test('should throw exception when JSON format is invalid', () async {
        // Arrange - Missing required fields
        final invalidData = {
          'region': 'english',
          'gender': 'male',
          'firstNames': ['John'], // Missing lastNames
        };
        mockAssetBundle.addAsset(
          'assets/data/names/english_male.json',
          json.encode(invalidData),
        );

        // Act & Assert
        expect(
          () => dataService.loadNames(Region.english, Gender.male),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('missing firstNames or lastNames'),
            ),
          ),
        );
      });

      test('should throw exception when name lists are empty', () async {
        // Arrange - Empty name lists
        final emptyData = {
          'region': 'english',
          'gender': 'male',
          'firstNames': <String>[],
          'lastNames': ['Smith'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/english_male.json',
          json.encode(emptyData),
        );

        // Act & Assert
        expect(
          () => dataService.loadNames(Region.english, Gender.male),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('empty name lists'),
            ),
          ),
        );
      });

      test('should throw exception when JSON is malformed', () async {
        // Arrange - Invalid JSON
        mockAssetBundle.addAsset(
          'assets/data/names/english_male.json',
          'invalid json content {',
        );

        // Act & Assert
        expect(
          () => dataService.loadNames(Region.english, Gender.male),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Trait Loading Tests', () {
      test('should load traits successfully from valid JSON', () async {
        // Arrange
        final traitData = {
          'traits': [
            {
              'id': 'ambitious',
              'name': 'Ambitious',
              'description':
                  'These Sims gain powerful Moodlets from career success.',
              'category': 'lifestyle',
              'pack': 'base_game',
              'conflictingTraits': ['lazy'],
            },
            {
              'id': 'cheerful',
              'name': 'Cheerful',
              'description': 'These Sims tend to be Happier than other Sims.',
              'category': 'emotional',
              'pack': 'base_game',
              'conflictingTraits': ['gloomy'],
            },
          ],
        };
        mockAssetBundle.addAsset(
          'assets/data/traits/traits.json',
          json.encode(traitData),
        );

        // Act
        final traits = await dataService.loadTraits();

        // Assert
        expect(traits.length, equals(2));

        final ambitious = traits.firstWhere((t) => t.id == 'ambitious');
        expect(ambitious.name, equals('Ambitious'));
        expect(ambitious.category, equals(TraitCategory.lifestyle));
        expect(ambitious.pack, equals('base_game'));
        expect(ambitious.conflictingTraits, contains('lazy'));

        final cheerful = traits.firstWhere((t) => t.id == 'cheerful');
        expect(cheerful.name, equals('Cheerful'));
        expect(cheerful.category, equals(TraitCategory.emotional));
        expect(cheerful.conflictingTraits, contains('gloomy'));
      });

      test(
        'should cache loaded traits and return cached data on subsequent calls',
        () async {
          // Arrange
          final traitData = {
            'traits': [
              {
                'id': 'creative',
                'name': 'Creative',
                'description': 'These Sims tend to be Inspired.',
                'category': 'hobby',
                'pack': 'base_game',
                'conflictingTraits': <String>[],
              },
            ],
          };
          mockAssetBundle.addAsset(
            'assets/data/traits/traits.json',
            json.encode(traitData),
          );

          // Act - First call
          final traits1 = await dataService.loadTraits();

          // Remove asset to test caching
          mockAssetBundle.evict('assets/data/traits/traits.json');

          // Act - Second call (should use cache)
          final traits2 = await dataService.loadTraits();

          // Assert
          expect(traits1.length, equals(traits2.length));
          expect(traits1.first.id, equals(traits2.first.id));
          expect(identical(traits1, traits2), isTrue); // Same object reference
        },
      );

      test(
        'should throw exception when traits asset file is not found',
        () async {
          // Act & Assert
          expect(
            () => dataService.loadTraits(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Asset not found'),
              ),
            ),
          );
        },
      );

      test(
        'should throw exception when traits JSON format is invalid',
        () async {
          // Arrange - Missing required fields
          final invalidData = {
            'invalidKey': [], // Missing 'traits' key
          };
          mockAssetBundle.addAsset(
            'assets/data/traits/traits.json',
            json.encode(invalidData),
          );

          // Act & Assert
          expect(
            () => dataService.loadTraits(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('missing traits array'),
              ),
            ),
          );
        },
      );

      test('should throw exception when traits list is empty', () async {
        // Arrange - Empty traits list
        final emptyData = {'traits': <Map<String, dynamic>>[]};
        mockAssetBundle.addAsset(
          'assets/data/traits/traits.json',
          json.encode(emptyData),
        );

        // Act & Assert
        expect(
          () => dataService.loadTraits(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('empty traits list'),
            ),
          ),
        );
      });

      test(
        'should throw exception when individual trait data is invalid',
        () async {
          // Arrange - Invalid trait data
          final invalidTraitData = {
            'traits': [
              {
                'id': 'invalid_trait',
                // Missing required fields like 'name', 'description', etc.
              },
            ],
          };
          mockAssetBundle.addAsset(
            'assets/data/traits/traits.json',
            json.encode(invalidTraitData),
          );

          // Act & Assert
          expect(
            () => dataService.loadTraits(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Invalid trait data'),
              ),
            ),
          );
        },
      );
    });

    group('Data Initialization Tests', () {
      test('should initialize data successfully', () async {
        // Arrange
        final traitData = {
          'traits': [
            {
              'id': 'test_trait',
              'name': 'Test Trait',
              'description': 'A test trait.',
              'category': 'lifestyle',
              'pack': 'base_game',
              'conflictingTraits': <String>[],
            },
          ],
        };
        mockAssetBundle.addAsset(
          'assets/data/traits/traits.json',
          json.encode(traitData),
        );

        // Act
        await dataService.initializeData();

        // Assert - Traits should be pre-loaded
        final traits = await dataService.loadTraits();
        expect(traits.length, equals(1));
        expect(traits.first.id, equals('test_trait'));
      });

      test('should handle initialization errors gracefully', () async {
        // Act & Assert - No traits file available
        expect(() => dataService.initializeData(), throwsA(isA<Exception>()));
      });
    });

    group('Cache Management Tests', () {
      test('should clear cache when clearCache is called', () async {
        // Arrange
        final nameData = {
          'region': 'english',
          'gender': 'male',
          'firstNames': ['Test'],
          'lastNames': ['Name'],
        };
        final traitData = {
          'traits': [
            {
              'id': 'test_trait',
              'name': 'Test Trait',
              'description': 'A test trait.',
              'category': 'lifestyle',
              'pack': 'base_game',
              'conflictingTraits': <String>[],
            },
          ],
        };

        mockAssetBundle.addAsset(
          'assets/data/names/english_male.json',
          json.encode(nameData),
        );
        mockAssetBundle.addAsset(
          'assets/data/traits/traits.json',
          json.encode(traitData),
        );

        // Load data to populate cache
        await dataService.loadNames(Region.english, Gender.male);
        await dataService.loadTraits();

        // Act
        dataService.clearCache();

        // Remove assets to test that cache was cleared
        mockAssetBundle.evict('assets/data/names/english_male.json');
        mockAssetBundle.evict('assets/data/traits/traits.json');

        // Assert - Should throw exceptions since cache is cleared and assets are gone
        expect(
          () => dataService.loadNames(Region.english, Gender.male),
          throwsA(isA<Exception>()),
        );
        expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
      });
    });
  });
}
