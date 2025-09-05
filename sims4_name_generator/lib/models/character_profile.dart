import 'name.dart';
import 'trait.dart';

/// Model representing a complete character profile with name and traits
class CharacterProfile {
  final Name name;
  final List<Trait> traits;
  final DateTime generatedAt;
  final bool isFavorite;

  const CharacterProfile({
    required this.name,
    required this.traits,
    required this.generatedAt,
    this.isFavorite = false,
  });

  /// Creates a CharacterProfile instance from JSON data
  factory CharacterProfile.fromJson(Map<String, dynamic> json) {
    return CharacterProfile(
      name: Name.fromJson(json['name'] as Map<String, dynamic>),
      traits: (json['traits'] as List<dynamic>)
          .map((traitJson) => Trait.fromJson(traitJson as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Converts the CharacterProfile instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'traits': traits.map((trait) => trait.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  /// Returns a formatted string representation of the character
  String get formattedProfile {
    final buffer = StringBuffer();
    buffer.writeln('Name: ${name.fullName}');
    buffer.writeln('Region: ${name.region.name}');
    buffer.writeln('Gender: ${name.gender.name}');

    if (traits.isNotEmpty) {
      buffer.writeln('Traits:');
      for (final trait in traits) {
        buffer.writeln('  • ${trait.name} (${trait.category.name})');
      }
    }

    buffer.writeln('Generated: ${generatedAt.toString()}');
    return buffer.toString();
  }

  /// Checks if the character profile has valid traits (no conflicts, max 3 traits)
  bool get isValid {
    if (traits.length > 3) return false;

    for (int i = 0; i < traits.length; i++) {
      for (int j = i + 1; j < traits.length; j++) {
        if (traits[i].conflictsWith(traits[j])) {
          return false;
        }
      }
    }

    return true;
  }

  /// Returns the number of traits in this profile
  int get traitCount => traits.length;

  /// Checks if this profile has the maximum number of traits (3)
  bool get hasMaxTraits => traits.length >= 3;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterProfile &&
        other.name == name &&
        _listEquals(other.traits, traits) &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return name.hashCode ^ traits.hashCode ^ generatedAt.hashCode;
  }

  @override
  String toString() {
    return 'CharacterProfile(name: ${name.fullName}, traits: ${traits.length}, generatedAt: $generatedAt)';
  }

  /// Creates a copy of this CharacterProfile with optionally updated fields
  CharacterProfile copyWith({
    Name? name,
    List<Trait>? traits,
    DateTime? generatedAt,
    bool? isFavorite,
  }) {
    return CharacterProfile(
      name: name ?? this.name,
      traits: traits ?? this.traits,
      generatedAt: generatedAt ?? this.generatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Helper method to compare lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
