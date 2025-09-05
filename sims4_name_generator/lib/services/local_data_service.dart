import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/name.dart';
import '../models/trait.dart';
import '../models/enums.dart';
import '../utils/performance_utils.dart';
import 'data_service.dart';

/// Local implementation of DataService that loads data from JSON assets
/// Optimized with caching, lazy loading, and performance monitoring
class LocalDataService implements DataService {
  final AssetBundle _assetBundle;
  final Map<String, List<Name>> _nameCache = {};
  List<Trait>? _traitsCache;

  // Performance tracking
  static const String _loadNamesOperation = 'load_names';
  static const String _loadTraitsOperation = 'load_traits';
  static const String _parseJsonOperation = 'parse_json';

  LocalDataService([AssetBundle? assetBundle])
    : _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<void> initializeData() async {
    return PerformanceMonitor.measureAsync('initialize_data', () async {
      // Pre-load traits since they're used frequently
      await loadTraits();

      // Pre-load most common regions to improve first-time experience
      final commonRegions = [
        Region.english,
        Region.northAfrican,
        Region.eastAsian,
      ];
      final commonGenders = [Gender.male, Gender.female];

      for (final region in commonRegions) {
        for (final gender in commonGenders) {
          try {
            await loadNames(region, gender);
          } catch (e) {
            // Continue loading other regions even if one fails
            debugPrint('Failed to preload $region $gender: $e');
          }
        }
      }
    });
  }

  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    return PerformanceMonitor.measureAsync(_loadNamesOperation, () async {
      final cacheKey = '${region.name}_${gender.name}';

      // Return cached data if available
      if (_nameCache.containsKey(cacheKey)) {
        return _nameCache[cacheKey]!;
      }

      // Use lazy loading with cache
      return PerformanceUtils.lazyLoad<List<Name>>(
        cacheKey: cacheKey,
        cacheDuration: const Duration(hours: 1), // Cache for 1 hour
        loader: () => _loadNamesFromAsset(region, gender, cacheKey),
      );
    });
  }

  Future<List<Name>> _loadNamesFromAsset(
    Region region,
    Gender gender,
    String cacheKey,
  ) async {
    try {
      // Load the JSON file for the specific region and gender
      final fileName = '${region.name}_${gender.name}.json';
      final jsonString = await _assetBundle.loadString(
        'assets/data/names/$fileName',
      );

      // Parse JSON in chunks to avoid blocking the UI
      final names = await _parseNamesJson(jsonString, region, gender);

      // Cache the results
      _nameCache[cacheKey] = names;

      return names;
    } on FlutterError {
      throw Exception(
        'Failed to load names file for $region $gender: Asset not found',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Failed to parse names data for $region $gender: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unexpected error loading names for $region $gender: $e');
    }
  }

  Future<List<Name>> _parseNamesJson(
    String jsonString,
    Region region,
    Gender gender,
  ) async {
    return PerformanceMonitor.measureAsync(_parseJsonOperation, () async {
      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate required fields
      if (!jsonData.containsKey('firstNames') ||
          !jsonData.containsKey('lastNames')) {
        throw FormatException(
          'Invalid JSON format: missing firstNames or lastNames',
        );
      }

      final List<String> firstNames = List<String>.from(jsonData['firstNames']);
      final List<String> lastNames = List<String>.from(jsonData['lastNames']);

      // Validate data
      if (firstNames.isEmpty || lastNames.isEmpty) {
        throw FormatException('Invalid data: empty name lists');
      }

      // Generate Name objects by combining first and last names
      // Process in chunks to avoid blocking the UI thread
      final List<Name> names = [];

      await PerformanceUtils.processInChunks<String, void>(
        firstNames,
        (firstName) async {
          for (final lastName in lastNames) {
            names.add(
              Name(
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                region: region,
              ),
            );
          }
        },
        chunkSize: 50, // Process 50 first names at a time
        delay: const Duration(
          microseconds: 100,
        ), // Small delay to prevent blocking
      );

      return names;
    });
  }

  @override
  Future<List<Trait>> loadTraits() async {
    return PerformanceMonitor.measureAsync(_loadTraitsOperation, () async {
      // Return cached data if available
      if (_traitsCache != null) {
        return _traitsCache!;
      }

      // Use lazy loading with cache
      return PerformanceUtils.lazyLoad<List<Trait>>(
        cacheKey: 'traits',
        cacheDuration: const Duration(hours: 2), // Cache for 2 hours
        loader: () => _loadTraitsFromAsset(),
      );
    });
  }

  Future<List<Trait>> _loadTraitsFromAsset() async {
    try {
      // Load the traits JSON file
      final jsonString = await _assetBundle.loadString(
        'assets/data/traits/traits.json',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate required fields
      if (!jsonData.containsKey('traits')) {
        throw FormatException('Invalid JSON format: missing traits array');
      }

      final List<dynamic> traitsJson = jsonData['traits'];

      // Convert JSON to Trait objects in chunks
      final List<Trait> traits = [];

      await PerformanceUtils.processInChunks<dynamic, void>(
        traitsJson,
        (traitJson) async {
          try {
            traits.add(Trait.fromJson(traitJson as Map<String, dynamic>));
          } catch (e) {
            throw FormatException('Invalid trait data: $e');
          }
        },
        chunkSize: 20, // Process 20 traits at a time
      );

      // Validate data
      if (traits.isEmpty) {
        throw FormatException('Invalid data: empty traits list');
      }

      // Cache the results
      _traitsCache = traits;

      return traits;
    } on FlutterError {
      throw Exception('Failed to load traits file: Asset not found');
    } on FormatException catch (e) {
      throw Exception('Failed to parse traits data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading traits: $e');
    }
  }

  /// Clear all cached data (useful for testing)
  void clearCache() {
    _nameCache.clear();
    _traitsCache = null;
    PerformanceUtils.logMemoryUsage('cache_cleared');
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'nameCache': {
        'size': _nameCache.length,
        'keys': _nameCache.keys.toList(),
      },
      'traitsCache': {
        'loaded': _traitsCache != null,
        'count': _traitsCache?.length ?? 0,
      },
    };
  }
}
