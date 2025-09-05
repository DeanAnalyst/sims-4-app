import 'dart:math';
import '../models/trait.dart';
import '../models/enums.dart';
import '../services/data_service.dart';

/// Repository for managing trait data with caching and compatibility logic
/// Enhanced with weighted selection and duplicate avoidance
class TraitRepository {
  final DataService _dataService;
  List<Trait>? _traitsCache;
  final Random _random = Random();

  // Generation history to avoid duplicates
  final List<List<Trait>> _generationHistory = [];

  // Weighted selection preferences
  final Map<String, double> _traitWeights = {};
  final Map<TraitCategory, double> _categoryWeights = {};
  final Map<String, double> _packWeights = {};

  static const int _maxHistorySize = 50;

  /// Maximum number of traits a Sim can have (as per Sims 4 game rules)
  static const int maxTraitsPerSim = 3;

  TraitRepository(this._dataService);

  /// Get all available traits
  /// Returns cached data if available, otherwise loads from data service
  Future<List<Trait>> getAllTraits() async {
    // Return cached data if available
    if (_traitsCache != null) {
      return _traitsCache!;
    }

    try {
      // Load traits from data service
      final traits = await _dataService.loadTraits();

      // Cache the results
      _traitsCache = traits;

      return traits;
    } catch (e) {
      throw Exception('Failed to load traits: $e');
    }
  }

  /// Get traits filtered by category
  Future<List<Trait>> getTraitsByCategory(TraitCategory category) async {
    final allTraits = await getAllTraits();
    return allTraits.where((trait) => trait.category == category).toList();
  }

  /// Get traits filtered by pack
  Future<List<Trait>> getTraitsByPack(String pack) async {
    final allTraits = await getAllTraits();
    return allTraits.where((trait) => trait.pack == pack).toList();
  }

  /// Get traits appropriate for a specific life stage
  Future<List<Trait>> getTraitsByLifeStage(LifeStage lifeStage) async {
    final allTraits = await getAllTraits();
    return allTraits.where((trait) => trait.isAppropriateForLifeStage(lifeStage)).toList();
  }

  /// Get the maximum number of traits allowed for a specific life stage
  int getMaxTraitsForLifeStage(LifeStage lifeStage) {
    return AgeBasedLimits.getTraitLimit(lifeStage);
  }

  /// Get a trait by its ID
  Future<Trait?> getTraitById(String id) async {
    final allTraits = await getAllTraits();
    try {
      return allTraits.firstWhere((trait) => trait.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find a trait by its ID (alias for getTraitById for test compatibility)
  Future<Trait?> findTraitById(String id) async {
    return getTraitById(id);
  }

  /// Check if a list of traits are compatible (no conflicts)
  bool areTraitsCompatible(List<Trait> traits) {
    if (traits.length > maxTraitsPerSim) {
      return false;
    }

    // Check each trait against all others for conflicts
    for (int i = 0; i < traits.length; i++) {
      for (int j = i + 1; j < traits.length; j++) {
        if (traits[i].conflictsWith(traits[j])) {
          return false;
        }
      }
    }

    return true;
  }

  /// Generate random traits with compatibility checking
  /// Returns up to maxTraits compatible traits
  /// Enhanced with weighted selection, duplicate avoidance, and age filtering
  Future<List<Trait>> generateRandomTraits({
    int maxTraits = maxTraitsPerSim,
    bool avoidDuplicates = true,
    List<TraitCategory>? preferredCategories,
    List<String>? preferredPacks,
    LifeStage? forLifeStage,
  }) async {
    if (maxTraits <= 0) {
      throw ArgumentError('maxTraits must be positive');
    }

    // Adjust maxTraits based on life stage if specified
    if (forLifeStage != null) {
      final ageLimit = AgeBasedLimits.getTraitLimit(forLifeStage);
      maxTraits = maxTraits > ageLimit ? ageLimit : maxTraits;
    }

    if (maxTraits > maxTraitsPerSim) {
      throw ArgumentError('maxTraits cannot exceed $maxTraitsPerSim');
    }

    final allTraits = await getAllTraits();

    if (allTraits.isEmpty) {
      throw Exception('No traits available');
    }

    List<Trait> availableTraits = List<Trait>.from(allTraits);

    // Filter by life stage if specified
    if (forLifeStage != null) {
      availableTraits = availableTraits
          .where((trait) => trait.isAppropriateForLifeStage(forLifeStage))
          .toList();
    }

    // Filter by preferred categories if specified
    if (preferredCategories != null && preferredCategories.isNotEmpty) {
      availableTraits = availableTraits
          .where((trait) => preferredCategories.contains(trait.category))
          .toList();
    }

    // Filter by preferred packs if specified
    if (preferredPacks != null && preferredPacks.isNotEmpty) {
      availableTraits = availableTraits
          .where((trait) => preferredPacks.contains(trait.pack))
          .toList();
    }

    // Filter out recently generated combinations if avoiding duplicates
    if (avoidDuplicates && _generationHistory.isNotEmpty) {
      availableTraits = _filterRecentlyUsedTraits(availableTraits);
    }

    if (availableTraits.isEmpty) {
      // Fallback to all traits if filtering left us with nothing
      availableTraits = List<Trait>.from(allTraits);
    }

    final selectedTraits = <Trait>[];
    final workingTraits = List<Trait>.from(availableTraits);

    while (selectedTraits.length < maxTraits && workingTraits.isNotEmpty) {
      Trait selectedTrait;

      if (_hasWeights()) {
        selectedTrait = _selectWeightedTrait(workingTraits, selectedTraits);
      } else {
        // Standard random selection
        workingTraits.shuffle(_random);
        selectedTrait = workingTraits.first;
      }

      // Check if this trait is compatible with already selected traits
      if (!selectedTrait.conflictsWithAny(selectedTraits)) {
        selectedTraits.add(selectedTrait);
      }

      // Remove the trait from working list to avoid selecting it again
      workingTraits.remove(selectedTrait);
    }

    // Add to generation history
    if (selectedTraits.isNotEmpty) {
      _addToHistory(selectedTraits);
    }

    return selectedTraits;
  }

  /// Generate random traits from a specific category
  Future<List<Trait>> generateRandomTraitsByCategory(
    TraitCategory category, {
    int maxTraits = maxTraitsPerSim,
  }) async {
    if (maxTraits <= 0) {
      throw ArgumentError('maxTraits must be positive');
    }

    if (maxTraits > maxTraitsPerSim) {
      throw ArgumentError('maxTraits cannot exceed $maxTraitsPerSim');
    }

    final categoryTraits = await getTraitsByCategory(category);

    if (categoryTraits.isEmpty) {
      throw Exception('No traits available for category $category');
    }

    final selectedTraits = <Trait>[];
    final availableTraits = List<Trait>.from(categoryTraits);

    // Shuffle the available traits for randomness
    availableTraits.shuffle(_random);

    for (final trait in availableTraits) {
      // Check if this trait is compatible with already selected traits
      if (!trait.conflictsWithAny(selectedTraits)) {
        selectedTraits.add(trait);

        // Stop if we've reached the maximum number of traits
        if (selectedTraits.length >= maxTraits) {
          break;
        }
      }
    }

    return selectedTraits;
  }

  /// Find traits that are compatible with a given list of traits
  Future<List<Trait>> getCompatibleTraits(List<Trait> existingTraits) async {
    final allTraits = await getAllTraits();
    final compatibleTraits = <Trait>[];

    for (final trait in allTraits) {
      // Skip if trait is already in the existing list
      if (existingTraits.any((existing) => existing.id == trait.id)) {
        continue;
      }

      // Check if this trait is compatible with all existing traits
      if (!trait.conflictsWithAny(existingTraits)) {
        compatibleTraits.add(trait);
      }
    }

    return compatibleTraits;
  }

  /// Find traits that conflict with a given trait
  Future<List<Trait>> getConflictingTraits(Trait trait) async {
    final allTraits = await getAllTraits();
    final conflictingTraits = <Trait>[];

    for (final otherTrait in allTraits) {
      if (trait.conflictsWith(otherTrait)) {
        conflictingTraits.add(otherTrait);
      }
    }

    return conflictingTraits;
  }

  /// Generate a random trait that is compatible with existing traits
  Future<Trait> generateRandomTraitCompatibleWith(
    List<Trait> existingTraits,
  ) async {
    final compatibleTraits = await getCompatibleTraits(existingTraits);

    if (compatibleTraits.isEmpty) {
      throw Exception(
        'No compatible traits available with the current selection',
      );
    }

    // Return a random compatible trait
    return compatibleTraits[_random.nextInt(compatibleTraits.length)];
  }

  /// Get all available trait categories
  Future<List<TraitCategory>> getAvailableCategories() async {
    final allTraits = await getAllTraits();
    final categories = allTraits
        .map((trait) => trait.category)
        .toSet()
        .toList();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  /// Get all available packs
  Future<List<String>> getAvailablePacks() async {
    final allTraits = await getAllTraits();
    final packs = allTraits.map((trait) => trait.pack).toSet().toList();
    packs.sort();
    return packs;
  }

  /// Search traits by name (case-insensitive)
  Future<List<Trait>> searchTraits(String query) async {
    if (query.trim().isEmpty) {
      return await getAllTraits();
    }

    final allTraits = await getAllTraits();
    final lowercaseQuery = query.toLowerCase();

    return allTraits.where((trait) {
      return trait.name.toLowerCase().contains(lowercaseQuery) ||
          trait.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get trait statistics
  Future<Map<String, dynamic>> getTraitStatistics() async {
    final allTraits = await getAllTraits();
    final categoryCount = <TraitCategory, int>{};
    final packCount = <String, int>{};

    for (final trait in allTraits) {
      categoryCount[trait.category] = (categoryCount[trait.category] ?? 0) + 1;
      packCount[trait.pack] = (packCount[trait.pack] ?? 0) + 1;
    }

    return {
      'totalTraits': allTraits.length,
      'traitsByCategory': categoryCount.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'traitsByPack': packCount,
      'averageConflictsPerTrait': _calculateAverageConflicts(allTraits),
    };
  }

  /// Calculate the average number of conflicts per trait
  double _calculateAverageConflicts(List<Trait> traits) {
    if (traits.isEmpty) return 0.0;

    int totalConflicts = 0;
    for (final trait in traits) {
      totalConflicts += trait.conflictingTraits.length;
    }

    return totalConflicts / traits.length;
  }

  /// Validate a trait combination and return validation result
  Future<TraitValidationResult> validateTraitCombination(
    List<Trait> traits, {
    LifeStage? forLifeStage,
  }) async {
    final conflicts = <TraitConflict>[];
    final ageInappropriateTraits = <Trait>[];

    // Determine maximum traits allowed
    int maxAllowed = maxTraitsPerSim;
    if (forLifeStage != null) {
      maxAllowed = AgeBasedLimits.getTraitLimit(forLifeStage);
    }

    // Check for too many traits
    if (traits.length > maxAllowed) {
      return TraitValidationResult(
        isValid: false,
        conflicts: conflicts,
        ageInappropriateTraits: ageInappropriateTraits,
        errorMessage:
            'Too many traits: ${traits.length}. Maximum allowed for ${forLifeStage?.name ?? 'general'}: $maxAllowed',
      );
    }

    // Check for age-inappropriate traits
    if (forLifeStage != null) {
      for (final trait in traits) {
        if (!trait.isAppropriateForLifeStage(forLifeStage)) {
          ageInappropriateTraits.add(trait);
        }
      }
    }

    // Check for conflicts between traits
    for (int i = 0; i < traits.length; i++) {
      for (int j = i + 1; j < traits.length; j++) {
        if (traits[i].conflictsWith(traits[j])) {
          conflicts.add(TraitConflict(trait1: traits[i], trait2: traits[j]));
        }
      }
    }

    final hasErrors = conflicts.isNotEmpty || ageInappropriateTraits.isNotEmpty;
    String? errorMessage;
    
    if (hasErrors) {
      final errorParts = <String>[];
      if (conflicts.isNotEmpty) {
        errorParts.add('Found ${conflicts.length} trait conflict(s)');
      }
      if (ageInappropriateTraits.isNotEmpty) {
        errorParts.add('${ageInappropriateTraits.length} trait(s) inappropriate for ${forLifeStage?.name}');
      }
      errorMessage = errorParts.join('; ');
    }

    return TraitValidationResult(
      isValid: !hasErrors,
      conflicts: conflicts,
      ageInappropriateTraits: ageInappropriateTraits,
      errorMessage: errorMessage,
    );
  }

  /// Set weight for a specific trait
  void setTraitWeight(String traitId, double weight) {
    _traitWeights[traitId] = weight.clamp(0.1, 10.0);
  }

  /// Set weight for a trait category
  void setCategoryWeight(TraitCategory category, double weight) {
    _categoryWeights[category] = weight.clamp(0.1, 10.0);
  }

  /// Set weight for a pack
  void setPackWeight(String pack, double weight) {
    _packWeights[pack] = weight.clamp(0.1, 10.0);
  }

  /// Clear all trait weights
  void clearTraitWeights() {
    _traitWeights.clear();
  }

  /// Clear all category weights
  void clearCategoryWeights() {
    _categoryWeights.clear();
  }

  /// Clear all pack weights
  void clearPackWeights() {
    _packWeights.clear();
  }

  /// Clear generation history
  void clearGenerationHistory() {
    _generationHistory.clear();
  }

  /// Get generation history
  List<List<Trait>> getGenerationHistory() {
    return List<List<Trait>>.from(_generationHistory);
  }

  /// Check if weights are configured
  bool _hasWeights() {
    return _traitWeights.isNotEmpty ||
        _categoryWeights.isNotEmpty ||
        _packWeights.isNotEmpty;
  }

  /// Select a trait using weighted random selection
  Trait _selectWeightedTrait(
    List<Trait> availableTraits,
    List<Trait> selectedTraits,
  ) {
    if (availableTraits.isEmpty) {
      throw ArgumentError('Available traits list cannot be empty');
    }

    // Filter out traits that conflict with already selected traits
    final compatibleTraits = availableTraits
        .where((trait) => !trait.conflictsWithAny(selectedTraits))
        .toList();

    if (compatibleTraits.isEmpty) {
      // If no compatible traits, return a random one from available
      return availableTraits[_random.nextInt(availableTraits.length)];
    }

    // Calculate weights for each compatible trait
    final weights = <double>[];
    double totalWeight = 0.0;

    for (final trait in compatibleTraits) {
      double weight = 1.0; // Base weight

      // Apply trait-specific weight
      if (_traitWeights.containsKey(trait.id)) {
        weight *= _traitWeights[trait.id]!;
      }

      // Apply category weight
      if (_categoryWeights.containsKey(trait.category)) {
        weight *= _categoryWeights[trait.category]!;
      }

      // Apply pack weight
      if (_packWeights.containsKey(trait.pack)) {
        weight *= _packWeights[trait.pack]!;
      }

      weights.add(weight);
      totalWeight += weight;
    }

    // Select based on weighted probability
    final randomValue = _random.nextDouble() * totalWeight;
    double currentWeight = 0.0;

    for (int i = 0; i < compatibleTraits.length; i++) {
      currentWeight += weights[i];
      if (randomValue <= currentWeight) {
        return compatibleTraits[i];
      }
    }

    // Fallback to last trait (shouldn't happen)
    return compatibleTraits.last;
  }

  /// Filter out recently used traits to avoid duplicates
  List<Trait> _filterRecentlyUsedTraits(List<Trait> traits) {
    if (_generationHistory.isEmpty) {
      return traits;
    }

    // Get recently used trait IDs from the last few generations
    final recentTraitIds = <String>{};
    final recentGenerations = _generationHistory.take(5); // Last 5 generations

    for (final generation in recentGenerations) {
      for (final trait in generation) {
        recentTraitIds.add(trait.id);
      }
    }

    // Filter out recently used traits
    final filteredTraits = traits
        .where((trait) => !recentTraitIds.contains(trait.id))
        .toList();

    // If filtering removed too many traits, return original list
    if (filteredTraits.length < traits.length * 0.3) {
      return traits;
    }

    return filteredTraits;
  }

  /// Add a trait combination to generation history
  void _addToHistory(List<Trait> traits) {
    if (traits.isEmpty) return;

    // Add to beginning (most recent first)
    _generationHistory.insert(0, List<Trait>.from(traits));

    // Limit history size
    if (_generationHistory.length > _maxHistorySize) {
      _generationHistory.removeRange(
        _maxHistorySize,
        _generationHistory.length,
      );
    }
  }

  /// Clear cached trait data
  void clearCache() {
    _traitsCache = null;
  }

  /// Get the total count of available traits
  Future<int> getTraitCount() async {
    final traits = await getAllTraits();
    return traits.length;
  }

  /// Check if traits are loaded and cached
  bool get isTraitsCached => _traitsCache != null;

  /// Get enhanced statistics including weights and history
  Future<Map<String, dynamic>> getEnhancedStatistics() async {
    final basicStats = await getTraitStatistics();

    return {
      ...basicStats,
      'generationHistory': _generationHistory.length,
      'traitWeights': _traitWeights.length,
      'categoryWeights': _categoryWeights.length,
      'packWeights': _packWeights.length,
      'hasWeights': _hasWeights(),
    };
  }
}

/// Result of trait validation
class TraitValidationResult {
  final bool isValid;
  final List<TraitConflict> conflicts;
  final List<Trait> ageInappropriateTraits;
  final String? errorMessage;

  const TraitValidationResult({
    required this.isValid,
    required this.conflicts,
    this.ageInappropriateTraits = const [],
    this.errorMessage,
  });
}

/// Represents a conflict between two traits
class TraitConflict {
  final Trait trait1;
  final Trait trait2;

  const TraitConflict({required this.trait1, required this.trait2});

  @override
  String toString() {
    return 'TraitConflict(${trait1.name} conflicts with ${trait2.name})';
  }
}
