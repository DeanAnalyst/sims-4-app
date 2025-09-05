import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/enums.dart';

import 'name_repository_comprehensive_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  group('NameRepository Comprehensive Tests', () {
    late MockDataService mockDataService;
    late NameRepository nameRepository;

    setUp(() {
      mockDataService = MockDataService();
      nameRepository = NameRepository(mockDataService);
    });

    group('getNames', () {
      test('should return names from data service', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final expectedNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => expectedNames);

        // Act
        final result = await nameRepository.getNames(region, gender);

        // Assert
        expect(result, equals(expectedNames));
        verify(mockDataService.loadNames(region, gender)).called(1);
      });

      test('should cache names after first load', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final expectedNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => expectedNames);

        // Act
        await nameRepository.getNames(region, gender);
        await nameRepository.getNames(region, gender);

        // Assert
        verify(mockDataService.loadNames(region, gender)).called(1);
      });

      test('should throw exception when data service fails', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockDataService.loadNames(region, gender),
        ).thenThrow(Exception('Data service error'));

        // Act & Assert
        expect(
          () => nameRepository.getNames(region, gender),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('generateRandomName', () {
      test('should generate random name from available names', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final availableNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => availableNames);

        // Act
        final result = await nameRepository.generateRandomName(region, gender);

        // Assert
        expect(availableNames, contains(result));
        expect(result.region, equals(region));
        expect(result.gender, equals(gender));
      });

      test('should throw exception when no names available', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => <Name>[]);

        // Act & Assert
        expect(
          () => nameRepository.generateRandomName(region, gender),
          throwsA(isA<Exception>()),
        );
      });

      test('should avoid duplicates when requested', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final availableNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'Robert',
            lastName: 'Brown',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => availableNames);

        // Act - Generate multiple names
        final results = <Name>[];
        for (int i = 0; i < 3; i++) {
          final name = await nameRepository.generateRandomName(
            region,
            gender,
            avoidDuplicates: true,
          );
          results.add(name);
        }

        // Assert - All names should be different
        expect(results.toSet(), hasLength(3));
      });
    });

    group('generateRandomNames', () {
      test('should generate multiple unique names', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final availableNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'Robert',
            lastName: 'Brown',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => availableNames);

        // Act
        final result = await nameRepository.generateRandomNames(
          region,
          gender,
          2,
        );

        // Assert
        expect(result, hasLength(2));
        expect(result[0], isNot(equals(result[1])));
        expect(availableNames, contains(result[0]));
        expect(availableNames, contains(result[1]));
      });

      test(
        'should return all names when requesting more than available',
        () async {
          // Arrange
          const region = Region.english;
          const gender = Gender.male;
          final availableNames = [
            Name(
              firstName: 'John',
              lastName: 'Smith',
              gender: gender,
              region: region,
            ),
          ];

          when(
            mockDataService.loadNames(region, gender),
          ).thenAnswer((_) async => availableNames);

          // Act
          final result = await nameRepository.generateRandomNames(
            region,
            gender,
            5,
          );

          // Assert
          expect(result, hasLength(1));
          expect(result[0], equals(availableNames[0]));
        },
      );

      test('should return empty list when count is zero or negative', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        // Act
        final result1 = await nameRepository.generateRandomNames(
          region,
          gender,
          0,
        );
        final result2 = await nameRepository.generateRandomNames(
          region,
          gender,
          -1,
        );

        // Assert
        expect(result1, isEmpty);
        expect(result2, isEmpty);
      });
    });

    group('getAvailableRegions', () {
      test('should return regions that have name data', () async {
        // Arrange
        final englishNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: Gender.male,
            region: Region.english,
          ),
        ];
        final emptyNames = <Name>[];

        // Mock English region to have names
        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => englishNames);
        when(
          mockDataService.loadNames(Region.english, Gender.female),
        ).thenAnswer((_) async => englishNames);

        // Mock other regions to be empty or throw exceptions
        when(
          mockDataService.loadNames(Region.eastAsian, Gender.male),
        ).thenAnswer((_) async => emptyNames);
        when(
          mockDataService.loadNames(Region.eastAsian, Gender.female),
        ).thenAnswer((_) async => emptyNames);

        // Mock some regions to throw exceptions (unavailable)
        when(
          mockDataService.loadNames(Region.middleEastern, Gender.male),
        ).thenThrow(Exception('Region not available'));
        when(
          mockDataService.loadNames(Region.middleEastern, Gender.female),
        ).thenThrow(Exception('Region not available'));

        // Act
        final result = await nameRepository.getAvailableRegions();

        // Assert
        expect(result, contains(Region.english));
        expect(result, isNot(contains(Region.middleEastern)));
      });
    });

    group('preloadNames', () {
      test('should preload names for specified regions and genders', () async {
        // Arrange
        final regions = [Region.english, Region.eastAsian];
        final genders = [Gender.male, Gender.female];
        final names = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: Gender.male,
            region: Region.english,
          ),
        ];

        when(
          mockDataService.loadNames(any, any),
        ).thenAnswer((_) async => names);

        // Act
        await nameRepository.preloadNames(regions, genders);

        // Assert
        verify(
          mockDataService.loadNames(Region.english, Gender.male),
        ).called(1);
        verify(
          mockDataService.loadNames(Region.english, Gender.female),
        ).called(1);
        verify(
          mockDataService.loadNames(Region.eastAsian, Gender.male),
        ).called(1);
        verify(
          mockDataService.loadNames(Region.eastAsian, Gender.female),
        ).called(1);
      });

      test('should continue preloading even if some regions fail', () async {
        // Arrange
        final regions = [Region.english, Region.eastAsian];
        final genders = [Gender.male];
        final names = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: Gender.male,
            region: Region.english,
          ),
        ];

        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => names);
        when(
          mockDataService.loadNames(Region.eastAsian, Gender.male),
        ).thenThrow(Exception('Region not available'));

        // Act
        await nameRepository.preloadNames(regions, genders);

        // Assert
        verify(
          mockDataService.loadNames(Region.english, Gender.male),
        ).called(1);
        verify(
          mockDataService.loadNames(Region.eastAsian, Gender.male),
        ).called(1);
      });
    });

    group('generation history', () {
      test('should track generation history', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final availableNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => availableNames);

        // Act
        final name1 = await nameRepository.generateRandomName(region, gender);
        final name2 = await nameRepository.generateRandomName(region, gender);
        final history = nameRepository.getGenerationHistory(region, gender);

        // Assert
        expect(history, contains(name1));
        expect(history, contains(name2));
        expect(history, hasLength(2));
      });

      test('should clear history for specific region and gender', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final availableNames = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => availableNames);

        // Act
        await nameRepository.generateRandomName(region, gender);
        nameRepository.clearHistory(region, gender);
        final history = nameRepository.getGenerationHistory(region, gender);

        // Assert
        expect(history, isEmpty);
      });

      test('should clear all history', () async {
        // Arrange
        const region1 = Region.english;
        const gender1 = Gender.male;
        const region2 = Region.english;
        const gender2 = Gender.female;
        final names = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: Gender.male,
            region: Region.english,
          ),
        ];

        when(
          mockDataService.loadNames(any, any),
        ).thenAnswer((_) async => names);

        // Act
        await nameRepository.generateRandomName(region1, gender1);
        await nameRepository.generateRandomName(region2, gender2);
        nameRepository.clearAllHistory();

        // Assert
        expect(nameRepository.getGenerationHistory(region1, gender1), isEmpty);
        expect(nameRepository.getGenerationHistory(region2, gender2), isEmpty);
      });
    });

    group('weighted selection', () {
      test('should set name weights', () {
        // Arrange
        const fullName = 'John Smith';
        const weight = 2.5;

        // Act
        nameRepository.setNameWeight(fullName, weight);

        // Assert - No direct way to verify, but should not throw
        expect(
          () => nameRepository.setNameWeight(fullName, weight),
          returnsNormally,
        );
      });

      test('should set region weights', () {
        // Arrange
        const region = Region.english;
        const weight = 1.5;

        // Act
        nameRepository.setRegionWeight(region, weight);

        // Assert - No direct way to verify, but should not throw
        expect(
          () => nameRepository.setRegionWeight(region, weight),
          returnsNormally,
        );
      });

      test('should clamp weights to valid range', () {
        // Arrange
        const fullName = 'John Smith';
        const region = Region.english;

        // Act & Assert - Should not throw for extreme values
        expect(
          () => nameRepository.setNameWeight(fullName, -1.0),
          returnsNormally,
        );
        expect(
          () => nameRepository.setNameWeight(fullName, 15.0),
          returnsNormally,
        );
        expect(
          () => nameRepository.setRegionWeight(region, -1.0),
          returnsNormally,
        );
        expect(
          () => nameRepository.setRegionWeight(region, 15.0),
          returnsNormally,
        );
      });
    });

    group('cache management', () {
      test('should clear cache and reload data', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        final names = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender,
            region: region,
          ),
        ];

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => names);

        // Act
        await nameRepository.getNames(region, gender); // Load and cache
        nameRepository.clearCache(); // Clear cache
        await nameRepository.getNames(region, gender); // Load again

        // Assert
        verify(mockDataService.loadNames(region, gender)).called(2);
      });

      test('should return cache statistics', () async {
        // Arrange
        const region1 = Region.english;
        const gender1 = Gender.male;
        const region2 = Region.english;
        const gender2 = Gender.female;

        final names1 = [
          Name(
            firstName: 'John',
            lastName: 'Smith',
            gender: gender1,
            region: region1,
          ),
          Name(
            firstName: 'James',
            lastName: 'Johnson',
            gender: gender1,
            region: region1,
          ),
        ];

        final names2 = [
          Name(
            firstName: 'Jane',
            lastName: 'Smith',
            gender: gender2,
            region: region2,
          ),
        ];

        when(
          mockDataService.loadNames(region1, gender1),
        ).thenAnswer((_) async => names1);
        when(
          mockDataService.loadNames(region2, gender2),
        ).thenAnswer((_) async => names2);

        // Act
        await nameRepository.getNames(region1, gender1);
        await nameRepository.getNames(region2, gender2);
        final stats = nameRepository.getCacheStats();

        // Assert
        expect(stats['nameCache']['size'], equals(2));
        expect(stats['nameCache']['totalNames'], equals(3));
        expect(stats, containsPair('generationHistory', isA<Map>()));
        expect(stats, containsPair('weights', isA<Map>()));
      });
    });
  });
}
