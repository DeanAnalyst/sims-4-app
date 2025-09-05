import 'dart:math';
import '../models/name.dart';
import '../models/enums.dart';
import '../services/data_service.dart';
import '../utils/performance_utils.dart';
import '../utils/lithuanian_name_customizer.dart';

/// Repository for managing name data with caching and random generation
/// Enhanced with weighted selection, duplicate avoidance, and performance optimizations
class NameRepository with PerformanceOptimizedWidget {
  final DataService _dataService;
  final Map<String, List<Name>> _nameCache = {};
  final Map<String, List<Name>> _generationHistory = {};
  final Random _random = Random();

  // Weighted selection preferences
  final Map<String, double> _nameWeights = {};
  final Map<Region, double> _regionWeights = {};

  static const int _maxHistorySize = 100;
  static const String _getNamesOperation = 'get_names';
  static const String _generateNameOperation = 'generate_name';

  NameRepository(this._dataService);

  /// Get all names for a specific region and gender
  /// Returns cached data if available, otherwise loads from data service
  Future<List<Name>> getNames(Region region, Gender gender) async {
    return PerformanceMonitor.measureAsync(_getNamesOperation, () async {
      final cacheKey = '${region.name}_${gender.name}';

      // Return cached data if available and hasn't changed
      if (_nameCache.containsKey(cacheKey) &&
          !hasChanged('names_$cacheKey', cacheKey)) {
        return _nameCache[cacheKey]!;
      }

      try {
        // Load names from data service
        final names = await _dataService.loadNames(region, gender);

        // Cache the results
        _nameCache[cacheKey] = names;

        return names;
      } catch (e) {
        throw Exception('Failed to load names for $region $gender: $e');
      }
    });
  }

  /// Check if names are available for a region and gender
  Future<bool> hasNames(Region region, Gender gender) async {
    try {
      final names = await getNames(region, gender);
      return names.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Generate a random name from the specified region and gender
  /// Uses weighted selection if weights are configured
  /// Supports Lithuanian name customization based on life stage and marital status
  Future<Name> generateRandomName(
    Region region,
    Gender gender, {
    bool avoidDuplicates = true,
    int maxAttempts = 10,
    LifeStage? lifeStage,
    MaritalStatus? maritalStatus,
  }) async {
    return PerformanceMonitor.measureAsync(_generateNameOperation, () async {
      final names = await getNames(region, gender);

      if (names.isEmpty) {
        throw Exception('No names available for $region $gender');
      }

      List<Name> availableNames = names;

      // Apply duplicate avoidance if requested
      if (avoidDuplicates) {
        final historyKey = '${region.name}_${gender.name}';
        final history = _generationHistory[historyKey] ?? [];

        // Filter out recently generated names
        availableNames = PerformanceUtils.optimizedFilter(
          names,
          (name) => !history.any((h) => h.fullName == name.fullName),
          maxResults: names.length ~/ 2, // Use up to half the available names
        );

        // If no unique names available, reset history and use all names
        if (availableNames.isEmpty) {
          _generationHistory[historyKey] = [];
          availableNames = names;
        }
      }

      // Select name using weighted selection if weights are configured
      final selectedName = _selectWeightedName(availableNames, region);

      // Apply Lithuanian customization if needed
      final customizedName = _applyLithuanianCustomization(
        selectedName, 
        region, 
        gender, 
        lifeStage, 
        maritalStatus
      );

      // Add to generation history
      _addToHistory(region, gender, customizedName);

      return customizedName;
    });
  }

  /// Generate multiple random names
  /// Ensures no duplicates in the returned list
  Future<List<Name>> generateRandomNames(
    Region region,
    Gender gender,
    int count, {
    bool avoidDuplicates = true,
  }) async {
    if (count <= 0) return [];

    final names = await getNames(region, gender);

    if (names.isEmpty) {
      throw Exception('No names available for $region $gender');
    }

    // If requesting more names than available, return all names shuffled
    if (count >= names.length) {
      final shuffledNames = List<Name>.from(names);
      shuffledNames.shuffle(_random);
      return shuffledNames;
    }

    List<Name> availableNames = List<Name>.from(names);

    // Apply duplicate avoidance if requested
    if (avoidDuplicates) {
      final historyKey = '${region.name}_${gender.name}';
      final history = _generationHistory[historyKey] ?? [];

      // Remove recently generated names from available pool
      availableNames.removeWhere(
        (name) => history.any((h) => h.fullName == name.fullName),
      );

      // If not enough unique names, reset history
      if (availableNames.length < count) {
        _generationHistory[historyKey] = [];
        availableNames = List<Name>.from(names);
      }
    }

    final selectedNames = <Name>[];
    final workingList = List<Name>.from(availableNames);

    // Generate the requested number of unique names
    for (int i = 0; i < count && workingList.isNotEmpty; i++) {
      final selectedName = _selectWeightedName(workingList, region);
      selectedNames.add(selectedName);
      workingList.remove(selectedName);

      // Add to generation history
      _addToHistory(region, gender, selectedName);
    }

    return selectedNames;
  }

  /// Add a name to the generation history
  void _addToHistory(Region region, Gender gender, Name name) {
    final historyKey = '${region.name}_${gender.name}';
    _generationHistory[historyKey] ??= [];

    final history = _generationHistory[historyKey]!;
    history.add(name);

    // Limit history size to prevent memory bloat
    if (history.length > _maxHistorySize) {
      history.removeRange(0, history.length - _maxHistorySize);
    }
  }

  /// Get generation history for a specific region and gender
  List<Name> getGenerationHistory(Region region, Gender gender) {
    final historyKey = '${region.name}_${gender.name}';
    return List<Name>.from(_generationHistory[historyKey] ?? []);
  }

  /// Clear generation history for a specific region and gender
  void clearHistory(Region region, Gender gender) {
    final historyKey = '${region.name}_${gender.name}';
    _generationHistory[historyKey] = [];
  }

  /// Clear all generation history
  void clearAllHistory() {
    _generationHistory.clear();
  }

  /// Set weight for a specific name (affects random selection probability)
  void setNameWeight(String fullName, double weight) {
    _nameWeights[fullName] = weight.clamp(0.0, 10.0);
  }

  /// Set weight for a specific region (affects random selection probability)
  void setRegionWeight(Region region, double weight) {
    _regionWeights[region] = weight.clamp(0.0, 10.0);
  }

  /// Select a name using weighted random selection
  Name _selectWeightedName(List<Name> names, Region region) {
    if (names.isEmpty) {
      throw Exception('Cannot select from empty name list');
    }

    // If no weights configured, use simple random selection
    if (_nameWeights.isEmpty && _regionWeights.isEmpty) {
      return names[_random.nextInt(names.length)];
    }

    // Calculate weights for each name
    final weights = <double>[];
    double totalWeight = 0.0;

    for (final name in names) {
      double weight = 1.0; // Base weight

      // Apply name-specific weight
      final nameWeight = _nameWeights[name.fullName];
      if (nameWeight != null) {
        weight *= nameWeight;
      }

      // Apply region-specific weight
      final regionWeight = _regionWeights[region];
      if (regionWeight != null) {
        weight *= regionWeight;
      }

      weights.add(weight);
      totalWeight += weight;
    }

    // Select based on weighted probability
    if (totalWeight <= 0) {
      return names[_random.nextInt(names.length)];
    }

    final randomValue = _random.nextDouble() * totalWeight;
    double currentWeight = 0.0;

    for (int i = 0; i < names.length; i++) {
      currentWeight += weights[i];
      if (randomValue <= currentWeight) {
        return names[i];
      }
    }

    // Fallback (should not reach here)
    return names.last;
  }

  /// Get all available regions that have name data
  Future<List<Region>> getAvailableRegions() async {
    final availableRegions = <Region>[];

    for (final region in Region.values) {
      try {
        final maleNames = await getNames(region, Gender.male);
        final femaleNames = await getNames(region, Gender.female);

        if (maleNames.isNotEmpty || femaleNames.isNotEmpty) {
          availableRegions.add(region);
        }
      } catch (e) {
        // Region not available, skip
        continue;
      }
    }

    return availableRegions;
  }

  /// Pre-load names for specific regions and genders to improve performance
  Future<void> preloadNames(List<Region> regions, List<Gender> genders) async {
    await PerformanceUtils.processInChunks<Region, void>(
      regions,
      (region) async {
        for (final gender in genders) {
          try {
            await getNames(region, gender);
          } catch (e) {
            // Continue with other regions if one fails
            continue;
          }
        }
      },
      chunkSize: 3, // Process 3 regions at a time
      delay: const Duration(milliseconds: 50),
    );
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'nameCache': {
        'size': _nameCache.length,
        'keys': _nameCache.keys.toList(),
        'totalNames': _nameCache.values.fold<int>(
          0,
          (sum, names) => sum + names.length,
        ),
      },
      'generationHistory': {
        'regions': _generationHistory.length,
        'totalHistory': _generationHistory.values.fold<int>(
          0,
          (sum, history) => sum + history.length,
        ),
      },
      'weights': {
        'nameWeights': _nameWeights.length,
        'regionWeights': _regionWeights.length,
      },
    };
  }

  /// Apply Lithuanian name customization if applicable
  Name _applyLithuanianCustomization(
    Name originalName,
    Region region,
    Gender gender,
    LifeStage? lifeStage,
    MaritalStatus? maritalStatus,
  ) {
    // Only apply customization to Lithuanian names and female gender
    if (region != Region.lithuanian || gender != Gender.female) {
      return originalName.copyWith(
        lifeStage: lifeStage,
        maritalStatus: maritalStatus,
      );
    }

    // Determine marital status if not provided
    MaritalStatus effectiveMaritalStatus = maritalStatus ?? 
        (lifeStage != null 
          ? LithuanianNameCustomizer.getDefaultMaritalStatus(lifeStage)
          : MaritalStatus.single);

    // Transform surname based on marital status
    final transformedSurname = LithuanianNameCustomizer.transformSurname(
      originalName.lastName,
      effectiveMaritalStatus,
    );

    return originalName.copyWith(
      lastName: transformedSurname,
      lifeStage: lifeStage,
      maritalStatus: effectiveMaritalStatus,
    );
  }

  /// Create a customized name with Lithuanian conventions
  /// This allows real-time surname updates without regeneration
  Name customizeLithuanianName(
    Name baseName,
    MaritalStatus maritalStatus, {
    LifeStage? lifeStage,
  }) {
    if (baseName.region != Region.lithuanian || baseName.gender != Gender.female) {
      throw ArgumentError('Can only customize Lithuanian female names');
    }

    // Get the base (masculine) form of the surname first
    final baseSurname = LithuanianNameCustomizer.getBaseSurname(baseName.lastName);
    
    // Apply the new transformation
    final customizedSurname = LithuanianNameCustomizer.transformSurname(
      baseSurname,
      maritalStatus,
    );

    return baseName.copyWith(
      lastName: customizedSurname,
      lifeStage: lifeStage ?? baseName.lifeStage,
      maritalStatus: maritalStatus,
    );
  }

  /// Check if a name can be customized (currently only Lithuanian female names)
  static bool canCustomizeName(Name name) {
    return name.region == Region.lithuanian && name.gender == Gender.female;
  }

  /// Get available marital status options for a name
  static List<MaritalStatus> getAvailableMaritalStatuses(Name name) {
    if (!canCustomizeName(name)) {
      return [];
    }
    return MaritalStatus.values;
  }

  /// Clear all cached data
  @override
  void clearCache() {
    _nameCache.clear();
    _generationHistory.clear();
    _nameWeights.clear();
    _regionWeights.clear();
    super.clearCache(); // Clear performance optimization cache
    PerformanceUtils.logMemoryUsage('name_repository_cache_cleared');
  }
}
