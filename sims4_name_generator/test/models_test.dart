import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/models.dart';

void main() {
  group('Core Models Tests', () {
    test('Name model creation and serialization', () {
      final name = Name(
        firstName: 'John',
        lastName: 'Doe',
        gender: Gender.male,
        region: Region.english,
      );

      expect(name.fullName, equals('John Doe'));
      expect(name.firstName, equals('John'));
      expect(name.lastName, equals('Doe'));
      expect(name.gender, equals(Gender.male));
      expect(name.region, equals(Region.english));

      // Test JSON serialization
      final json = name.toJson();
      final nameFromJson = Name.fromJson(json);
      expect(nameFromJson, equals(name));
    });

    test('Trait model creation and conflict detection', () {
      final trait1 = Trait(
        id: 'ambitious',
        name: 'Ambitious',
        description: 'These Sims gain powerful Moodlets from career success.',
        category: TraitCategory.emotional,
        pack: 'base_game',
        conflictingTraits: ['lazy'],
      );

      final trait2 = Trait(
        id: 'lazy',
        name: 'Lazy',
        description: 'These Sims prefer to avoid work.',
        category: TraitCategory.lifestyle,
        pack: 'base_game',
        conflictingTraits: ['ambitious'],
      );

      expect(trait1.conflictsWith(trait2), isTrue);
      expect(trait2.conflictsWith(trait1), isTrue);

      // Test JSON serialization
      final json = trait1.toJson();
      final traitFromJson = Trait.fromJson(json);
      expect(traitFromJson, equals(trait1));
    });

    test('CharacterProfile model creation and validation', () {
      final name = Name(
        firstName: 'Jane',
        lastName: 'Smith',
        gender: Gender.female,
        region: Region.english,
      );

      final trait1 = Trait(
        id: 'cheerful',
        name: 'Cheerful',
        description: 'These Sims tend to be Happier than other Sims.',
        category: TraitCategory.emotional,
        pack: 'base_game',
      );

      final trait2 = Trait(
        id: 'creative',
        name: 'Creative',
        description: 'These Sims tend to be inspired.',
        category: TraitCategory.hobby,
        pack: 'base_game',
      );

      final profile = CharacterProfile(
        name: name,
        traits: [trait1, trait2],
        generatedAt: DateTime.now(),
      );

      expect(profile.isValid, isTrue);
      expect(profile.traitCount, equals(2));
      expect(profile.hasMaxTraits, isFalse);

      // Test JSON serialization
      final json = profile.toJson();
      final profileFromJson = CharacterProfile.fromJson(json);
      expect(profileFromJson.name, equals(profile.name));
      expect(profileFromJson.traits.length, equals(profile.traits.length));
    });

    test('Enum values are correctly defined', () {
      // Test Region enum
      expect(Region.values.length, equals(13));
      expect(Region.values.contains(Region.english), isTrue);
      expect(Region.values.contains(Region.lithuanian), isTrue);

      // Test Gender enum
      expect(Gender.values.length, equals(2));
      expect(Gender.values.contains(Gender.male), isTrue);
      expect(Gender.values.contains(Gender.female), isTrue);

      // Test TraitCategory enum
      expect(TraitCategory.values.length, equals(6));
      expect(TraitCategory.values.contains(TraitCategory.emotional), isTrue);
      expect(TraitCategory.values.contains(TraitCategory.infant), isTrue);
    });
  });
}
