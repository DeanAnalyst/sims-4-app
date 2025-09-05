import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Comprehensive performance monitoring service
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  static PerformanceMonitoringService get instance => _instance;

  PerformanceMonitoringService._internal();

  // Performance tracking
  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};

  // Memory tracking
  final List<MemorySnapshot> _memorySnapshots = [];
  Timer? _memoryTrackingTimer;

  // Performance thresholds
  static const Duration _slowOperationThreshold = Duration(milliseconds: 100);
  static const Duration _verySlowOperationThreshold = Duration(
    milliseconds: 500,
  );
  static const int _maxMemorySnapshots = 100;
  static const Duration _memoryTrackingInterval = Duration(seconds: 30);

  /// Start monitoring an operation
  void startOperation(String operationName) {
    _stopwatches[operationName] = Stopwatch()..start();
  }

  /// End monitoring an operation
  void endOperation(String operationName) {
    final stopwatch = _stopwatches[operationName];
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsed;

      // Track operation times
      _operationTimes[operationName] ??= [];
      _operationTimes[operationName]!.add(duration);

      // Track operation counts
      _operationCounts[operationName] =
          (_operationCounts[operationName] ?? 0) + 1;

      // Log slow operations
      if (duration > _verySlowOperationThreshold) {
        _logSlowOperation(operationName, duration, 'VERY_SLOW');
      } else if (duration > _slowOperationThreshold) {
        _logSlowOperation(operationName, duration, 'SLOW');
      }

      // Clean up stopwatch
      _stopwatches.remove(operationName);
    }
  }

  /// Measure operation with automatic start/stop
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startOperation(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }

  /// Measure synchronous operation
  T measureSyncOperation<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      final result = operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }

  /// Log slow operation
  void _logSlowOperation(
    String operationName,
    Duration duration,
    String severity,
  ) {
    if (kDebugMode) {
      developer.log(
        'Performance Warning: $operationName took ${duration.inMilliseconds}ms ($severity)',
        name: 'PerformanceMonitor',
        level: severity == 'VERY_SLOW' ? 900 : 800,
      );
    }
  }

  /// Start memory tracking
  void startMemoryTracking() {
    _memoryTrackingTimer?.cancel();
    _memoryTrackingTimer = Timer.periodic(_memoryTrackingInterval, (timer) {
      _takeMemorySnapshot();
    });
  }

  /// Stop memory tracking
  void stopMemoryTracking() {
    _memoryTrackingTimer?.cancel();
    _memoryTrackingTimer = null;
  }

  /// Take memory snapshot
  void _takeMemorySnapshot() {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      memoryUsage: _getCurrentMemoryUsage(),
    );

    _memorySnapshots.add(snapshot);

    // Limit memory snapshots
    if (_memorySnapshots.length > _maxMemorySnapshots) {
      _memorySnapshots.removeAt(0);
    }

    // Check for memory leaks
    _checkForMemoryLeaks();
  }

  /// Get current memory usage (platform-specific)
  double _getCurrentMemoryUsage() {
    // This would require platform-specific implementation
    // For now, return a placeholder value
    return 0.0;
  }

  /// Check for potential memory leaks
  void _checkForMemoryLeaks() {
    if (_memorySnapshots.length < 10) return;

    final recentSnapshots = _memorySnapshots
        .skip(_memorySnapshots.length - 10)
        .toList();
    final firstUsage = recentSnapshots.first.memoryUsage;
    final lastUsage = recentSnapshots.last.memoryUsage;

    // Check if memory usage is consistently increasing
    if (lastUsage > firstUsage * 1.5) {
      if (kDebugMode) {
        developer.log(
          'Potential memory leak detected: Memory usage increased from ${firstUsage.toStringAsFixed(2)}MB to ${lastUsage.toStringAsFixed(2)}MB',
          name: 'PerformanceMonitor',
          level: 900,
        );
      }
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _operationTimes.entries) {
      final operationName = entry.key;
      final times = entry.value;
      final count = _operationCounts[operationName] ?? 0;

      if (times.isNotEmpty) {
        final avgTime =
            times.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
            times.length;
        final minTime = times
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a < b ? a : b);
        final maxTime = times
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a > b ? a : b);

        stats[operationName] = {
          'count': count,
          'avgTimeMs': avgTime / 1000,
          'minTimeMs': minTime / 1000,
          'maxTimeMs': maxTime / 1000,
          'totalTimeMs': times
              .map((d) => d.inMilliseconds)
              .reduce((a, b) => a + b),
        };
      }
    }

    return stats;
  }

  /// Get memory statistics
  Map<String, dynamic> getMemoryStats() {
    if (_memorySnapshots.isEmpty) {
      return {'error': 'No memory data available'};
    }

    final currentUsage = _memorySnapshots.last.memoryUsage;
    final peakUsage = _memorySnapshots
        .map((s) => s.memoryUsage)
        .reduce((a, b) => a > b ? a : b);
    final avgUsage =
        _memorySnapshots.map((s) => s.memoryUsage).reduce((a, b) => a + b) /
        _memorySnapshots.length;

    return {
      'currentUsageMB': currentUsage,
      'peakUsageMB': peakUsage,
      'averageUsageMB': avgUsage,
      'snapshotCount': _memorySnapshots.length,
      'trackingDuration': _memorySnapshots.last.timestamp
          .difference(_memorySnapshots.first.timestamp)
          .inMinutes,
    };
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final stats = getPerformanceStats();

    for (final entry in stats.entries) {
      final operationName = entry.key;
      final operationStats = entry.value as Map<String, dynamic>;
      final avgTimeMs = operationStats['avgTimeMs'] as double;
      final count = operationStats['count'] as int;

      if (avgTimeMs > _verySlowOperationThreshold.inMilliseconds) {
        recommendations.add(
          'Optimize $operationName: Average time ${avgTimeMs.toStringAsFixed(2)}ms is very slow',
        );
      } else if (avgTimeMs > _slowOperationThreshold.inMilliseconds) {
        recommendations.add(
          'Consider optimizing $operationName: Average time ${avgTimeMs.toStringAsFixed(2)}ms is slow',
        );
      }

      if (count > 100) {
        recommendations.add(
          'High frequency operation: $operationName called $count times - consider caching',
        );
      }
    }

    // Memory recommendations
    final memoryStats = getMemoryStats();
    if (memoryStats.containsKey('currentUsageMB')) {
      final currentUsage = memoryStats['currentUsageMB'] as double;
      if (currentUsage > 100) {
        recommendations.add(
          'High memory usage: ${currentUsage.toStringAsFixed(2)}MB - consider memory optimization',
        );
      }
    }

    return recommendations;
  }

  /// Clear performance data
  void clearPerformanceData() {
    _stopwatches.clear();
    _operationTimes.clear();
    _operationCounts.clear();
    _memorySnapshots.clear();
  }

  /// Generate performance report
  Map<String, dynamic> generatePerformanceReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'performanceStats': getPerformanceStats(),
      'memoryStats': getMemoryStats(),
      'recommendations': getPerformanceRecommendations(),
      'activeOperations': _stopwatches.keys.toList(),
    };
  }

  /// Dispose resources
  void dispose() {
    stopMemoryTracking();
    clearPerformanceData();
  }
}

/// Memory snapshot data
class MemorySnapshot {
  final DateTime timestamp;
  final double memoryUsage;

  MemorySnapshot({required this.timestamp, required this.memoryUsage});
}

/// Performance monitoring mixin for widgets
mixin PerformanceMonitoringMixin {
  final Map<String, Stopwatch> _widgetStopwatches = {};

  /// Start monitoring widget operation
  void startWidgetOperation(String operationName) {
    _widgetStopwatches[operationName] = Stopwatch()..start();
  }

  /// End monitoring widget operation
  void endWidgetOperation(String operationName) {
    final stopwatch = _widgetStopwatches[operationName];
    if (stopwatch != null) {
      stopwatch.stop();
      PerformanceMonitoringService.instance.endOperation(
        'widget_$operationName',
      );
      _widgetStopwatches.remove(operationName);
    }
  }

  /// Measure widget operation
  Future<T> measureWidgetOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startWidgetOperation(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      endWidgetOperation(operationName);
    }
  }

  /// Dispose widget monitoring
  void disposeWidgetMonitoring() {
    _widgetStopwatches.clear();
  }
}

/// Performance monitoring extension for common operations
extension PerformanceMonitoringExtension on Object {
  /// Measure operation with automatic naming
  Future<T> measureOperation<T>(Future<T> Function() operation) async {
    final operationName =
        '${runtimeType}_${DateTime.now().millisecondsSinceEpoch}';
    return PerformanceMonitoringService.instance.measureOperation(
      operationName,
      operation,
    );
  }

  /// Measure synchronous operation with automatic naming
  T measureSyncOperation<T>(T Function() operation) {
    final operationName =
        '${runtimeType}_${DateTime.now().millisecondsSinceEpoch}';
    return PerformanceMonitoringService.instance.measureSyncOperation(
      operationName,
      operation,
    );
  }
}
