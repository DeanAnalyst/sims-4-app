import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';

import 'name_repository_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  group('NameRepository', () {
    late MockDataService mockDataService;
    late NameRepository nameRepository;

    setUp(() {
      mockDataService = MockDataService();
      nameRepository = NameRepository(mockDataService);
    });

    group('getNames', () {
      test('should return names from data service on first call', () async {
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

      test('should return cached names on subsequent calls', () async {
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
        await nameRepository.getNames(region, gender); // First call
        final result = await nameRepository.getNames(
          region,
          gender,
        ); // Second call

        // Assert
        expect(result, equals(expectedNames));
        verify(
          mockDataService.loadNames(region, gender),
        ).called(1); // Only called once
      });

      test('should throw exception when data service fails', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const errorMessage = 'Data service error';

        when(
          mockDataService.loadNames(region, gender),
        ).thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => nameRepository.getNames(region, gender),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load names for $region $gender'),
            ),
          ),
        );
      });
    });

    group('generateRandomName', () {
      test('should return a random name from available names', () async {
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
        expect(availableNames.contains(result), isTrue);
        expect(result.region, equals(region));
        expect(result.gender, equals(gender));
      });

      test('should throw exception when no names are available', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => <Name>[]);

        // Act & Assert
        expect(
          () => nameRepository.generateRandomName(region, gender),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No names available for $region $gender'),
            ),
          ),
        );
      });
    });

    group('generateRandomNames', () {
      test('should return requested number of unique names', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;
        const count = 2;
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
            lastName: 'Williams',
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
          count,
        );

        // Assert
        expect(result.length, equals(count));
        expect(result.toSet().length, equals(count)); // Ensure uniqueness
        for (final name in result) {
          expect(availableNames.contains(name), isTrue);
        }
      });

      test(
        'should return all names when count exceeds available names',
        () async {
          // Arrange
          const region = Region.english;
          const gender = Gender.male;
          const count = 5;
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
          final result = await nameRepository.generateRandomNames(
            region,
            gender,
            count,
          );

          // Assert
          expect(result.length, equals(availableNames.length));
          expect(result.toSet().length, equals(availableNames.length));
        },
      );

      test('should throw ArgumentError for non-positive count', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        // Act & Assert
        expect(
          () => nameRepository.generateRandomNames(region, gender, 0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => nameRepository.generateRandomNames(region, gender, -1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getNameCount', () {
      test('should return correct count of available names', () async {
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
        final result = await nameRepository.getNames(region, gender);

        // Assert
        expect(result, hasLength(2));
      });
    });

    group('hasNames', () {
      test('should return true when names are available', () async {
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
        final result = await nameRepository.getNames(region, gender);

        // Assert
        expect(result, isNotEmpty);
      });

      test('should return false when no names are available', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockDataService.loadNames(region, gender),
        ).thenAnswer((_) async => <Name>[]);

        // Act
        final result = await nameRepository.hasNames(region, gender);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when data service throws exception', () async {
        // Arrange
        const region = Region.english;
        const gender = Gender.male;

        when(
          mockDataService.loadNames(region, gender),
        ).thenThrow(Exception('Data service error'));

        // Act
        final result = await nameRepository.hasNames(region, gender);

        // Assert
        expect(result, isFalse);
      });
    });

    group('clearCache', () {
      test('should clear cached data and reload from service', () async {
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
    });

    group('getCacheStats', () {
      test('should return correct cache statistics', () async {
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
      });
    });
  });
}
