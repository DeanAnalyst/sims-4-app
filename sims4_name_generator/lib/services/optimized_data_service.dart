import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import '../models/name.dart';
import '../models/trait.dart';
import '../models/enums.dart';
import '../utils/performance_utils.dart';

/// Optimized data service with efficient JSON parsing and memory management
class OptimizedDataService {
  static const String _namesPath = 'assets/data/names/';
  static const String _traitsPath = 'assets/data/traits/traits.json';

  // Memory-managed cache with size limits
  final Map<String, List<Name>> _nameCache = {};
  final Map<String, DateTime> _nameCacheTimestamps = {};
  List<Trait>? _traitsCache;
  DateTime? _traitsCacheTimestamp;

  // Cache configuration
  static const int _maxNameCacheSize = 10; // Max regions/genders cached
  static const Duration _nameCacheExpiry = Duration(minutes: 30);
  static const Duration _traitsCacheExpiry = Duration(hours: 2);

  // Background processing
  final Map<String, Future<List<Name>>> _loadingOperations = {};
  Future<List<Trait>>? _traitsLoadingOperation;

  /// Load names for a specific region and gender with optimized caching
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    return PerformanceMonitor.measureAsync('load_names_optimized', () async {
      final cacheKey = '${region.name}_${gender.name}';

      // Check if already loading
      if (_loadingOperations.containsKey(cacheKey)) {
        return await _loadingOperations[cacheKey]!;
      }

      // Check cache first
      if (_isNameCacheValid(cacheKey)) {
        return _nameCache[cacheKey]!;
      }

      // Start loading operation
      final loadingFuture = _loadNamesFromAssets(region, gender);
      _loadingOperations[cacheKey] = loadingFuture;

      try {
        final names = await loadingFuture;
        _updateNameCache(cacheKey, names);
        return names;
      } finally {
        _loadingOperations.remove(cacheKey);
      }
    });
  }

  /// Load all traits with optimized caching
  Future<List<Trait>> loadTraits() async {
    return PerformanceMonitor.measureAsync('load_traits_optimized', () async {
      // Check if already loading
      if (_traitsLoadingOperation != null) {
        return await _traitsLoadingOperation!;
      }

      // Check cache first
      if (_isTraitsCacheValid()) {
        return _traitsCache!;
      }

      // Start loading operation
      _traitsLoadingOperation = _loadTraitsFromAssets();

      try {
        final traits = await _traitsLoadingOperation!;
        _updateTraitsCache(traits);
        return traits;
      } finally {
        _traitsLoadingOperation = null;
      }
    });
  }

  /// Load names from assets with background processing
  Future<List<Name>> _loadNamesFromAssets(Region region, Gender gender) async {
    final fileName = '${region.name}_${gender.name}.json';
    final filePath = '$_namesPath$fileName';

    try {
      // Load raw bytes for better performance
      final ByteData data = await rootBundle.load(filePath);
      final String jsonString = utf8.decode(data.buffer.asUint8List());

      // Parse JSON in background isolate for large files
      if (jsonString.length > 10000) {
        // Large file threshold
        return await _parseNamesInBackground(jsonString);
      } else {
        return _parseNamesJson(jsonString);
      }
    } catch (e) {
      throw Exception('Failed to load names from $filePath: $e');
    }
  }

  /// Load traits from assets with optimized parsing
  Future<List<Trait>> _loadTraitsFromAssets() async {
    try {
      final ByteData data = await rootBundle.load(_traitsPath);
      final String jsonString = utf8.decode(data.buffer.asUint8List());

      // Parse JSON in background isolate for large trait files
      if (jsonString.length > 5000) {
        return await _parseTraitsInBackground(jsonString);
      } else {
        return _parseTraitsJson(jsonString);
      }
    } catch (e) {
      throw Exception('Failed to load traits: $e');
    }
  }

  /// Parse names JSON in background isolate
  Future<List<Name>> _parseNamesInBackground(String jsonString) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_parseNamesIsolate, {
      'jsonString': jsonString,
      'sendPort': receivePort.sendPort,
    });

    final result = await receivePort.first as List<Name>;
    receivePort.close();
    return result;
  }

  /// Parse traits JSON in background isolate
  Future<List<Trait>> _parseTraitsInBackground(String jsonString) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_parseTraitsIsolate, {
      'jsonString': jsonString,
      'sendPort': receivePort.sendPort,
    });

    final result = await receivePort.first as List<Trait>;
    receivePort.close();
    return result;
  }

  /// Parse names JSON synchronously
  List<Name> _parseNamesJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> namesList = json['names'] ?? [];

    return namesList.map((nameJson) {
      return Name.fromJson(nameJson as Map<String, dynamic>);
    }).toList();
  }

  /// Parse traits JSON synchronously
  List<Trait> _parseTraitsJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> traitsList = json['traits'] ?? [];

    return traitsList.map((traitJson) {
      return Trait.fromJson(traitJson as Map<String, dynamic>);
    }).toList();
  }

  /// Check if name cache is valid
  bool _isNameCacheValid(String cacheKey) {
    if (!_nameCache.containsKey(cacheKey)) return false;

    final timestamp = _nameCacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _nameCacheExpiry;
  }

  /// Check if traits cache is valid
  bool _isTraitsCacheValid() {
    if (_traitsCache == null || _traitsCacheTimestamp == null) return false;

    return DateTime.now().difference(_traitsCacheTimestamp!) <
        _traitsCacheExpiry;
  }

  /// Update name cache with memory management
  void _updateNameCache(String cacheKey, List<Name> names) {
    // Manage cache size
    if (_nameCache.length >= _maxNameCacheSize) {
      _evictOldestNameCache();
    }

    _nameCache[cacheKey] = names;
    _nameCacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Update traits cache
  void _updateTraitsCache(List<Trait> traits) {
    _traitsCache = traits;
    _traitsCacheTimestamp = DateTime.now();
  }

  /// Evict oldest cache entry when cache is full
  void _evictOldestNameCache() {
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _nameCacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _nameCache.remove(oldestKey);
      _nameCacheTimestamps.remove(oldestKey);
    }
  }

  /// Clear all caches
  void clearCache() {
    _nameCache.clear();
    _nameCacheTimestamps.clear();
    _traitsCache = null;
    _traitsCacheTimestamp = null;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'nameCacheSize': _nameCache.length,
      'nameCacheKeys': _nameCache.keys.toList(),
      'traitsCacheValid': _isTraitsCacheValid(),
      'loadingOperations': _loadingOperations.length,
      'traitsLoading': _traitsLoadingOperation != null,
    };
  }

  /// Preload frequently used data
  Future<void> preloadCommonData() async {
    // Preload English names (most commonly used)
    await Future.wait([
      loadNames(Region.english, Gender.male),
      loadNames(Region.english, Gender.female),
    ]);

    // Preload traits
    await loadTraits();
  }

  /// Initialize data service
  Future<void> initialize() async {
    // Preload common data in background
    unawaited(preloadCommonData());
  }
}

/// Background isolate function for parsing names
void _parseNamesIsolate(Map<String, dynamic> params) {
  final jsonString = params['jsonString'] as String;
  final sendPort = params['sendPort'] as SendPort;

  try {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> namesList = json['names'] ?? [];

    final names = namesList.map((nameJson) {
      return Name.fromJson(nameJson as Map<String, dynamic>);
    }).toList();

    sendPort.send(names);
  } catch (e) {
    sendPort.send(<Name>[]); // Return empty list on error
  }
}

/// Background isolate function for parsing traits
void _parseTraitsIsolate(Map<String, dynamic> params) {
  final jsonString = params['jsonString'] as String;
  final sendPort = params['sendPort'] as SendPort;

  try {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> traitsList = json['traits'] ?? [];

    final traits = traitsList.map((traitJson) {
      return Trait.fromJson(traitJson as Map<String, dynamic>);
    }).toList();

    sendPort.send(traits);
  } catch (e) {
    sendPort.send(<Trait>[]); // Return empty list on error
  }
}
