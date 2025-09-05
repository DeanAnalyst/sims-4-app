import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/optimized_data_service.dart';
import '../services/optimized_storage_service.dart';
import '../models/name.dart';
import '../models/trait.dart';
import '../models/character_profile.dart';
import '../models/enums.dart';

/// Optimized data service provider
final optimizedDataServiceProvider = Provider<OptimizedDataService>((ref) {
  return OptimizedDataService();
});

/// Optimized storage service provider
final optimizedStorageServiceProvider = Provider<OptimizedStorageService>((
  ref,
) {
  return OptimizedStorageService();
});

/// Optimized name repository provider
final optimizedNameRepositoryProvider = Provider<OptimizedNameRepository>((
  ref,
) {
  final dataService = ref.watch(optimizedDataServiceProvider);
  return OptimizedNameRepository(dataService);
});

/// Optimized trait repository provider
final optimizedTraitRepositoryProvider = Provider<OptimizedTraitRepository>((
  ref,
) {
  final dataService = ref.watch(optimizedDataServiceProvider);
  return OptimizedTraitRepository(dataService);
});

/// Optimized character storage provider
final optimizedCharacterStorageProvider = Provider<OptimizedCharacterStorage>((
  ref,
) {
  final storageService = ref.watch(optimizedStorageServiceProvider);
  return OptimizedCharacterStorage(storageService);
});

/// Optimized name repository with enhanced caching and performance
class OptimizedNameRepository {
  final OptimizedDataService _dataService;
  final Map<String, List<Name>> _nameCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration _cacheExpiry = Duration(minutes: 30);
  static const int _maxCacheSize = 20;

  OptimizedNameRepository(this._dataService);

  /// Get names with optimized caching
  Future<List<Name>> getNames(Region region, Gender gender) async {
    final cacheKey = '${region.name}_${gender.name}';

    // Check cache first
    if (_isCacheValid(cacheKey)) {
      return _nameCache[cacheKey]!;
    }

    // Load from optimized data service
    final names = await _dataService.loadNames(region, gender);

    // Update cache
    _updateCache(cacheKey, names);

    return names;
  }

  /// Generate random name with optimized performance
  Future<Name> generateRandomName(
    Region region,
    Gender gender, {
    bool avoidDuplicates = true,
  }) async {
    final names = await getNames(region, gender);

    if (names.isEmpty) {
      throw Exception('No names available for $region $gender');
    }

    // Use efficient random selection
    final random = DateTime.now().millisecondsSinceEpoch;
    final index = random % names.length;

    return names[index];
  }

  /// Check if cache is valid
  bool _isCacheValid(String cacheKey) {
    if (!_nameCache.containsKey(cacheKey)) return false;

    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Update cache with memory management
  void _updateCache(String cacheKey, List<Name> names) {
    // Manage cache size
    if (_nameCache.length >= _maxCacheSize) {
      _evictOldestCache();
    }

    _nameCache[cacheKey] = names;
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
      _nameCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Clear cache
  void clearCache() {
    _nameCache.clear();
    _cacheTimestamps.clear();
  }
}

/// Optimized trait repository with enhanced caching and performance
class OptimizedTraitRepository {
  final OptimizedDataService _dataService;
  List<Trait>? _traitsCache;
  DateTime? _cacheTimestamp;

  static const Duration _cacheExpiry = Duration(hours: 2);

  OptimizedTraitRepository(this._dataService);

  /// Get all traits with optimized caching
  Future<List<Trait>> getAllTraits() async {
    // Check cache first
    if (_isCacheValid()) {
      return _traitsCache!;
    }

    // Load from optimized data service
    final traits = await _dataService.loadTraits();

    // Update cache
    _updateCache(traits);

    return traits;
  }

  /// Get traits by category with optimized filtering
  Future<List<Trait>> getTraitsByCategory(TraitCategory category) async {
    final allTraits = await getAllTraits();
    return allTraits.where((trait) => trait.category == category).toList();
  }

  /// Get traits by pack with optimized filtering
  Future<List<Trait>> getTraitsByPack(String pack) async {
    final allTraits = await getAllTraits();
    return allTraits.where((trait) => trait.pack == pack).toList();
  }

  /// Generate random traits with optimized performance
  Future<List<Trait>> generateRandomTraits({
    int maxTraits = 3,
    List<TraitCategory>? preferredCategories,
  }) async {
    final allTraits = await getAllTraits();

    if (allTraits.isEmpty) {
      return [];
    }

    // Filter by preferred categories if specified
    List<Trait> availableTraits = allTraits;
    if (preferredCategories != null && preferredCategories.isNotEmpty) {
      availableTraits = allTraits
          .where((trait) => preferredCategories.contains(trait.category))
          .toList();
    }

    if (availableTraits.isEmpty) {
      availableTraits = allTraits;
    }

    // Generate random traits efficiently
    final selectedTraits = <Trait>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < maxTraits && availableTraits.isNotEmpty; i++) {
      final index = (random + i) % availableTraits.length;
      final selectedTrait = availableTraits[index];

      // Check compatibility with already selected traits
      if (_isCompatibleWithSelected(selectedTrait, selectedTraits)) {
        selectedTraits.add(selectedTrait);
      }

      // Remove selected trait to avoid duplicates
      availableTraits.removeAt(index);
    }

    return selectedTraits;
  }

  /// Check if trait is compatible with selected traits
  bool _isCompatibleWithSelected(Trait trait, List<Trait> selectedTraits) {
    for (final selectedTrait in selectedTraits) {
      if (trait.conflictsWith(selectedTrait)) {
        return false;
      }
    }
    return true;
  }

  /// Check if cache is valid
  bool _isCacheValid() {
    if (_traitsCache == null || _cacheTimestamp == null) return false;

    return DateTime.now().difference(_cacheTimestamp!) < _cacheExpiry;
  }

  /// Update cache
  void _updateCache(List<Trait> traits) {
    _traitsCache = traits;
    _cacheTimestamp = DateTime.now();
  }

  /// Clear cache
  void clearCache() {
    _traitsCache = null;
    _cacheTimestamp = null;
  }
}

/// Optimized character storage with enhanced performance
class OptimizedCharacterStorage {
  final OptimizedStorageService _storageService;

  OptimizedCharacterStorage(this._storageService);

  /// Save character with optimized storage
  Future<void> saveCharacter(CharacterProfile character) async {
    await _storageService.saveCharacter(character);
  }

  /// Get saved characters with pagination
  Future<List<CharacterProfile>> getSavedCharacters({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    String? regionFilter,
    String? genderFilter,
  }) async {
    return await _storageService.getSavedCharacters(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      regionFilter: regionFilter,
      genderFilter: genderFilter,
    );
  }

  /// Get total count of saved characters
  Future<int> getSavedCharactersCount({
    String? searchQuery,
    String? regionFilter,
    String? genderFilter,
  }) async {
    return await _storageService.getSavedCharactersCount(
      searchQuery: searchQuery,
      regionFilter: regionFilter,
      genderFilter: genderFilter,
    );
  }

  /// Delete saved character
  Future<void> deleteSavedCharacter(CharacterProfile character) async {
    await _storageService.deleteSavedCharacter(character);
  }

  /// Add character to favorites
  Future<void> addToFavorites(CharacterProfile character) async {
    await _storageService.addToFavorites(character);
  }

  /// Remove character from favorites
  Future<void> removeFromFavorites(CharacterProfile character) async {
    await _storageService.removeFromFavorites(character);
  }

  /// Get favorite characters with pagination
  Future<List<CharacterProfile>> getFavoriteCharacters({
    int page = 0,
    int pageSize = 20,
  }) async {
    return await _storageService.getFavoriteCharacters(
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get character history with pagination
  Future<List<CharacterProfile>> getCharacterHistory({
    int page = 0,
    int pageSize = 20,
  }) async {
    return await _storageService.getCharacterHistory(
      page: page,
      pageSize: pageSize,
    );
  }

  /// Add character to history
  Future<void> addToHistory(CharacterProfile character) async {
    await _storageService.addToHistory(character);
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    return await _storageService.getStorageStats();
  }

  /// Optimize storage
  Future<void> optimizeStorage() async {
    await _storageService.optimizeStorage();
  }
}

/// Optimized character generator provider
final optimizedCharacterGeneratorProvider =
    StateNotifierProvider<
      OptimizedCharacterGeneratorNotifier,
      OptimizedCharacterGeneratorState
    >((ref) {
      final nameRepository = ref.watch(optimizedNameRepositoryProvider);
      final traitRepository = ref.watch(optimizedTraitRepositoryProvider);
      final storage = ref.watch(optimizedCharacterStorageProvider);
      return OptimizedCharacterGeneratorNotifier(
        nameRepository,
        traitRepository,
        storage,
      );
    });

/// Optimized character generator state
class OptimizedCharacterGeneratorState {
  final Name? generatedName;
  final List<Trait> generatedTraits;
  final bool isGeneratingName;
  final bool isGeneratingTraits;
  final String? error;
  final bool isSaving;

  const OptimizedCharacterGeneratorState({
    this.generatedName,
    this.generatedTraits = const [],
    this.isGeneratingName = false,
    this.isGeneratingTraits = false,
    this.error,
    this.isSaving = false,
  });

  OptimizedCharacterGeneratorState copyWith({
    Name? generatedName,
    List<Trait>? generatedTraits,
    bool? isGeneratingName,
    bool? isGeneratingTraits,
    String? error,
    bool? isSaving,
  }) {
    return OptimizedCharacterGeneratorState(
      generatedName: generatedName ?? this.generatedName,
      generatedTraits: generatedTraits ?? this.generatedTraits,
      isGeneratingName: isGeneratingName ?? this.isGeneratingName,
      isGeneratingTraits: isGeneratingTraits ?? this.isGeneratingTraits,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Optimized character generator notifier
class OptimizedCharacterGeneratorNotifier
    extends StateNotifier<OptimizedCharacterGeneratorState> {
  final OptimizedNameRepository _nameRepository;
  final OptimizedTraitRepository _traitRepository;
  final OptimizedCharacterStorage _storage;

  OptimizedCharacterGeneratorNotifier(
    this._nameRepository,
    this._traitRepository,
    this._storage,
  ) : super(const OptimizedCharacterGeneratorState());

  /// Generate name with optimized performance
  Future<void> generateName(Region region, Gender gender) async {
    state = state.copyWith(isGeneratingName: true, error: null);

    try {
      final name = await _nameRepository.generateRandomName(region, gender);
      state = state.copyWith(generatedName: name, isGeneratingName: false);
    } catch (e) {
      state = state.copyWith(isGeneratingName: false, error: e.toString());
    }
  }

  /// Generate traits with optimized performance
  Future<void> generateTraits({
    int maxTraits = 3,
    List<TraitCategory>? preferredCategories,
  }) async {
    state = state.copyWith(isGeneratingTraits: true, error: null);

    try {
      final traits = await _traitRepository.generateRandomTraits(
        maxTraits: maxTraits,
        preferredCategories: preferredCategories,
      );
      state = state.copyWith(
        generatedTraits: traits,
        isGeneratingTraits: false,
      );
    } catch (e) {
      state = state.copyWith(isGeneratingTraits: false, error: e.toString());
    }
  }

  /// Generate complete character
  Future<void> generateCompleteCharacter(
    Region region,
    Gender gender, {
    int maxTraits = 3,
    List<TraitCategory>? preferredCategories,
  }) async {
    await generateName(region, gender);
    await generateTraits(
      maxTraits: maxTraits,
      preferredCategories: preferredCategories,
    );
  }

  /// Save current character
  Future<void> saveCurrentCharacter() async {
    if (state.generatedName == null) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final character = CharacterProfile(
        name: state.generatedName!,
        traits: state.generatedTraits,
        generatedAt: DateTime.now(),
      );

      await _storage.saveCharacter(character);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear generated data
  void clearGeneratedData() {
    state = const OptimizedCharacterGeneratorState();
  }
}
