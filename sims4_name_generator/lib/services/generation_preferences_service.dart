import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';

/// Service for managing generation preferences and filters
class GenerationPreferencesService {
  static const String _preferencesKey = 'generation_preferences';
  static const String _nameFiltersKey = 'name_filters';
  static const String _traitFiltersKey = 'trait_filters';
  static const String _weightsKey = 'generation_weights';

  /// Save generation preferences
  Future<void> savePreferences(GenerationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  /// Load generation preferences
  Future<GenerationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferencesKey);

    if (jsonString == null) {
      return GenerationPreferences.defaultPreferences();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GenerationPreferences.fromJson(json);
    } catch (e) {
      // Return default preferences if parsing fails
      return GenerationPreferences.defaultPreferences();
    }
  }

  /// Save name filters
  Future<void> saveNameFilters(NameFilters filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameFiltersKey, jsonEncode(filters.toJson()));
  }

  /// Load name filters
  Future<NameFilters> loadNameFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_nameFiltersKey);

    if (jsonString == null) {
      return NameFilters.defaultFilters();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NameFilters.fromJson(json);
    } catch (e) {
      return NameFilters.defaultFilters();
    }
  }

  /// Save trait filters
  Future<void> saveTraitFilters(TraitFilters filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_traitFiltersKey, jsonEncode(filters.toJson()));
  }

  /// Load trait filters
  Future<TraitFilters> loadTraitFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_traitFiltersKey);

    if (jsonString == null) {
      return TraitFilters.defaultFilters();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TraitFilters.fromJson(json);
    } catch (e) {
      return TraitFilters.defaultFilters();
    }
  }

  /// Save generation weights
  Future<void> saveWeights(GenerationWeights weights) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightsKey, jsonEncode(weights.toJson()));
  }

  /// Load generation weights
  Future<GenerationWeights> loadWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_weightsKey);

    if (jsonString == null) {
      return GenerationWeights.defaultWeights();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GenerationWeights.fromJson(json);
    } catch (e) {
      return GenerationWeights.defaultWeights();
    }
  }

  /// Clear all preferences
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferencesKey);
    await prefs.remove(_nameFiltersKey);
    await prefs.remove(_traitFiltersKey);
    await prefs.remove(_weightsKey);
  }
}

/// Model for general generation preferences
class GenerationPreferences {
  final bool avoidDuplicates;
  final bool useWeightedSelection;
  final int maxTraitsPerCharacter;
  final bool enableGenerationHistory;
  final int historySize;

  const GenerationPreferences({
    required this.avoidDuplicates,
    required this.useWeightedSelection,
    required this.maxTraitsPerCharacter,
    required this.enableGenerationHistory,
    required this.historySize,
  });

  factory GenerationPreferences.defaultPreferences() {
    return const GenerationPreferences(
      avoidDuplicates: true,
      useWeightedSelection: false,
      maxTraitsPerCharacter: 3,
      enableGenerationHistory: true,
      historySize: 50,
    );
  }

  factory GenerationPreferences.fromJson(Map<String, dynamic> json) {
    return GenerationPreferences(
      avoidDuplicates: json['avoidDuplicates'] as bool? ?? true,
      useWeightedSelection: json['useWeightedSelection'] as bool? ?? false,
      maxTraitsPerCharacter: json['maxTraitsPerCharacter'] as int? ?? 3,
      enableGenerationHistory: json['enableGenerationHistory'] as bool? ?? true,
      historySize: json['historySize'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avoidDuplicates': avoidDuplicates,
      'useWeightedSelection': useWeightedSelection,
      'maxTraitsPerCharacter': maxTraitsPerCharacter,
      'enableGenerationHistory': enableGenerationHistory,
      'historySize': historySize,
    };
  }

  GenerationPreferences copyWith({
    bool? avoidDuplicates,
    bool? useWeightedSelection,
    int? maxTraitsPerCharacter,
    bool? enableGenerationHistory,
    int? historySize,
  }) {
    return GenerationPreferences(
      avoidDuplicates: avoidDuplicates ?? this.avoidDuplicates,
      useWeightedSelection: useWeightedSelection ?? this.useWeightedSelection,
      maxTraitsPerCharacter:
          maxTraitsPerCharacter ?? this.maxTraitsPerCharacter,
      enableGenerationHistory:
          enableGenerationHistory ?? this.enableGenerationHistory,
      historySize: historySize ?? this.historySize,
    );
  }
}

/// Model for name generation filters
class NameFilters {
  final List<Region> preferredRegions;
  final List<Region> excludedRegions;
  final int minNameLength;
  final int maxNameLength;
  final bool allowDuplicateFirstNames;
  final bool allowDuplicateLastNames;

  const NameFilters({
    required this.preferredRegions,
    required this.excludedRegions,
    required this.minNameLength,
    required this.maxNameLength,
    required this.allowDuplicateFirstNames,
    required this.allowDuplicateLastNames,
  });

  factory NameFilters.defaultFilters() {
    return const NameFilters(
      preferredRegions: [],
      excludedRegions: [],
      minNameLength: 2,
      maxNameLength: 20,
      allowDuplicateFirstNames: true,
      allowDuplicateLastNames: true,
    );
  }

  factory NameFilters.fromJson(Map<String, dynamic> json) {
    return NameFilters(
      preferredRegions:
          (json['preferredRegions'] as List<dynamic>?)
              ?.map((e) => Region.values.byName(e as String))
              .toList() ??
          [],
      excludedRegions:
          (json['excludedRegions'] as List<dynamic>?)
              ?.map((e) => Region.values.byName(e as String))
              .toList() ??
          [],
      minNameLength: json['minNameLength'] as int? ?? 2,
      maxNameLength: json['maxNameLength'] as int? ?? 20,
      allowDuplicateFirstNames:
          json['allowDuplicateFirstNames'] as bool? ?? true,
      allowDuplicateLastNames: json['allowDuplicateLastNames'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredRegions': preferredRegions.map((e) => e.name).toList(),
      'excludedRegions': excludedRegions.map((e) => e.name).toList(),
      'minNameLength': minNameLength,
      'maxNameLength': maxNameLength,
      'allowDuplicateFirstNames': allowDuplicateFirstNames,
      'allowDuplicateLastNames': allowDuplicateLastNames,
    };
  }

  NameFilters copyWith({
    List<Region>? preferredRegions,
    List<Region>? excludedRegions,
    int? minNameLength,
    int? maxNameLength,
    bool? allowDuplicateFirstNames,
    bool? allowDuplicateLastNames,
  }) {
    return NameFilters(
      preferredRegions: preferredRegions ?? this.preferredRegions,
      excludedRegions: excludedRegions ?? this.excludedRegions,
      minNameLength: minNameLength ?? this.minNameLength,
      maxNameLength: maxNameLength ?? this.maxNameLength,
      allowDuplicateFirstNames:
          allowDuplicateFirstNames ?? this.allowDuplicateFirstNames,
      allowDuplicateLastNames:
          allowDuplicateLastNames ?? this.allowDuplicateLastNames,
    );
  }
}

/// Model for trait generation filters
class TraitFilters {
  final List<TraitCategory> preferredCategories;
  final List<TraitCategory> excludedCategories;
  final List<String> preferredPacks;
  final List<String> excludedPacks;
  final List<String> excludedTraitIds;
  final bool allowConflictingTraits;

  const TraitFilters({
    required this.preferredCategories,
    required this.excludedCategories,
    required this.preferredPacks,
    required this.excludedPacks,
    required this.excludedTraitIds,
    required this.allowConflictingTraits,
  });

  factory TraitFilters.defaultFilters() {
    return const TraitFilters(
      preferredCategories: [],
      excludedCategories: [],
      preferredPacks: [],
      excludedPacks: [],
      excludedTraitIds: [],
      allowConflictingTraits: false,
    );
  }

  factory TraitFilters.fromJson(Map<String, dynamic> json) {
    return TraitFilters(
      preferredCategories:
          (json['preferredCategories'] as List<dynamic>?)
              ?.map((e) => TraitCategory.values.byName(e as String))
              .toList() ??
          [],
      excludedCategories:
          (json['excludedCategories'] as List<dynamic>?)
              ?.map((e) => TraitCategory.values.byName(e as String))
              .toList() ??
          [],
      preferredPacks:
          (json['preferredPacks'] as List<dynamic>?)?.cast<String>() ?? [],
      excludedPacks:
          (json['excludedPacks'] as List<dynamic>?)?.cast<String>() ?? [],
      excludedTraitIds:
          (json['excludedTraitIds'] as List<dynamic>?)?.cast<String>() ?? [],
      allowConflictingTraits: json['allowConflictingTraits'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCategories': preferredCategories.map((e) => e.name).toList(),
      'excludedCategories': excludedCategories.map((e) => e.name).toList(),
      'preferredPacks': preferredPacks,
      'excludedPacks': excludedPacks,
      'excludedTraitIds': excludedTraitIds,
      'allowConflictingTraits': allowConflictingTraits,
    };
  }

  TraitFilters copyWith({
    List<TraitCategory>? preferredCategories,
    List<TraitCategory>? excludedCategories,
    List<String>? preferredPacks,
    List<String>? excludedPacks,
    List<String>? excludedTraitIds,
    bool? allowConflictingTraits,
  }) {
    return TraitFilters(
      preferredCategories: preferredCategories ?? this.preferredCategories,
      excludedCategories: excludedCategories ?? this.excludedCategories,
      preferredPacks: preferredPacks ?? this.preferredPacks,
      excludedPacks: excludedPacks ?? this.excludedPacks,
      excludedTraitIds: excludedTraitIds ?? this.excludedTraitIds,
      allowConflictingTraits:
          allowConflictingTraits ?? this.allowConflictingTraits,
    );
  }
}

/// Model for generation weights
class GenerationWeights {
  final Map<String, double> nameWeights;
  final Map<String, double> regionWeights;
  final Map<String, double> traitWeights;
  final Map<String, double> categoryWeights;
  final Map<String, double> packWeights;

  const GenerationWeights({
    required this.nameWeights,
    required this.regionWeights,
    required this.traitWeights,
    required this.categoryWeights,
    required this.packWeights,
  });

  factory GenerationWeights.defaultWeights() {
    return const GenerationWeights(
      nameWeights: {},
      regionWeights: {},
      traitWeights: {},
      categoryWeights: {},
      packWeights: {},
    );
  }

  factory GenerationWeights.fromJson(Map<String, dynamic> json) {
    return GenerationWeights(
      nameWeights: Map<String, double>.from(json['nameWeights'] ?? {}),
      regionWeights: Map<String, double>.from(json['regionWeights'] ?? {}),
      traitWeights: Map<String, double>.from(json['traitWeights'] ?? {}),
      categoryWeights: Map<String, double>.from(json['categoryWeights'] ?? {}),
      packWeights: Map<String, double>.from(json['packWeights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameWeights': nameWeights,
      'regionWeights': regionWeights,
      'traitWeights': traitWeights,
      'categoryWeights': categoryWeights,
      'packWeights': packWeights,
    };
  }

  GenerationWeights copyWith({
    Map<String, double>? nameWeights,
    Map<String, double>? regionWeights,
    Map<String, double>? traitWeights,
    Map<String, double>? categoryWeights,
    Map<String, double>? packWeights,
  }) {
    return GenerationWeights(
      nameWeights: nameWeights ?? this.nameWeights,
      regionWeights: regionWeights ?? this.regionWeights,
      traitWeights: traitWeights ?? this.traitWeights,
      categoryWeights: categoryWeights ?? this.categoryWeights,
      packWeights: packWeights ?? this.packWeights,
    );
  }
}
