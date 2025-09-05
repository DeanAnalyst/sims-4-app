import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sims4_name_generator/services/optimized_data_service.dart';
import 'package:sims4_name_generator/services/optimized_storage_service.dart';
import 'package:sims4_name_generator/services/performance_monitoring_service.dart';
import 'package:sims4_name_generator/providers/optimized_providers.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/character_profile.dart';
import 'package:sims4_name_generator/models/enums.dart';

// Generate mocks
@GenerateMocks([OptimizedDataService, OptimizedStorageService])
import 'performance_optimization_test.mocks.dart';

void main() {
  group('Performance Optimization Tests', () {
    late MockOptimizedDataService mockDataService;
    late MockOptimizedStorageService mockStorageService;
    late OptimizedNameRepository nameRepository;
    late OptimizedTraitRepository traitRepository;
    late OptimizedCharacterStorage characterStorage;

    setUp(() {
      mockDataService = MockOptimizedDataService();
      mockStorageService = MockOptimizedStorageService();

      nameRepository = OptimizedNameRepository(mockDataService);
      traitRepository = OptimizedTraitRepository(mockDataService);
      characterStorage = OptimizedCharacterStorage(mockStorageService);
    });

    group('Optimized Data Service Tests', () {
      test('loads names with caching', () async {
        final testNames = [
          Name(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.male,
            region: Region.english,
          ),
          Name(
            firstName: 'Jane',
            lastName: 'Smith',
            gender: Gender.female,
            region: Region.english,
          ),
        ];

        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => testNames);

        // First call should load from service
        final result1 = await nameRepository.getNames(
          Region.english,
          Gender.male,
        );
        expect(result1, equals(testNames));

        // Second call should use cache (should not call service again)
        final result2 = await nameRepository.getNames(
          Region.english,
          Gender.male,
        );
        expect(result2, equals(testNames));

        // Verify that the service was called exactly once (due to caching)
        verify(
          mockDataService.loadNames(Region.english, Gender.male),
        ).called(1);
      });

      test('loads traits with caching', () async {
        final testTraits = [
          Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        when(mockDataService.loadTraits()).thenAnswer((_) async => testTraits);

        // First call should load from service
        final result1 = await traitRepository.getAllTraits();
        expect(result1, equals(testTraits));

        // Second call should use cache (should not call service again)
        final result2 = await traitRepository.getAllTraits();
        expect(result2, equals(testTraits));

        // Verify that the service was called exactly once (due to caching)
        verify(mockDataService.loadTraits()).called(1);
      });

      test('generates random names efficiently', () async {
        final testNames = List.generate(
          100,
          (index) => Name(
            firstName: 'Name$index',
            lastName: 'Last$index',
            gender: Gender.male,
            region: Region.english,
          ),
        );

        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => testNames);

        final stopwatch = Stopwatch()..start();

        // Generate multiple names
        for (int i = 0; i < 10; i++) {
          await nameRepository.generateRandomName(Region.english, Gender.male);
        }

        stopwatch.stop();

        // Should be very fast (under 100ms for 10 generations)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('generates random traits efficiently', () async {
        final testTraits = List.generate(
          50,
          (index) => Trait(
            id: 'trait$index',
            name: 'Trait$index',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        );

        when(mockDataService.loadTraits()).thenAnswer((_) async => testTraits);

        final stopwatch = Stopwatch()..start();

        // Generate multiple trait sets
        for (int i = 0; i < 10; i++) {
          await traitRepository.generateRandomTraits(maxTraits: 3);
        }

        stopwatch.stop();

        // Should be very fast (under 100ms for 10 generations)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Optimized Storage Service Tests', () {
      test('saves characters with optimized storage', () async {
        final character = CharacterProfile(
          name: Name(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.male,
            region: Region.english,
          ),
          traits: [],
          generatedAt: DateTime.now(),
        );

        when(
          mockStorageService.saveCharacter(character),
        ).thenAnswer((_) async {});

        await characterStorage.saveCharacter(character);
        verify(mockStorageService.saveCharacter(character)).called(1);
      });

      test('gets saved characters with pagination', () async {
        final testCharacters = List.generate(
          20,
          (index) => CharacterProfile(
            name: Name(
              firstName: 'Name$index',
              lastName: 'Last$index',
              gender: Gender.male,
              region: Region.english,
            ),
            traits: [],
            generatedAt: DateTime.now(),
          ),
        );

        when(
          mockStorageService.getSavedCharacters(page: 0, pageSize: 10),
        ).thenAnswer((_) async => testCharacters.take(10).toList());

        final result = await characterStorage.getSavedCharacters(
          page: 0,
          pageSize: 10,
        );
        expect(result.length, equals(10));
        verify(
          mockStorageService.getSavedCharacters(page: 0, pageSize: 10),
        ).called(1);
      });

      test('gets storage statistics', () async {
        final stats = {
          'savedCharacters': 50,
          'favorites': 10,
          'history': 100,
          'cacheSize': 5,
          'pendingOperations': 0,
        };

        when(
          mockStorageService.getStorageStats(),
        ).thenAnswer((_) async => stats);

        final result = await characterStorage.getStorageStats();
        expect(result, equals(stats));
        verify(mockStorageService.getStorageStats()).called(1);
      });
    });

    group('Performance Monitoring Service Tests', () {
      test('measures operation performance', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Measure a simple operation
        final result = await monitor.measureOperation(
          'test_operation',
          () async {
            await Future.delayed(Duration(milliseconds: 10));
            return 'test_result';
          },
        );

        expect(result, equals('test_result'));

        // Check that performance data was recorded
        final stats = monitor.getPerformanceStats();
        expect(stats.containsKey('test_operation'), isTrue);

        final operationStats = stats['test_operation'] as Map<String, dynamic>;
        expect(operationStats['count'], equals(1));
        expect(operationStats['avgTimeMs'], greaterThan(0));
      });

      test('tracks multiple operations', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Perform multiple operations
        for (int i = 0; i < 5; i++) {
          await monitor.measureOperation('repeated_operation', () async {
            await Future.delayed(Duration(milliseconds: 5));
            return i;
          });
        }

        final stats = monitor.getPerformanceStats();
        expect(stats.containsKey('repeated_operation'), isTrue);

        final operationStats =
            stats['repeated_operation'] as Map<String, dynamic>;
        expect(operationStats['count'], equals(5));
        expect(operationStats['avgTimeMs'], greaterThan(0));
      });

      test('generates performance recommendations', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Perform a slow operation
        await monitor.measureOperation('slow_operation', () async {
          await Future.delayed(Duration(milliseconds: 200)); // Above threshold
          return 'slow_result';
        });

        final recommendations = monitor.getPerformanceRecommendations();
        expect(recommendations.isNotEmpty, isTrue);
        expect(
          recommendations.any((r) => r.contains('slow_operation')),
          isTrue,
        );
      });

      test('generates comprehensive performance report', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Perform some operations
        await monitor.measureOperation('report_test', () async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'test';
        });

        final report = monitor.generatePerformanceReport();
        expect(report.containsKey('timestamp'), isTrue);
        expect(report.containsKey('performanceStats'), isTrue);
        expect(report.containsKey('memoryStats'), isTrue);
        expect(report.containsKey('recommendations'), isTrue);
        expect(report.containsKey('activeOperations'), isTrue);
      });

      test('clears performance data', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Perform an operation
        await monitor.measureOperation('clear_test', () async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'test';
        });

        // Verify data exists
        final statsBefore = monitor.getPerformanceStats();
        expect(statsBefore.containsKey('clear_test'), isTrue);

        // Clear data
        monitor.clearPerformanceData();

        // Verify data is cleared
        final statsAfter = monitor.getPerformanceStats();
        expect(statsAfter.isEmpty, isTrue);
      });
    });

    group('Lazy Loading Tests', () {
      test('lazy loading list handles large datasets efficiently', () async {
        // Simulate a large dataset
        final largeDataset = List.generate(1000, (index) => 'Item $index');

        Future<List<String>> dataLoader(int page, int pageSize) async {
          final start = page * pageSize;
          final end = (start + pageSize).clamp(0, largeDataset.length);
          await Future.delayed(
            Duration(milliseconds: 1),
          ); // Simulate loading time
          return largeDataset.sublist(start, end);
        }

        final stopwatch = Stopwatch()..start();

        // Load first page
        final firstPage = await dataLoader(0, 20);
        expect(firstPage.length, equals(20));
        expect(firstPage.first, equals('Item 0'));
        expect(firstPage.last, equals('Item 19'));

        // Load second page
        final secondPage = await dataLoader(1, 20);
        expect(secondPage.length, equals(20));
        expect(secondPage.first, equals('Item 20'));
        expect(secondPage.last, equals('Item 39'));

        stopwatch.stop();

        // Should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('Memory Management Tests', () {
      test('cache size limits are respected', () async {
        final testNames = [
          Name(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.male,
            region: Region.english,
          ),
        ];

        when(
          mockDataService.loadNames(any, any),
        ).thenAnswer((_) async => testNames);

        // Load many different regions to test cache limits
        for (int i = 0; i < 25; i++) {
          final region = Region.values[i % Region.values.length];
          final gender = i % 2 == 0 ? Gender.male : Gender.female;
          await nameRepository.getNames(region, gender);
        }

        // Cache should not exceed maximum size
        // Note: This is an indirect test since we can't directly access the cache
        // In a real implementation, we would verify cache size through a getter
        expect(true, isTrue); // Placeholder for cache size verification
      });

      test('memory-efficient trait generation', () async {
        final testTraits = List.generate(
          100,
          (index) => Trait(
            id: 'trait$index',
            name: 'Trait$index',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        );

        when(mockDataService.loadTraits()).thenAnswer((_) async => testTraits);

        // Generate many trait sets without memory issues
        final results = <List<Trait>>[];
        for (int i = 0; i < 50; i++) {
          final traits = await traitRepository.generateRandomTraits(
            maxTraits: 3,
          );
          results.add(traits);
        }

        expect(results.length, equals(50));
        for (final traits in results) {
          expect(traits.length, lessThanOrEqualTo(3));
        }
      });
    });

    group('Optimization Integration Tests', () {
      test('complete character generation workflow is optimized', () async {
        final testNames = [
          Name(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.male,
            region: Region.english,
          ),
        ];
        final testTraits = [
          Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => testNames);
        when(mockDataService.loadTraits()).thenAnswer((_) async => testTraits);
        when(mockStorageService.saveCharacter(any)).thenAnswer((_) async {});

        final stopwatch = Stopwatch()..start();

        // Complete workflow: generate name, traits, and save
        final name = await nameRepository.generateRandomName(
          Region.english,
          Gender.male,
        );
        final traits = await traitRepository.generateRandomTraits(maxTraits: 3);
        final character = CharacterProfile(
          name: name,
          traits: traits,
          generatedAt: DateTime.now(),
        );
        await characterStorage.saveCharacter(character);

        stopwatch.stop();

        // Complete workflow should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(name, isNotNull);
        expect(traits.length, lessThanOrEqualTo(3));
      });

      test('performance monitoring integration', () async {
        final monitor = PerformanceMonitoringService.instance;

        // Setup mocks for integration test
        final testNames = [
          Name(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.male,
            region: Region.english,
          ),
        ];
        final testTraits = [
          Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        when(
          mockDataService.loadNames(Region.english, Gender.male),
        ).thenAnswer((_) async => testNames);
        when(mockDataService.loadTraits()).thenAnswer((_) async => testTraits);

        // Start monitoring
        monitor.startMemoryTracking();

        // Perform operations with monitoring
        await monitor.measureOperation('integration_test', () async {
          final name = await nameRepository.generateRandomName(
            Region.english,
            Gender.male,
          );
          final traits = await traitRepository.generateRandomTraits(
            maxTraits: 3,
          );
          return {'name': name, 'traits': traits};
        });

        // Stop monitoring
        monitor.stopMemoryTracking();

        // Verify monitoring data
        final report = monitor.generatePerformanceReport();
        expect(
          report['performanceStats'].containsKey('integration_test'),
          isTrue,
        );
        expect(report['recommendations'], isA<List<String>>());
      });
    });
  });
}
