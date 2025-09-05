import 'enums.dart';

/// Model representing a Sims 4 character trait
class Trait {
  final String id;
  final String name;
  final String description;
  final TraitCategory category;
  final String pack;
  final List<String> conflictingTraits;
  final List<LifeStage> allowedLifeStages;
  final LifeStage? minimumAge;
  final LifeStage? maximumAge;

  const Trait({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pack,
    this.conflictingTraits = const [],
    this.allowedLifeStages = const [],
    this.minimumAge,
    this.maximumAge,
  });

  /// Creates a Trait instance from JSON data
  factory Trait.fromJson(Map<String, dynamic> json) {
    return Trait(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: TraitCategory.values.byName(json['category'] as String),
      pack: json['pack'] as String,
      conflictingTraits:
          (json['conflictingTraits'] as List<dynamic>?)?.cast<String>() ??
          const [],
      allowedLifeStages: (json['allowedLifeStages'] as List<dynamic>?)
          ?.map((stage) => LifeStage.values.byName(stage as String))
          .toList() ?? const [],
      minimumAge: json['minimumAge'] != null 
          ? LifeStage.values.byName(json['minimumAge'] as String)
          : null,
      maximumAge: json['maximumAge'] != null 
          ? LifeStage.values.byName(json['maximumAge'] as String)
          : null,
    );
  }

  /// Converts the Trait instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'pack': pack,
      'conflictingTraits': conflictingTraits,
      'allowedLifeStages': allowedLifeStages.map((stage) => stage.name).toList(),
      if (minimumAge != null) 'minimumAge': minimumAge!.name,
      if (maximumAge != null) 'maximumAge': maximumAge!.name,
    };
  }

  /// Checks if this trait conflicts with another trait
  bool conflictsWith(Trait other) {
    return conflictingTraits.contains(other.id) ||
        other.conflictingTraits.contains(id);
  }

  /// Checks if this trait conflicts with any trait in a list
  bool conflictsWithAny(List<Trait> traits) {
    return traits.any((trait) => conflictsWith(trait));
  }

  /// Checks if this trait is appropriate for a specific life stage
  bool isAppropriateForLifeStage(LifeStage lifeStage) {
    // If no restrictions are set, trait is available for all ages
    if (allowedLifeStages.isEmpty && minimumAge == null && maximumAge == null) {
      return true;
    }

    // Check if explicitly allowed
    if (allowedLifeStages.isNotEmpty) {
      return allowedLifeStages.contains(lifeStage);
    }

    // Check minimum age requirement
    if (minimumAge != null && lifeStage.index < minimumAge!.index) {
      return false;
    }

    // Check maximum age requirement
    if (maximumAge != null && lifeStage.index > maximumAge!.index) {
      return false;
    }

    return true;
  }

  /// Checks if this trait is age-restricted (has any age limitations)
  bool get isAgeRestricted {
    return allowedLifeStages.isNotEmpty || 
           minimumAge != null || 
           maximumAge != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trait &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.pack == pack &&
        _listEquals(other.conflictingTraits, conflictingTraits) &&
        _listEquals(other.allowedLifeStages.map((e) => e.name).toList(), 
                   allowedLifeStages.map((e) => e.name).toList()) &&
        other.minimumAge == minimumAge &&
        other.maximumAge == maximumAge;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        pack.hashCode ^
        conflictingTraits.hashCode ^
        allowedLifeStages.hashCode ^
        (minimumAge?.hashCode ?? 0) ^
        (maximumAge?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Trait(id: $id, name: $name, category: $category, pack: $pack)';
  }

  /// Creates a copy of this Trait with optionally updated fields
  Trait copyWith({
    String? id,
    String? name,
    String? description,
    TraitCategory? category,
    String? pack,
    List<String>? conflictingTraits,
    List<LifeStage>? allowedLifeStages,
    LifeStage? minimumAge,
    LifeStage? maximumAge,
  }) {
    return Trait(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      pack: pack ?? this.pack,
      conflictingTraits: conflictingTraits ?? this.conflictingTraits,
      allowedLifeStages: allowedLifeStages ?? this.allowedLifeStages,
      minimumAge: minimumAge ?? this.minimumAge,
      maximumAge: maximumAge ?? this.maximumAge,
    );
  }
}

/// Helper function to compare lists for equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
