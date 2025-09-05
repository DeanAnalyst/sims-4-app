import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/character_profile.dart';
import 'package:sims4_name_generator/models/enums.dart';

void main() {
  group('Name Model Tests', () {
    test('should create Name with all properties', () {
      final name = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      expect(name.firstName, equals('John'));
      expect(name.lastName, equals('Smith'));
      expect(name.gender, equals(Gender.male));
      expect(name.region, equals(Region.english));
      expect(name.fullName, equals('John Smith'));
    });

    test('should serialize to and from JSON correctly', () {
      final originalName = Name(
        firstName: 'Jane',
        lastName: 'Doe',
        gender: Gender.female,
        region: Region.northAfrican,
      );

      final json = originalName.toJson();
      final deserializedName = Name.fromJson(json);

      expect(deserializedName.firstName, equals(originalName.firstName));
      expect(deserializedName.lastName, equals(originalName.lastName));
      expect(deserializedName.gender, equals(originalName.gender));
      expect(deserializedName.region, equals(originalName.region));
    });

    test('should handle equality correctly', () {
      final name1 = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      final name2 = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      final name3 = Name(
        firstName: 'Jane',
        lastName: 'Smith',
        gender: Gender.female,
        region: Region.english,
      );

      expect(name1, equals(name2));
      expect(name1, isNot(equals(name3)));
      expect(name1.hashCode, equals(name2.hashCode));
    });
  });

  group('Trait Model Tests', () {
    test('should create Trait with all properties', () {
      final trait = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'These Sims gain powerful Moodlets from career success.',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      );

      expect(trait.id, equals('ambitious'));
      expect(trait.name, equals('Ambitious'));
      expect(trait.description, contains('career success'));
      expect(trait.category, equals(TraitCategory.lifestyle));
      expect(trait.pack, equals('base_game'));
      expect(trait.conflictingTraits, contains('lazy'));
    });

    test('should serialize to and from JSON correctly', () {
      final originalTrait = Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'These Sims tend to be Happier than other Sims.',
        category: TraitCategory.emotional,
        pack: 'base_game',
        conflictingTraits: ['gloomy', 'mean'],
      );

      final json = originalTrait.toJson();
      final deserializedTrait = Trait.fromJson(json);

      expect(deserializedTrait.id, equals(originalTrait.id));
      expect(deserializedTrait.name, equals(originalTrait.name));
      expect(deserializedTrait.description, equals(originalTrait.description));
      expect(deserializedTrait.category, equals(originalTrait.category));
      expect(deserializedTrait.pack, equals(originalTrait.pack));
      expect(
        deserializedTrait.conflictingTraits,
        equals(originalTrait.conflictingTraits),
      );
    });

    test('should detect conflicts correctly', () {
      final ambitious = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'Career focused',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      );

      final lazy = Trait(
        id: 'lazy',
        name: 'Lazy',
        description: 'Avoids work',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['ambitious'],
      );

      final cheerful = Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'Happy',
        category: TraitCategory.emotional,
        pack: 'base_game',
        conflictingTraits: [],
      );

      expect(ambitious.conflictsWith(lazy), isTrue);
      expect(lazy.conflictsWith(ambitious), isTrue);
      expect(ambitious.conflictsWith(cheerful), isFalse);
      expect(cheerful.conflictsWith(ambitious), isFalse);
    });

    test('should handle conflictsWithAny correctly', () {
      final ambitious = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'Career focused',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      );

      final lazy = Trait(
        id: 'lazy',
        name: 'Lazy',
        description: 'Avoids work',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['ambitious'],
      );

      final cheerful = Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'Happy',
        category: TraitCategory.emotional,
        pack: 'base_game',
        conflictingTraits: [],
      );

      expect(ambitious.conflictsWithAny([lazy, cheerful]), isTrue);
      expect(ambitious.conflictsWithAny([cheerful]), isFalse);
      expect(cheerful.conflictsWithAny([ambitious, lazy]), isFalse);
    });
  });

  group('CharacterProfile Model Tests', () {
    test('should create CharacterProfile with all properties', () {
      final name = Name(
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        region: Region.english,
      );

      final traits = [
        Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'Career focused',
          category: TraitCategory.lifestyle,
          pack: 'base_game',
          conflictingTraits: [],
        ),
      ];

      final generatedAt = DateTime.now();
      final profile = CharacterProfile(
        name: name,
        traits: traits,
        generatedAt: generatedAt,
      );

      expect(profile.name, equals(name));
      expect(profile.traits, equals(traits));
      expect(profile.generatedAt, equals(generatedAt));
    });

    test('should serialize to and from JSON correctly', () {
      final name = Name(
        firstName: 'Jane',
        lastName: 'Doe',
        gender: Gender.female,
        region: Region.eastAsian,
      );

      final traits = [
        Trait(
          id: 'cheerful',
          name: 'Cheerful',
          description: 'Happy',
          category: TraitCategory.emotional,
          pack: 'base_game',
          conflictingTraits: [],
        ),
        Trait(
          id: 'creative',
          name: 'Creative',
          description: 'Artistic',
          category: TraitCategory.hobby,
          pack: 'base_game',
          conflictingTraits: [],
        ),
      ];

      final generatedAt = DateTime.now();
      final originalProfile = CharacterProfile(
        name: name,
        traits: traits,
        generatedAt: generatedAt,
      );

      final json = originalProfile.toJson();
      final deserializedProfile = CharacterProfile.fromJson(json);

      expect(
        deserializedProfile.name.firstName,
        equals(originalProfile.name.firstName),
      );
      expect(
        deserializedProfile.name.lastName,
        equals(originalProfile.name.lastName),
      );
      expect(
        deserializedProfile.traits.length,
        equals(originalProfile.traits.length),
      );
      expect(
        deserializedProfile.traits[0].id,
        equals(originalProfile.traits[0].id),
      );
      expect(
        deserializedProfile.generatedAt.millisecondsSinceEpoch,
        equals(originalProfile.generatedAt.millisecondsSinceEpoch),
      );
    });
  });

  group('Enum Tests', () {
    test('should have all expected Region values', () {
      final expectedRegions = [
        Region.english,
        Region.northAfrican,
        Region.subSaharanAfrican,
        Region.eastAfrican,
        Region.southAfrican,
        Region.centralEuropean,
        Region.northernEuropean,
        Region.easternEuropean,
        Region.middleEastern,
        Region.southAsian,
        Region.eastAsian,
        Region.oceania,
        Region.lithuanian,
      ];

      expect(Region.values.length, equals(expectedRegions.length));
      for (final region in expectedRegions) {
        expect(Region.values, contains(region));
      }
    });

    test('should have all expected Gender values', () {
      expect(Gender.values, contains(Gender.male));
      expect(Gender.values, contains(Gender.female));
      expect(Gender.values.length, equals(2));
    });

    test('should have all expected TraitCategory values', () {
      final expectedCategories = [
        TraitCategory.emotional,
        TraitCategory.hobby,
        TraitCategory.lifestyle,
        TraitCategory.social,
        TraitCategory.toddler,
        TraitCategory.infant,
      ];

      expect(TraitCategory.values.length, equals(expectedCategories.length));
      for (final category in expectedCategories) {
        expect(TraitCategory.values, contains(category));
      }
    });
  });
}
