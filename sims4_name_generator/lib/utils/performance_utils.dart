import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility class for performance optimizations
class PerformanceUtils {
  /// Debounce function calls to prevent excessive executions
  static Timer? _debounceTimer;

  static void debounce({
    required Duration delay,
    required VoidCallback callback,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleTime;

  static void throttle({
    required Duration interval,
    required VoidCallback callback,
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Batch multiple operations together
  static final Map<String, List<VoidCallback>> _batchedOperations = {};
  static final Map<String, Timer> _batchTimers = {};

  static void batch({
    required String key,
    required VoidCallback operation,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _batchedOperations[key] ??= [];
    _batchedOperations[key]!.add(operation);

    _batchTimers[key]?.cancel();
    _batchTimers[key] = Timer(delay, () {
      final operations = _batchedOperations[key] ?? [];
      for (final operation in operations) {
        operation();
      }
      _batchedOperations[key]?.clear();
      _batchTimers.remove(key);
    });
  }

  /// Lazy loading helper
  static Future<T> lazyLoad<T>({
    required Future<T> Function() loader,
    required String cacheKey,
    Duration? cacheDuration,
  }) async {
    final cache = _LazyCache.instance;

    if (cache.has(cacheKey)) {
      final cachedItem = cache.get<T>(cacheKey);
      if (cachedItem != null) {
        return cachedItem;
      }
    }

    final result = await loader();
    cache.set(cacheKey, result, duration: cacheDuration);
    return result;
  }

  /// Memory usage monitoring
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // This would require platform-specific implementation
      // For now, just log the context
      debugPrint('Memory check at: $context');
    }
  }

  /// Widget build optimization - prevent unnecessary rebuilds
  static bool shouldRebuild<T>(T? previous, T current) {
    return previous != current;
  }

  /// Dispose resources properly
  static void disposeResources(List<dynamic> resources) {
    for (final resource in resources) {
      if (resource is Timer) {
        resource.cancel();
      } else if (resource is StreamSubscription) {
        resource.cancel();
      }
      // Add more resource types as needed
    }
  }

  /// Optimize list operations
  static List<T> optimizedFilter<T>(
    List<T> list,
    bool Function(T) predicate, {
    int? maxResults,
  }) {
    final result = <T>[];
    int count = 0;

    for (final item in list) {
      if (predicate(item)) {
        result.add(item);
        count++;
        if (maxResults != null && count >= maxResults) {
          break;
        }
      }
    }

    return result;
  }

  /// Chunk large operations
  static Future<List<T>> processInChunks<T, R>(
    List<T> items,
    Future<R> Function(T) processor, {
    int chunkSize = 10,
    Duration delay = const Duration(milliseconds: 1),
  }) async {
    final results = <T>[];

    for (int i = 0; i < items.length; i += chunkSize) {
      final chunk = items.skip(i).take(chunkSize);

      for (final item in chunk) {
        await processor(item);
        results.add(item);
      }

      if (i + chunkSize < items.length) {
        await Future.delayed(delay);
      }
    }

    return results;
  }
}

/// Simple cache implementation for lazy loading
class _LazyCache {
  static final _LazyCache _instance = _LazyCache._internal();
  static _LazyCache get instance => _instance;

  _LazyCache._internal();

  final Map<String, _CacheItem> _cache = {};

  bool has(String key) {
    final item = _cache[key];
    if (item == null) return false;

    if (item.expiresAt != null && DateTime.now().isAfter(item.expiresAt!)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  T? get<T>(String key) {
    if (!has(key)) return null;
    return _cache[key]?.value as T?;
  }

  void set<T>(String key, T value, {Duration? duration}) {
    final expiresAt = duration != null ? DateTime.now().add(duration) : null;

    _cache[key] = _CacheItem(value, expiresAt);
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  int get size => _cache.length;
}

class _CacheItem {
  final dynamic value;
  final DateTime? expiresAt;

  _CacheItem(this.value, this.expiresAt);
}

/// Mixin for widgets that need performance optimizations
mixin PerformanceOptimizedWidget {
  final Map<String, dynamic> _previousValues = {};

  bool hasChanged<T>(String key, T value) {
    final previous = _previousValues[key] as T?;
    final changed = previous != value;
    if (changed) {
      _previousValues[key] = value;
    }
    return changed;
  }

  void clearCache() {
    _previousValues.clear();
  }
}

/// Performance monitoring
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void start(String operation) {
    _stopwatches[operation] = Stopwatch()..start();
  }

  static void stop(String operation) {
    final stopwatch = _stopwatches[operation];
    if (stopwatch != null) {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('$operation took: ${stopwatch.elapsedMilliseconds}ms');
      }
      _stopwatches.remove(operation);
    }
  }

  static void measure(String operation, VoidCallback callback) {
    start(operation);
    callback();
    stop(operation);
  }

  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() callback,
  ) async {
    start(operation);
    final result = await callback();
    stop(operation);
    return result;
  }
}
