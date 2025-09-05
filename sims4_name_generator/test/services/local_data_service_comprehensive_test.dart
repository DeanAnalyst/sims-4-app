import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/services/local_data_service.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/enums.dart';

import 'local_data_service_comprehensive_test.mocks.dart';

@GenerateMocks([AssetBundle])
void main() {
  group('LocalDataService Comprehensive Tests', () {
    late MockAssetBundle mockAssetBundle;
    late LocalDataService dataService;

    setUp(() {
      mockAssetBundle = MockAssetBundle();
      dataService = LocalDataService(mockAssetBundle);
    });

    group('loadNames', () {
      test('should load and parse names from JSON file', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const jsonContent = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": ["John", "James", "Robert"],
          "lastNames": ["Smith", "Johnson", "Brown"]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadNames(region, gender);

        // Assert
        expect(result, hasLength(9)); // 3 first names × 3 last names
        expect(result.every((name) => name.region == region), isTrue);
        expect(result.every((name) => name.gender == gender), isTrue);
        expect(result.map((n) => n.firstName), contains('John'));
        expect(result.map((n) => n.lastName), contains('Smith'));
      });

      test('should handle different regions and genders', () async {
        // Arrange
        const region = Region.eastAsian;
        const gender = Gender.female;
        const jsonContent = '''
        {
          "region": "eastAsian",
          "gender": "female",
          "firstNames": ["Mei", "Li", "Yuki"],
          "lastNames": ["Wang", "Chen", "Tanaka"]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/eastAsian_female.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadNames(region, gender);

        // Assert
        expect(result, hasLength(9));
        expect(result.every((name) => name.region == region), isTrue);
        expect(result.every((name) => name.gender == gender), isTrue);
        expect(result.map((n) => n.firstName), contains('Mei'));
        expect(result.map((n) => n.lastName), contains('Wang'));
      });

      test('should throw exception for malformed JSON', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const invalidJson = '{ invalid json }';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => invalidJson);

        // Act & Assert
        expect(
          () => dataService.loadNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for missing required fields', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const incompleteJson = '''
        {
          "region": "english",
          "firstNames": ["John", "James"]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => incompleteJson);

        // Act & Assert
        expect(
          () => dataService.loadNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when asset file not found', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenThrow(FlutterError('Asset not found'));

        // Act & Assert
        expect(
          () => dataService.loadNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty name lists', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const jsonContent = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": [],
          "lastNames": []
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadNames(region, gender);

        // Assert
        expect(result, isEmpty);
      });

      test('should validate region and gender consistency', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const inconsistentJson = '''
        {
          "region": "eastAsian",
          "gender": "female",
          "firstNames": ["John"],
          "lastNames": ["Smith"]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => inconsistentJson);

        // Act & Assert
        expect(
          () => dataService.loadNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('loadTraits', () {
      test('should load and parse traits from JSON file', () async {
        // Arrange
        const jsonContent = '''
        {
          "traits": [
            {
              "id": "ambitious",
              "name": "Ambitious",
              "description": "These Sims gain powerful Moodlets from career success.",
              "category": "emotional",
              "pack": "base_game",
              "conflictingTraits": ["lazy"]
            },
            {
              "id": "cheerful",
              "name": "Cheerful",
              "description": "These Sims tend to be Happier than other Sims.",
              "category": "emotional",
              "pack": "base_game",
              "conflictingTraits": []
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadTraits();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('ambitious'));
        expect(result[0].name, equals('Ambitious'));
        expect(result[0].category, equals(TraitCategory.emotional));
        expect(result[0].pack, equals('base_game'));
        expect(result[0].conflictingTraits, contains('lazy'));
        expect(result[1].id, equals('cheerful'));
        expect(result[1].conflictingTraits, isEmpty);
      });

      test('should handle traits with different categories', () async {
        // Arrange
        const jsonContent = '''
        {
          "traits": [
            {
              "id": "creative",
              "name": "Creative",
              "description": "These Sims enjoy creative activities.",
              "category": "hobby",
              "pack": "base_game",
              "conflictingTraits": []
            },
            {
              "id": "active",
              "name": "Active",
              "description": "These Sims enjoy physical activities.",
              "category": "lifestyle",
              "pack": "base_game",
              "conflictingTraits": ["lazy"]
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadTraits();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].category, equals(TraitCategory.hobby));
        expect(result[1].category, equals(TraitCategory.lifestyle));
      });

      test('should handle traits from different packs', () async {
        // Arrange
        const jsonContent = '''
        {
          "traits": [
            {
              "id": "base_trait",
              "name": "Base Trait",
              "description": "From base game.",
              "category": "emotional",
              "pack": "base_game",
              "conflictingTraits": []
            },
            {
              "id": "expansion_trait",
              "name": "Expansion Trait",
              "description": "From expansion pack.",
              "category": "emotional",
              "pack": "get_to_work",
              "conflictingTraits": []
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadTraits();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].pack, equals('base_game'));
        expect(result[1].pack, equals('get_to_work'));
      });

      test('should throw exception for malformed traits JSON', () async {
        // Arrange
        const invalidJson = '{ invalid json }';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => invalidJson);

        // Act & Assert
        expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
      });

      test(
        'should throw exception for missing required trait fields',
        () async {
          // Arrange
          const incompleteJson = '''
        {
          "traits": [
            {
              "id": "incomplete",
              "name": "Incomplete Trait"
            }
          ]
        }
        ''';

          when(
            mockAssetBundle.loadString('assets/data/traits/traits.json'),
          ).thenAnswer((_) async => incompleteJson);

          // Act & Assert
          expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
        },
      );

      test('should throw exception for invalid trait category', () async {
        // Arrange
        const invalidCategoryJson = '''
        {
          "traits": [
            {
              "id": "invalid",
              "name": "Invalid Trait",
              "description": "Has invalid category.",
              "category": "invalid_category",
              "pack": "base_game",
              "conflictingTraits": []
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => invalidCategoryJson);

        // Act & Assert
        expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
      });

      test('should throw exception when traits file not found', () async {
        // Arrange
        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenThrow(FlutterError('Asset not found'));

        // Act & Assert
        expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
      });

      test('should handle empty traits list', () async {
        // Arrange
        const jsonContent = '''
        {
          "traits": []
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadTraits();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle traits with complex conflicting traits', () async {
        // Arrange
        const jsonContent = '''
        {
          "traits": [
            {
              "id": "complex",
              "name": "Complex Trait",
              "description": "Has multiple conflicts.",
              "category": "emotional",
              "pack": "base_game",
              "conflictingTraits": ["trait1", "trait2", "trait3"]
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => jsonContent);

        // Act
        final result = await dataService.loadTraits();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].conflictingTraits, hasLength(3));
        expect(
          result[0].conflictingTraits,
          containsAll(['trait1', 'trait2', 'trait3']),
        );
      });
    });

    group('initializeData', () {
      test(
        'should complete without errors when all data loads successfully',
        () async {
          // Arrange
          const nameJson = '''
        {
          "region": "english",
          "gender": "male",
          "firstNames": ["John"],
          "lastNames": ["Smith"]
        }
        ''';
          const traitJson = '''
        {
          "traits": [
            {
              "id": "test",
              "name": "Test",
              "description": "Test trait.",
              "category": "emotional",
              "pack": "base_game",
              "conflictingTraits": []
            }
          ]
        }
        ''';

          when(mockAssetBundle.loadString(any)).thenAnswer((invocation) async {
            final path = invocation.positionalArguments[0] as String;
            if (path.contains('traits')) {
              return traitJson;
            } else {
              return nameJson;
            }
          });

          // Act & Assert
          expect(() => dataService.initializeData(), returnsNormally);
        },
      );

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(
          mockAssetBundle.loadString(any),
        ).thenThrow(FlutterError('Asset not found'));

        // Act & Assert
        expect(() => dataService.initializeData(), returnsNormally);
      });
    });

    group('error handling', () {
      test(
        'should provide meaningful error messages for name loading failures',
        () async {
          // Arrange
          const region = Region.english;
          const gender = Gender.male;

          when(
            mockAssetBundle.loadString('assets/data/names/english_male.json'),
          ).thenThrow(FlutterError('Network error'));

          // Act & Assert
          try {
            await dataService.loadNames(region, gender);
            fail('Expected exception was not thrown');
          } catch (e) {
            expect(e.toString(), contains('Failed to load names'));
            expect(e.toString(), contains('english'));
            expect(e.toString(), contains('male'));
          }
        },
      );

      test(
        'should provide meaningful error messages for trait loading failures',
        () async {
          // Arrange
          when(
            mockAssetBundle.loadString('assets/data/traits/traits.json'),
          ).thenThrow(FlutterError('Network error'));

          // Act & Assert
          try {
            await dataService.loadTraits();
            fail('Expected exception was not thrown');
          } catch (e) {
            expect(e.toString(), contains('Failed to load traits'));
          }
        },
      );
    });

    group('data validation', () {
      test('should validate name data structure', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const invalidStructure = '''
        {
          "region": "english",
          "gender": "male",
          "names": ["John Smith", "Jane Doe"]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/names/english_male.json'),
        ).thenAnswer((_) async => invalidStructure);

        // Act & Assert
        expect(
          () => dataService.loadNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });

      test('should validate trait data structure', () async {
        // Arrange
        const invalidStructure = '''
        {
          "traitList": [
            {
              "traitId": "test",
              "traitName": "Test"
            }
          ]
        }
        ''';

        when(
          mockAssetBundle.loadString('assets/data/traits/traits.json'),
        ).thenAnswer((_) async => invalidStructure);

        // Act & Assert
        expect(() => dataService.loadTraits(), throwsA(isA<Exception>()));
      });
    });
  });
}
