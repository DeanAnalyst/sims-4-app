import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/utils/performance_utils.dart';

void main() {
  group('PerformanceUtils Tests', () {
    test('should filter items correctly with optimizedFilter', () {
      final items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      final evenNumbers = PerformanceUtils.optimizedFilter(
        items,
        (item) => item % 2 == 0,
        maxResults: 3,
      );

      expect(evenNumbers.length, equals(3));
      expect(evenNumbers, contains(2));
      expect(evenNumbers, contains(4));
      expect(evenNumbers, contains(6));
    });

    test('should handle empty list in optimizedFilter', () {
      final emptyList = <int>[];

      final result = PerformanceUtils.optimizedFilter(
        emptyList,
        (item) => true,
        maxResults: 5,
      );

      expect(result, isEmpty);
    });

    test('should process items in chunks correctly', () async {
      final items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final processedItems = <int>[];

      await PerformanceUtils.processInChunks<int, void>(
        items,
        (item) async {
          processedItems.add(item * 2);
        },
        chunkSize: 3,
        delay: const Duration(milliseconds: 1),
      );

      expect(processedItems.length, equals(10));
      expect(processedItems, contains(2)); // 1 * 2
      expect(processedItems, contains(20)); // 10 * 2
    });

    test('should handle empty list in processInChunks', () async {
      final emptyList = <int>[];
      final processedItems = <int>[];

      await PerformanceUtils.processInChunks<int, void>(emptyList, (
        item,
      ) async {
        processedItems.add(item);
      }, chunkSize: 3);

      expect(processedItems, isEmpty);
    });

    test('should log memory usage without throwing', () {
      expect(
        () => PerformanceUtils.logMemoryUsage('test_operation'),
        returnsNormally,
      );
    });

    test('should determine rebuild necessity correctly', () {
      expect(PerformanceUtils.shouldRebuild(null, 'new_value'), isTrue);
      expect(PerformanceUtils.shouldRebuild('same', 'same'), isFalse);
      expect(PerformanceUtils.shouldRebuild('old', 'new'), isTrue);
    });

    test('should dispose resources correctly', () {
      // This test mainly ensures the method doesn't throw
      expect(() => PerformanceUtils.disposeResources([]), returnsNormally);
    });
  });

  group('PerformanceOptimizedWidget Tests', () {
    test('should track changes correctly', () {
      final widget = TestPerformanceWidget();

      // Initially no changes
      expect(widget.hasChanged('test_key', 'value1'), isTrue);

      // Same value should not be considered changed
      expect(widget.hasChanged('test_key', 'value1'), isFalse);

      // Different value should be considered changed
      expect(widget.hasChanged('test_key', 'value2'), isTrue);
    });

    test('should clear cache correctly', () {
      final widget = TestPerformanceWidget();

      // Set some values
      widget.hasChanged('key1', 'value1');
      widget.hasChanged('key2', 'value2');

      // Clear cache
      widget.clearCache();

      // Should be considered changed again after clearing
      expect(widget.hasChanged('key1', 'value1'), isTrue);
      expect(widget.hasChanged('key2', 'value2'), isTrue);
    });
  });

  group('PerformanceMonitor Tests', () {
    test('should measure sync operations', () {
      var executed = false;
      PerformanceMonitor.measure('test_operation', () {
        executed = true;
      });

      expect(executed, isTrue);
    });

    test('should measure async operations', () async {
      final result = await PerformanceMonitor.measureAsync(
        'test_async',
        () async {
          await Future.delayed(const Duration(milliseconds: 1));
          return 'completed';
        },
      );

      expect(result, equals('completed'));
    });

    test('should handle exceptions in sync operations', () {
      expect(() {
        PerformanceMonitor.measure('test_error', () {
          throw Exception('Test error');
        });
      }, throwsException);
    });

    test('should handle exceptions in async operations', () async {
      expect(() async {
        await PerformanceMonitor.measureAsync('test_async_error', () async {
          throw Exception('Test async error');
        });
      }, throwsException);
    });

    test('should start and stop operations', () {
      expect(() {
        PerformanceMonitor.start('test_op');
        PerformanceMonitor.stop('test_op');
      }, returnsNormally);
    });
  });
}

// Test implementation of PerformanceOptimizedWidget
class TestPerformanceWidget with PerformanceOptimizedWidget {
  // Expose the protected methods for testing
  @override
  bool hasChanged<T>(String key, T value) {
    return super.hasChanged(key, value);
  }

  @override
  void clearCache() {
    super.clearCache();
  }
}
