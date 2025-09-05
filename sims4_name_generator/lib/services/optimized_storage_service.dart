import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_profile.dart';
import '../models/trait.dart';
import '../utils/performance_utils.dart';

/// Optimized storage service with efficient queries and pagination
class OptimizedStorageService {
  static const String _savedCharactersKey = 'saved_characters';
  static const String _favoritesKey = 'favorite_characters';
  static const String _historyKey = 'character_history';

  // Cache configuration
  static const int _maxHistorySize = 100;
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(minutes: 15);

  // Memory cache with timestamps
  final Map<String, List<CharacterProfile>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Pagination support
  static const int _defaultPageSize = 20;

  // Background operations
  final Map<String, Future<void>> _pendingOperations = {};

  /// Save character with optimized storage
  Future<void> saveCharacter(CharacterProfile character) async {
    return PerformanceMonitor.measureAsync(
      'save_character_optimized',
      () async {
        final operationKey = 'save_${DateTime.now().millisecondsSinceEpoch}';

        // Check if operation is already pending
        if (_pendingOperations.containsKey(operationKey)) {
          await _pendingOperations[operationKey];
          return;
        }

        final operation = _performSaveCharacter(character);
        _pendingOperations[operationKey] = operation;

        try {
          await operation;
        } finally {
          _pendingOperations.remove(operationKey);
        }
      },
    );
  }

  /// Perform the actual save operation
  Future<void> _performSaveCharacter(CharacterProfile character) async {
    await SharedPreferences.getInstance();
    final savedCharacters = await getSavedCharacters();

    // Add the character with a unique ID
    final characterWithId = character.copyWith(generatedAt: DateTime.now());
    savedCharacters.add(characterWithId);

    // Batch the save operation
    await _batchSave(_savedCharactersKey, savedCharacters);

    // Update cache
    _updateCache(_savedCharactersKey, savedCharacters);
  }

  /// Get saved characters with pagination
  Future<List<CharacterProfile>> getSavedCharacters({
    int page = 0,
    int pageSize = _defaultPageSize,
    String? searchQuery,
    String? regionFilter,
    String? genderFilter,
  }) async {
    return PerformanceMonitor.measureAsync(
      'get_saved_characters_optimized',
      () async {
        final cacheKey =
            'saved_$page${searchQuery ?? ''}${regionFilter ?? ''}${genderFilter ?? ''}';

        // Check cache first
        if (_isCacheValid(cacheKey)) {
          return _cache[cacheKey]!;
        }

        final allCharacters = await _loadSavedCharacters();

        // Apply filters
        List<CharacterProfile> filteredCharacters = allCharacters;

        if (searchQuery != null && searchQuery.isNotEmpty) {
          filteredCharacters = _filterBySearch(filteredCharacters, searchQuery);
        }

        if (regionFilter != null) {
          filteredCharacters = _filterByRegion(
            filteredCharacters,
            regionFilter,
          );
        }

        if (genderFilter != null) {
          filteredCharacters = _filterByGender(
            filteredCharacters,
            genderFilter,
          );
        }

        // Apply pagination
        final startIndex = page * pageSize;
        final endIndex = (startIndex + pageSize).clamp(
          0,
          filteredCharacters.length,
        );

        List<CharacterProfile> paginatedCharacters = [];
        if (startIndex < filteredCharacters.length) {
          paginatedCharacters = filteredCharacters.sublist(
            startIndex,
            endIndex,
          );
        }

        // Update cache
        _updateCache(cacheKey, paginatedCharacters);

        return paginatedCharacters;
      },
    );
  }

  /// Get total count of saved characters (for pagination)
  Future<int> getSavedCharactersCount({
    String? searchQuery,
    String? regionFilter,
    String? genderFilter,
  }) async {
    final allCharacters = await _loadSavedCharacters();

    List<CharacterProfile> filteredCharacters = allCharacters;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredCharacters = _filterBySearch(filteredCharacters, searchQuery);
    }

    if (regionFilter != null) {
      filteredCharacters = _filterByRegion(filteredCharacters, regionFilter);
    }

    if (genderFilter != null) {
      filteredCharacters = _filterByGender(filteredCharacters, genderFilter);
    }

    return filteredCharacters.length;
  }

  /// Load saved characters from storage
  Future<List<CharacterProfile>> _loadSavedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedCharactersKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // Clear corrupted data
      await prefs.remove(_savedCharactersKey);
      return [];
    }
  }

  /// Filter characters by search query
  List<CharacterProfile> _filterBySearch(
    List<CharacterProfile> characters,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return characters.where((character) {
      final fullName = '${character.name.firstName} ${character.name.lastName}'
          .toLowerCase();
      return fullName.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter characters by region
  List<CharacterProfile> _filterByRegion(
    List<CharacterProfile> characters,
    String region,
  ) {
    return characters.where((character) {
      return character.name.region.name == region;
    }).toList();
  }

  /// Filter characters by gender
  List<CharacterProfile> _filterByGender(
    List<CharacterProfile> characters,
    String gender,
  ) {
    return characters.where((character) {
      return character.name.gender.name == gender;
    }).toList();
  }

  /// Delete saved character with optimized operation
  Future<void> deleteSavedCharacter(CharacterProfile character) async {
    return PerformanceMonitor.measureAsync(
      'delete_character_optimized',
      () async {
        final operationKey = 'delete_${DateTime.now().millisecondsSinceEpoch}';

        if (_pendingOperations.containsKey(operationKey)) {
          await _pendingOperations[operationKey];
          return;
        }

        final operation = _performDeleteCharacter(character);
        _pendingOperations[operationKey] = operation;

        try {
          await operation;
        } finally {
          _pendingOperations.remove(operationKey);
        }
      },
    );
  }

  /// Perform the actual delete operation
  Future<void> _performDeleteCharacter(CharacterProfile character) async {
    final savedCharacters = await getSavedCharacters();

    // Remove the character
    savedCharacters.removeWhere((c) => _charactersEqual(c, character));

    // Batch the save operation
    await _batchSave(_savedCharactersKey, savedCharacters);

    // Clear related caches
    _clearRelatedCaches();
  }

  /// Add character to favorites with optimized operation
  Future<void> addToFavorites(CharacterProfile character) async {
    return PerformanceMonitor.measureAsync(
      'add_to_favorites_optimized',
      () async {
        final favorites = await getFavoriteCharacters();

        // Check if already in favorites
        final isAlreadyFavorite = favorites.any(
          (c) => _charactersEqual(c, character),
        );

        if (!isAlreadyFavorite) {
          favorites.add(character);
          await _batchSave(_favoritesKey, favorites);
          _updateCache(_favoritesKey, favorites);
        }
      },
    );
  }

  /// Remove character from favorites
  Future<void> removeFromFavorites(CharacterProfile character) async {
    return PerformanceMonitor.measureAsync(
      'remove_from_favorites_optimized',
      () async {
        final favorites = await getFavoriteCharacters();

        favorites.removeWhere((c) => _charactersEqual(c, character));
        await _batchSave(_favoritesKey, favorites);
        _updateCache(_favoritesKey, favorites);
      },
    );
  }

  /// Get favorite characters with pagination
  Future<List<CharacterProfile>> getFavoriteCharacters({
    int page = 0,
    int pageSize = _defaultPageSize,
  }) async {
    return PerformanceMonitor.measureAsync('get_favorites_optimized', () async {
      final cacheKey = 'favorites_$page';

      if (_isCacheValid(cacheKey)) {
        return _cache[cacheKey]!;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);

      if (jsonString == null) return [];

      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        final allFavorites = jsonList
            .map(
              (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Apply pagination
        final startIndex = page * pageSize;
        final endIndex = (startIndex + pageSize).clamp(0, allFavorites.length);

        List<CharacterProfile> paginatedFavorites = [];
        if (startIndex < allFavorites.length) {
          paginatedFavorites = allFavorites.sublist(startIndex, endIndex);
        }

        _updateCache(cacheKey, paginatedFavorites);
        return paginatedFavorites;
      } catch (e) {
        await prefs.remove(_favoritesKey);
        return [];
      }
    });
  }

  /// Get character history with pagination
  Future<List<CharacterProfile>> getCharacterHistory({
    int page = 0,
    int pageSize = _defaultPageSize,
  }) async {
    return PerformanceMonitor.measureAsync('get_history_optimized', () async {
      final cacheKey = 'history_$page';

      if (_isCacheValid(cacheKey)) {
        return _cache[cacheKey]!;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null) return [];

      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        final allHistory = jsonList
            .map(
              (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Apply pagination
        final startIndex = page * pageSize;
        final endIndex = (startIndex + pageSize).clamp(0, allHistory.length);

        List<CharacterProfile> paginatedHistory = [];
        if (startIndex < allHistory.length) {
          paginatedHistory = allHistory.sublist(startIndex, endIndex);
        }

        _updateCache(cacheKey, paginatedHistory);
        return paginatedHistory;
      } catch (e) {
        await prefs.remove(_historyKey);
        return [];
      }
    });
  }

  /// Add character to history
  Future<void> addToHistory(CharacterProfile character) async {
    return PerformanceMonitor.measureAsync(
      'add_to_history_optimized',
      () async {
        final history = await getCharacterHistory();

        // Add to beginning of history
        history.insert(0, character);

        // Limit history size
        if (history.length > _maxHistorySize) {
          history.removeRange(_maxHistorySize, history.length);
        }

        await _batchSave(_historyKey, history);
        _clearRelatedCaches();
      },
    );
  }

  /// Batch save operation for better performance
  Future<void> _batchSave(String key, List<CharacterProfile> characters) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert to JSON efficiently
    final jsonList = characters.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    // Save with error handling
    try {
      await prefs.setString(key, jsonString);
    } catch (e) {
      // If save fails, try to save in chunks
      await _saveInChunks(key, characters);
    }
  }

  /// Save data in chunks if main save fails
  Future<void> _saveInChunks(
    String key,
    List<CharacterProfile> characters,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    const chunkSize = 10;

    for (int i = 0; i < characters.length; i += chunkSize) {
      final chunk = characters.skip(i).take(chunkSize).toList();
      final jsonList = chunk.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString('${key}_chunk_${i ~/ chunkSize}', jsonString);
    }

    // Save metadata about chunks
    final metadata = {
      'chunkCount': (characters.length / chunkSize).ceil(),
      'totalCount': characters.length,
    };
    await prefs.setString('${key}_metadata', jsonEncode(metadata));
  }

  /// Check if characters are equal
  bool _charactersEqual(CharacterProfile a, CharacterProfile b) {
    return a.name.firstName == b.name.firstName &&
        a.name.lastName == b.name.lastName &&
        a.name.gender == b.name.gender &&
        a.name.region == b.name.region &&
        _traitsEqual(a.traits, b.traits);
  }

  /// Check if traits are equal
  bool _traitsEqual(List<Trait> a, List<Trait> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }

    return true;
  }

  /// Check if cache is valid
  bool _isCacheValid(String cacheKey) {
    if (!_cache.containsKey(cacheKey)) return false;

    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Update cache with memory management
  void _updateCache(String cacheKey, List<CharacterProfile> data) {
    // Manage cache size
    if (_cache.length >= _maxCacheSize) {
      _evictOldestCache();
    }

    _cache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Evict oldest cache entry
  void _evictOldestCache() {
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Clear related caches
  void _clearRelatedCaches() {
    final keysToRemove = _cache.keys
        .where(
          (key) =>
              key.startsWith('saved_') ||
              key.startsWith('favorites_') ||
              key.startsWith('history_'),
        )
        .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Clear all caches
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final savedCount = await getSavedCharactersCount();
    final favoritesCount = (await getFavoriteCharacters()).length;
    final historyCount = (await getCharacterHistory()).length;

    return {
      'savedCharacters': savedCount,
      'favorites': favoritesCount,
      'history': historyCount,
      'cacheSize': _cache.length,
      'pendingOperations': _pendingOperations.length,
    };
  }

  /// Optimize storage (clean up old data, compress, etc.)
  Future<void> optimizeStorage() async {
    return PerformanceMonitor.measureAsync('optimize_storage', () async {
      // Clear expired caches
      final now = DateTime.now();
      final expiredKeys = _cacheTimestamps.entries
          .where((entry) => now.difference(entry.value) > _cacheExpiry)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }

      // Clear old history entries
      final history = await getCharacterHistory();
      if (history.length > _maxHistorySize) {
        final optimizedHistory = history.take(_maxHistorySize).toList();
        await _batchSave(_historyKey, optimizedHistory);
      }
    });
  }
}
