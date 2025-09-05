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
  group('Sample Data Files Format Tests', () {
    late MockAssetBundle mockAssetBundle;
    late LocalDataService dataService;

    setUp(() {
      mockAssetBundle = MockAssetBundle();
      dataService = LocalDataService(mockAssetBundle);
    });

    group('Northern European Sample Data', () {
      test('should parse Northern European male names correctly', () async {
        // Arrange - Sample data in the expected format
        final nameData = {
          'region': 'northernEuropean',
          'gender': 'male',
          'firstNames': ['Anders', 'Bjorn', 'Carl', 'Erik'],
          'lastNames': ['Andersen', 'Berg', 'Carlsson', 'Dahl'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/northernEuropean_male.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(
          Region.northernEuropean,
          Gender.male,
        );

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.northernEuropean));
        expect(names.first.gender, equals(Gender.male));

        // Verify specific combinations exist
        final andersAndersen = names.firstWhere(
          (name) => name.firstName == 'Anders' && name.lastName == 'Andersen',
        );
        expect(andersAndersen, isNotNull);
      });

      test('should parse Northern European female names correctly', () async {
        // Arrange
        final nameData = {
          'region': 'northernEuropean',
          'gender': 'female',
          'firstNames': ['Astrid', 'Freya', 'Greta', 'Helga'],
          'lastNames': ['Andersen', 'Berg', 'Carlsson', 'Dahl'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/northernEuropean_female.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(
          Region.northernEuropean,
          Gender.female,
        );

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.northernEuropean));
        expect(names.first.gender, equals(Gender.female));
      });
    });

    group('South Asian Sample Data', () {
      test('should parse South Asian male names correctly', () async {
        // Arrange
        final nameData = {
          'region': 'southAsian',
          'gender': 'male',
          'firstNames': ['Aarav', 'Arjun', 'Dev', 'Gautam'],
          'lastNames': ['Agarwal', 'Bansal', 'Chandra', 'Desai'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/southAsian_male.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(
          Region.southAsian,
          Gender.male,
        );

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.southAsian));
        expect(names.first.gender, equals(Gender.male));
      });

      test('should parse South Asian female names correctly', () async {
        // Arrange
        final nameData = {
          'region': 'southAsian',
          'gender': 'female',
          'firstNames': ['Aadhya', 'Ananya', 'Diya', 'Kavya'],
          'lastNames': ['Agarwal', 'Bansal', 'Chandra', 'Desai'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/southAsian_female.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(
          Region.southAsian,
          Gender.female,
        );

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.southAsian));
        expect(names.first.gender, equals(Gender.female));
      });
    });

    group('Oceania Sample Data', () {
      test('should parse Oceania male names correctly', () async {
        // Arrange
        final nameData = {
          'region': 'oceania',
          'gender': 'male',
          'firstNames': ['Aiden', 'Blake', 'Connor', 'Dylan'],
          'lastNames': ['Anderson', 'Brown', 'Campbell', 'Davis'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/oceania_male.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(Region.oceania, Gender.male);

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.oceania));
        expect(names.first.gender, equals(Gender.male));
      });

      test('should parse Oceania female names correctly', () async {
        // Arrange
        final nameData = {
          'region': 'oceania',
          'gender': 'female',
          'firstNames': ['Aria', 'Bella', 'Chloe', 'Emma'],
          'lastNames': ['Anderson', 'Brown', 'Campbell', 'Davis'],
        };
        mockAssetBundle.addAsset(
          'assets/data/names/oceania_female.json',
          json.encode(nameData),
        );

        // Act
        final names = await dataService.loadNames(
          Region.oceania,
          Gender.female,
        );

        // Assert
        expect(names.length, equals(16)); // 4 × 4 combinations
        expect(names.first.region, equals(Region.oceania));
        expect(names.first.gender, equals(Gender.female));
      });
    });

    group('Sample Traits Data', () {
      test('should parse sample traits correctly', () async {
        // Arrange - Sample traits data
        final traitData = {
          'traits': [
            {
              'id': 'active',
              'name': 'Active',
              'description': 'These Sims tend to be Energized.',
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
            {
              'id': 'creative',
              'name': 'Creative',
              'description': 'These Sims tend to be Inspired.',
              'category': 'hobby',
              'pack': 'base_game',
              'conflictingTraits': [],
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
        expect(traits.length, equals(3));

        final activeTrait = traits.firstWhere((t) => t.id == 'active');
        expect(activeTrait.name, equals('Active'));
        expect(activeTrait.category, equals(TraitCategory.lifestyle));
        expect(activeTrait.conflictingTraits, contains('lazy'));

        final cheerfulTrait = traits.firstWhere((t) => t.id == 'cheerful');
        expect(cheerfulTrait.name, equals('Cheerful'));
        expect(cheerfulTrait.category, equals(TraitCategory.emotional));
        expect(cheerfulTrait.conflictingTraits, contains('gloomy'));

        final creativeTrait = traits.firstWhere((t) => t.id == 'creative');
        expect(creativeTrait.name, equals('Creative'));
        expect(creativeTrait.category, equals(TraitCategory.hobby));
        expect(creativeTrait.conflictingTraits, isEmpty);
      });
    });

    group('Data Format Validation', () {
      test('should validate name data structure requirements', () async {
        // Test that all required fields are present and properly typed
        final regions = [
          {'region': Region.northernEuropean, 'name': 'northernEuropean'},
          {'region': Region.southAsian, 'name': 'southAsian'},
          {'region': Region.oceania, 'name': 'oceania'},
        ];

        for (final regionInfo in regions) {
          for (final gender in Gender.values) {
            // Arrange
            final nameData = {
              'region': regionInfo['name'],
              'gender': gender.name,
              'firstNames': ['Test1', 'Test2'],
              'lastNames': ['Last1', 'Last2'],
            };
            mockAssetBundle.addAsset(
              'assets/data/names/${regionInfo['name']}_${gender.name}.json',
              json.encode(nameData),
            );

            // Act
            final names = await dataService.loadNames(
              regionInfo['region'] as Region,
              gender,
            );

            // Assert
            expect(names.length, equals(4)); // 2 × 2 combinations
            expect(names.every((name) => name.firstName.isNotEmpty), isTrue);
            expect(names.every((name) => name.lastName.isNotEmpty), isTrue);
            expect(
              names.every((name) => name.region == regionInfo['region']),
              isTrue,
            );
            expect(names.every((name) => name.gender == gender), isTrue);
          }
        }
      });

      test('should validate trait data structure requirements', () async {
        // Arrange - Test various trait configurations
        final traitData = {
          'traits': [
            {
              'id': 'test_trait_1',
              'name': 'Test Trait 1',
              'description': 'A test trait with conflicts.',
              'category': 'emotional',
              'pack': 'base_game',
              'conflictingTraits': ['test_trait_2'],
            },
            {
              'id': 'test_trait_2',
              'name': 'Test Trait 2',
              'description': 'A test trait without conflicts.',
              'category': 'lifestyle',
              'pack': 'expansion_pack',
              'conflictingTraits': [],
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

        for (final trait in traits) {
          expect(trait.id.isNotEmpty, isTrue);
          expect(trait.name.isNotEmpty, isTrue);
          expect(trait.description.isNotEmpty, isTrue);
          expect(trait.pack.isNotEmpty, isTrue);
          expect(trait.conflictingTraits, isA<List<String>>());
        }
      });
    });
  });
}
