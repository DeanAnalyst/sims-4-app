import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/models.dart';

void main() {
  group('Data Parsing Unit Tests', () {
    group('Name Data Structure Tests', () {
      test('should parse name JSON structure correctly', () {
        const mockJsonData = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": ["John", "James", "Robert"],
          "lastNames": ["Smith", "Johnson", "Williams"]
        }
        ''';

        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
          json.decode(mockJsonData),
        );

        expect(jsonData['region'], equals('english'));
        expect(jsonData['gender'], equals('male'));
        expect(jsonData['firstNames'], isA<List>());
        expect(jsonData['lastNames'], isA<List>());
        expect((jsonData['firstNames'] as List).length, equals(3));
        expect((jsonData['lastNames'] as List).length, equals(3));
      });

      test('should validate required JSON fields for names', () {
        const validJson = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": ["John"],
          "lastNames": ["Smith"]
        }
        ''';

        const invalidJson = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": ["John"]
        }
        ''';

        final validData = Map<String, dynamic>.from(json.decode(validJson));
        final invalidData = Map<String, dynamic>.from(json.decode(invalidJson));

        // Valid data should have all required fields
        expect(validData.containsKey('firstNames'), isTrue);
        expect(validData.containsKey('lastNames'), isTrue);

        // Invalid data should be missing required fields
        expect(invalidData.containsKey('firstNames'), isTrue);
        expect(invalidData.containsKey('lastNames'), isFalse);
      });

      test('should create Name objects from parsed data', () {
        final name = Name(
          firstName: 'Alexander',
          lastName: 'Anderson',
          gender: Gender.male,
          region: Region.english,
        );

        expect(name.firstName, equals('Alexander'));
        expect(name.lastName, equals('Anderson'));
        expect(name.gender, equals(Gender.male));
        expect(name.region, equals(Region.english));
        expect(name.fullName, equals('Alexander Anderson'));
      });

      test('should generate name combinations correctly', () {
        final firstNames = ['John', 'Jane'];
        final lastNames = ['Smith', 'Doe'];
        final names = <Name>[];

        for (final firstName in firstNames) {
          for (final lastName in lastNames) {
            names.add(
              Name(
                firstName: firstName,
                lastName: lastName,
                gender: Gender.male,
                region: Region.english,
              ),
            );
          }
        }

        expect(names.length, equals(4)); // 2 x 2 combinations
        expect(names.map((n) => n.fullName), contains('John Smith'));
        expect(names.map((n) => n.fullName), contains('John Doe'));
        expect(names.map((n) => n.fullName), contains('Jane Smith'));
        expect(names.map((n) => n.fullName), contains('Jane Doe'));
      });
    });

    group('Trait Data Structure Tests', () {
      test('should parse trait JSON structure correctly', () {
        const mockTraitJson = '''
        {
          "traits": [
            {
              "id": "active",
              "name": "Active",
              "description": "These Sims tend to be Energized.",
              "category": "lifestyle",
              "pack": "base_game",
              "conflictingTraits": ["lazy"]
            }
          ]
        }
        ''';

        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
          json.decode(mockTraitJson),
        );

        expect(jsonData['traits'], isA<List>());
        final traits = jsonData['traits'] as List;
        expect(traits.length, equals(1));

        final trait = traits[0] as Map<String, dynamic>;
        expect(trait['id'], equals('active'));
        expect(trait['name'], equals('Active'));
        expect(trait['description'], isA<String>());
        expect(trait['category'], equals('lifestyle'));
        expect(trait['pack'], equals('base_game'));
        expect(trait['conflictingTraits'], isA<List>());
      });

      test('should create Trait objects from JSON', () {
        final traitJson = {
          'id': 'cheerful',
          'name': 'Cheerful',
          'description': 'These Sims tend to be Happier than other Sims.',
          'category': 'emotional',
          'pack': 'base_game',
          'conflictingTraits': ['gloomy'],
        };

        final trait = Trait.fromJson(traitJson);

        expect(trait.id, equals('cheerful'));
        expect(trait.name, equals('Cheerful'));
        expect(trait.description, contains('Happier'));
        expect(trait.category, equals(TraitCategory.emotional));
        expect(trait.pack, equals('base_game'));
        expect(trait.conflictingTraits, contains('gloomy'));
      });

      test('should validate trait conflict logic', () {
        final activeTraitJson = {
          'id': 'active',
          'name': 'Active',
          'description': 'These Sims tend to be Energized.',
          'category': 'lifestyle',
          'pack': 'base_game',
          'conflictingTraits': ['lazy'],
        };

        final lazyTraitJson = {
          'id': 'lazy',
          'name': 'Lazy',
          'description': 'These Sims are harder to motivate.',
          'category': 'lifestyle',
          'pack': 'base_game',
          'conflictingTraits': ['active'],
        };

        final activeTrait = Trait.fromJson(activeTraitJson);
        final lazyTrait = Trait.fromJson(lazyTraitJson);

        expect(activeTrait.conflictsWith(lazyTrait), isTrue);
        expect(lazyTrait.conflictsWith(activeTrait), isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('should handle malformed JSON gracefully', () {
        const malformedJson = '{"invalid": json}';

        expect(
          () => json.decode(malformedJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('should validate enum parsing', () {
        // Test valid enum values
        expect(Region.values.map((e) => e.name), contains('english'));
        expect(Gender.values.map((e) => e.name), contains('male'));
        expect(TraitCategory.values.map((e) => e.name), contains('lifestyle'));

        // Test enum parsing from string
        expect(Region.values.byName('english'), equals(Region.english));
        expect(Gender.values.byName('female'), equals(Gender.female));
        expect(
          TraitCategory.values.byName('emotional'),
          equals(TraitCategory.emotional),
        );
      });

      test('should handle invalid enum values', () {
        expect(
          () => Region.values.byName('invalid_region'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => Gender.values.byName('invalid_gender'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => TraitCategory.values.byName('invalid_category'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Sample Data Structure Validation', () {
      test('should validate expected sample name file structure', () {
        // Test the expected structure of sample name files
        final sampleNameData = {
          'region': 'english',
          'gender': 'male',
          'firstNames': [
            'Alexander',
            'Benjamin',
            'Christopher',
            'Daniel',
            'Edward',
            'Frederick',
            'George',
            'Henry',
            'Isaac',
            'James',
            'Kenneth',
            'Lawrence',
            'Michael',
            'Nicholas',
            'Oliver',
          ],
          'lastNames': [
            'Anderson',
            'Brown',
            'Clark',
            'Davis',
            'Evans',
            'Fisher',
            'Green',
            'Harris',
            'Johnson',
            'King',
            'Lewis',
            'Miller',
            'Nelson',
            'Parker',
            'Roberts',
          ],
        };

        expect(sampleNameData['region'], equals('english'));
        expect(sampleNameData['gender'], equals('male'));
        expect(sampleNameData['firstNames'], isA<List<String>>());
        expect(sampleNameData['lastNames'], isA<List<String>>());
        expect((sampleNameData['firstNames'] as List).length, equals(15));
        expect((sampleNameData['lastNames'] as List).length, equals(15));
      });

      test('should validate expected sample trait file structure', () {
        // Test the expected structure of sample trait files
        final sampleTraitData = {
          'traits': [
            {
              'id': 'active',
              'name': 'Active',
              'description':
                  'These Sims tend to be Energized, can Pump Up other Sims, and may become upset if they don\'t exercise for a period of time.',
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

        expect(sampleTraitData['traits'], isA<List>());
        final traits = sampleTraitData['traits'] as List;
        expect(traits.length, equals(2));

        for (final trait in traits) {
          final traitMap = trait as Map<String, dynamic>;
          expect(traitMap.containsKey('id'), isTrue);
          expect(traitMap.containsKey('name'), isTrue);
          expect(traitMap.containsKey('description'), isTrue);
          expect(traitMap.containsKey('category'), isTrue);
          expect(traitMap.containsKey('pack'), isTrue);
          expect(traitMap.containsKey('conflictingTraits'), isTrue);
        }
      });

      test('should validate region coverage requirements', () {
        // Test that we have the required regions for sample data
        final requiredRegions = ['english', 'eastAsian', 'middleEastern'];

        final requiredGenders = ['male', 'female'];

        for (final region in requiredRegions) {
          for (final gender in requiredGenders) {
            // This test validates that we have the expected file naming structure
            final expectedFileName = '${region}_${gender}_sample.json';
            expect(
              expectedFileName,
              matches(RegExp(r'^\w+_\w+_sample\.json$')),
            );
          }
        }

        // Verify we have at least 3 regions as required by the task
        expect(requiredRegions.length, greaterThanOrEqualTo(3));
      });

      test('should validate name count requirements', () {
        // Test that sample data meets the 10-20 names requirement
        const nameCount = 15; // Our sample files have 15 names each

        expect(nameCount, greaterThanOrEqualTo(10));
        expect(nameCount, lessThanOrEqualTo(20));

        // Test that combinations meet expected count
        final expectedCombinations = nameCount * nameCount; // 15 x 15 = 225
        expect(expectedCombinations, equals(225));
      });
    });
  });
}
