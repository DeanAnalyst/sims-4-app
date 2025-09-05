import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/generation_preferences_service.dart';

/// Provider for the generation preferences service
final generationPreferencesServiceProvider =
    Provider<GenerationPreferencesService>((ref) {
      return GenerationPreferencesService();
    });

/// Provider for generation preferences
final generationPreferencesProvider = FutureProvider<GenerationPreferences>((
  ref,
) async {
  final service = ref.watch(generationPreferencesServiceProvider);
  return await service.loadPreferences();
});

/// Provider for name filters
final nameFiltersProvider = FutureProvider<NameFilters>((ref) async {
  final service = ref.watch(generationPreferencesServiceProvider);
  return await service.loadNameFilters();
});

/// Provider for trait filters
final traitFiltersProvider = FutureProvider<TraitFilters>((ref) async {
  final service = ref.watch(generationPreferencesServiceProvider);
  return await service.loadTraitFilters();
});

/// Provider for generation weights
final generationWeightsProvider = FutureProvider<GenerationWeights>((
  ref,
) async {
  final service = ref.watch(generationPreferencesServiceProvider);
  return await service.loadWeights();
});

/// State notifier for managing generation preferences
class GenerationPreferencesNotifier
    extends StateNotifier<AsyncValue<GenerationPreferences>> {
  final GenerationPreferencesService _service;
  final Ref _ref;

  GenerationPreferencesNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await _service.loadPreferences();
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update generation preferences
  Future<void> updatePreferences(GenerationPreferences preferences) async {
    state = const AsyncValue.loading();
    try {
      await _service.savePreferences(preferences);
      state = AsyncValue.data(preferences);

      // Refresh related providers
      _ref.invalidate(generationPreferencesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle avoid duplicates setting
  Future<void> toggleAvoidDuplicates() async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(
        currentPrefs.copyWith(avoidDuplicates: !currentPrefs.avoidDuplicates),
      );
    }
  }

  /// Toggle weighted selection setting
  Future<void> toggleWeightedSelection() async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(
        currentPrefs.copyWith(
          useWeightedSelection: !currentPrefs.useWeightedSelection,
        ),
      );
    }
  }

  /// Update max traits per character
  Future<void> updateMaxTraits(int maxTraits) async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(
        currentPrefs.copyWith(maxTraitsPerCharacter: maxTraits.clamp(1, 3)),
      );
    }
  }

  /// Toggle generation history setting
  Future<void> toggleGenerationHistory() async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(
        currentPrefs.copyWith(
          enableGenerationHistory: !currentPrefs.enableGenerationHistory,
        ),
      );
    }
  }

  /// Update history size
  Future<void> updateHistorySize(int size) async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(
        currentPrefs.copyWith(historySize: size.clamp(10, 200)),
      );
    }
  }

  /// Reset to default preferences
  Future<void> resetToDefaults() async {
    await updatePreferences(GenerationPreferences.defaultPreferences());
  }
}

/// Provider for the generation preferences notifier
final generationPreferencesNotifierProvider =
    StateNotifierProvider<
      GenerationPreferencesNotifier,
      AsyncValue<GenerationPreferences>
    >((ref) {
      final service = ref.watch(generationPreferencesServiceProvider);
      return GenerationPreferencesNotifier(service, ref);
    });

/// State notifier for managing name filters
class NameFiltersNotifier extends StateNotifier<AsyncValue<NameFilters>> {
  final GenerationPreferencesService _service;
  final Ref _ref;

  NameFiltersNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final filters = await _service.loadNameFilters();
      state = AsyncValue.data(filters);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update name filters
  Future<void> updateFilters(NameFilters filters) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveNameFilters(filters);
      state = AsyncValue.data(filters);

      // Refresh related providers
      _ref.invalidate(nameFiltersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset to default filters
  Future<void> resetToDefaults() async {
    await updateFilters(NameFilters.defaultFilters());
  }
}

/// Provider for the name filters notifier
final nameFiltersNotifierProvider =
    StateNotifierProvider<NameFiltersNotifier, AsyncValue<NameFilters>>((ref) {
      final service = ref.watch(generationPreferencesServiceProvider);
      return NameFiltersNotifier(service, ref);
    });

/// State notifier for managing trait filters
class TraitFiltersNotifier extends StateNotifier<AsyncValue<TraitFilters>> {
  final GenerationPreferencesService _service;
  final Ref _ref;

  TraitFiltersNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final filters = await _service.loadTraitFilters();
      state = AsyncValue.data(filters);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update trait filters
  Future<void> updateFilters(TraitFilters filters) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveTraitFilters(filters);
      state = AsyncValue.data(filters);

      // Refresh related providers
      _ref.invalidate(traitFiltersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset to default filters
  Future<void> resetToDefaults() async {
    await updateFilters(TraitFilters.defaultFilters());
  }
}

/// Provider for the trait filters notifier
final traitFiltersNotifierProvider =
    StateNotifierProvider<TraitFiltersNotifier, AsyncValue<TraitFilters>>((
      ref,
    ) {
      final service = ref.watch(generationPreferencesServiceProvider);
      return TraitFiltersNotifier(service, ref);
    });

/// State notifier for managing generation weights
class GenerationWeightsNotifier
    extends StateNotifier<AsyncValue<GenerationWeights>> {
  final GenerationPreferencesService _service;
  final Ref _ref;

  GenerationWeightsNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadWeights();
  }

  Future<void> _loadWeights() async {
    try {
      final weights = await _service.loadWeights();
      state = AsyncValue.data(weights);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update generation weights
  Future<void> updateWeights(GenerationWeights weights) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveWeights(weights);
      state = AsyncValue.data(weights);

      // Refresh related providers
      _ref.invalidate(generationWeightsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Set name weight
  Future<void> setNameWeight(String nameKey, double weight) async {
    final currentWeights = state.value;
    if (currentWeights != null) {
      final newNameWeights = Map<String, double>.from(
        currentWeights.nameWeights,
      );
      newNameWeights[nameKey] = weight.clamp(0.1, 10.0);

      await updateWeights(currentWeights.copyWith(nameWeights: newNameWeights));
    }
  }

  /// Set region weight
  Future<void> setRegionWeight(String region, double weight) async {
    final currentWeights = state.value;
    if (currentWeights != null) {
      final newRegionWeights = Map<String, double>.from(
        currentWeights.regionWeights,
      );
      newRegionWeights[region] = weight.clamp(0.1, 10.0);

      await updateWeights(
        currentWeights.copyWith(regionWeights: newRegionWeights),
      );
    }
  }

  /// Set trait weight
  Future<void> setTraitWeight(String traitId, double weight) async {
    final currentWeights = state.value;
    if (currentWeights != null) {
      final newTraitWeights = Map<String, double>.from(
        currentWeights.traitWeights,
      );
      newTraitWeights[traitId] = weight.clamp(0.1, 10.0);

      await updateWeights(
        currentWeights.copyWith(traitWeights: newTraitWeights),
      );
    }
  }

  /// Set category weight
  Future<void> setCategoryWeight(String category, double weight) async {
    final currentWeights = state.value;
    if (currentWeights != null) {
      final newCategoryWeights = Map<String, double>.from(
        currentWeights.categoryWeights,
      );
      newCategoryWeights[category] = weight.clamp(0.1, 10.0);

      await updateWeights(
        currentWeights.copyWith(categoryWeights: newCategoryWeights),
      );
    }
  }

  /// Set pack weight
  Future<void> setPackWeight(String pack, double weight) async {
    final currentWeights = state.value;
    if (currentWeights != null) {
      final newPackWeights = Map<String, double>.from(
        currentWeights.packWeights,
      );
      newPackWeights[pack] = weight.clamp(0.1, 10.0);

      await updateWeights(currentWeights.copyWith(packWeights: newPackWeights));
    }
  }

  /// Clear all weights
  Future<void> clearAllWeights() async {
    await updateWeights(GenerationWeights.defaultWeights());
  }

  /// Reset to default weights
  Future<void> resetToDefaults() async {
    await updateWeights(GenerationWeights.defaultWeights());
  }
}

/// Provider for the generation weights notifier
final generationWeightsNotifierProvider =
    StateNotifierProvider<
      GenerationWeightsNotifier,
      AsyncValue<GenerationWeights>
    >((ref) {
      final service = ref.watch(generationPreferencesServiceProvider);
      return GenerationWeightsNotifier(service, ref);
    });
