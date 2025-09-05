import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/character_profile.dart';

void main() {
  group('Core Functionality Tests', () {
    group('Name Model Tests', () {
      test('creates name with correct properties', () {
        const name = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        expect(name.firstName, equals('John'));
        expect(name.lastName, equals('Doe'));
        expect(name.gender, equals(Gender.male));
        expect(name.region, equals(Region.english));
        expect(name.fullName, equals('John Doe'));
      });

      test('converts to and from JSON correctly', () {
        const originalName = Name(
          firstName: 'Jane',
          lastName: 'Smith',
          gender: Gender.female,
          region: Region.english,
        );

        final json = originalName.toJson();
        final restoredName = Name.fromJson(json);

        expect(restoredName.firstName, equals(originalName.firstName));
        expect(restoredName.lastName, equals(originalName.lastName));
        expect(restoredName.gender, equals(originalName.gender));
        expect(restoredName.region, equals(originalName.region));
      });

      test('copyWith creates new instance with updated fields', () {
        const originalName = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        final updatedName = originalName.copyWith(
          firstName: 'Jane',
          gender: Gender.female,
        );

        expect(updatedName.firstName, equals('Jane'));
        expect(updatedName.lastName, equals('Doe')); // Unchanged
        expect(updatedName.gender, equals(Gender.female));
        expect(updatedName.region, equals(Region.english)); // Unchanged
      });

      test('equality comparison works correctly', () {
        const name1 = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        const name2 = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        const name3 = Name(
          firstName: 'Jane',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        expect(name1, equals(name2));
        expect(name1, isNot(equals(name3)));
      });
    });

    group('Trait Model Tests', () {
      test('creates trait with correct properties', () {
        const trait = Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'A Sim who is driven to succeed',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        expect(trait.id, equals('ambitious'));
        expect(trait.name, equals('Ambitious'));
        expect(trait.description, equals('A Sim who is driven to succeed'));
        expect(trait.category, equals(TraitCategory.emotional));
        expect(trait.pack, equals('base_game'));
      });

      test('converts to and from JSON correctly', () {
        const originalTrait = Trait(
          id: 'cheerful',
          name: 'Cheerful',
          description: 'A Sim who is always happy',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        final json = originalTrait.toJson();
        final restoredTrait = Trait.fromJson(json);

        expect(restoredTrait.id, equals(originalTrait.id));
        expect(restoredTrait.name, equals(originalTrait.name));
        expect(restoredTrait.description, equals(originalTrait.description));
        expect(restoredTrait.category, equals(originalTrait.category));
        expect(restoredTrait.pack, equals(originalTrait.pack));
      });

      test('copyWith creates new instance with updated fields', () {
        const originalTrait = Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'A Sim who is driven to succeed',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        final updatedTrait = originalTrait.copyWith(
          name: 'Very Ambitious',
          description: 'A Sim who is extremely driven to succeed',
        );

        expect(updatedTrait.id, equals('ambitious')); // Unchanged
        expect(updatedTrait.name, equals('Very Ambitious'));
        expect(updatedTrait.description, equals('A Sim who is extremely driven to succeed'));
        expect(updatedTrait.category, equals(TraitCategory.emotional)); // Unchanged
        expect(updatedTrait.pack, equals('base_game')); // Unchanged
      });

      test('equality comparison works correctly', () {
        const trait1 = Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'A Sim who is driven to succeed',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        const trait2 = Trait(
          id: 'ambitious',
          name: 'Ambitious',
          description: 'A Sim who is driven to succeed',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        const trait3 = Trait(
          id: 'cheerful',
          name: 'Cheerful',
          description: 'A Sim who is always happy',
          category: TraitCategory.emotional,
          pack: 'base_game',
        );

        expect(trait1, equals(trait2));
        expect(trait1, isNot(equals(trait3)));
      });
    });

    group('Character Profile Tests', () {
      test('creates character profile with correct properties', () {
        const name = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        final traits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'A Sim who is driven to succeed',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final profile = CharacterProfile(
          name: name,
          traits: traits,
          generatedAt: DateTime(2024, 1, 1),
        );

        expect(profile.name, equals(name));
        expect(profile.traits, equals(traits));
        expect(profile.generatedAt, equals(DateTime(2024, 1, 1)));
      });

      test('converts to and from JSON correctly', () {
        const name = Name(
          firstName: 'Jane',
          lastName: 'Smith',
          gender: Gender.female,
          region: Region.english,
        );

        final traits = [
          const Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'A Sim who is always happy',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final originalProfile = CharacterProfile(
          name: name,
          traits: traits,
          generatedAt: DateTime(2024, 1, 1),
        );

        final json = originalProfile.toJson();
        final restoredProfile = CharacterProfile.fromJson(json);

        expect(restoredProfile.name.firstName, equals(originalProfile.name.firstName));
        expect(restoredProfile.name.lastName, equals(originalProfile.name.lastName));
        expect(restoredProfile.name.gender, equals(originalProfile.name.gender));
        expect(restoredProfile.name.region, equals(originalProfile.name.region));
        expect(restoredProfile.traits.length, equals(originalProfile.traits.length));
        expect(restoredProfile.traits.first.id, equals(originalProfile.traits.first.id));
      });

      test('copyWith creates new instance with updated fields', () {
        const name = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        final traits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'A Sim who is driven to succeed',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final originalProfile = CharacterProfile(
          name: name,
          traits: traits,
          generatedAt: DateTime(2024, 1, 1),
        );

        final newTraits = [
          const Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'A Sim who is always happy',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final updatedProfile = originalProfile.copyWith(traits: newTraits);

        expect(updatedProfile.name, equals(name)); // Unchanged
        expect(updatedProfile.traits, equals(newTraits));
        expect(updatedProfile.generatedAt, equals(DateTime(2024, 1, 1))); // Unchanged
      });
    });

    group('Enum Tests', () {
      test('Region enum values are correct', () {
        expect(Region.values.length, greaterThan(0));
        expect(Region.english, isA<Region>());
        expect(Region.english.name, equals('english'));
      });

      test('Gender enum values are correct', () {
        expect(Gender.values.length, equals(2));
        expect(Gender.male, isA<Gender>());
        expect(Gender.female, isA<Gender>());
        expect(Gender.male.name, equals('male'));
        expect(Gender.female.name, equals('female'));
      });

      test('TraitCategory enum values are correct', () {
        expect(TraitCategory.values.length, greaterThan(0));
        expect(TraitCategory.emotional, isA<TraitCategory>());
        expect(TraitCategory.emotional.name, equals('emotional'));
      });

      test('enum fromString conversion works', () {
        expect(Gender.values.byName('male'), equals(Gender.male));
        expect(Gender.values.byName('female'), equals(Gender.female));
        expect(Region.values.byName('english'), equals(Region.english));
        expect(TraitCategory.values.byName('emotional'), equals(TraitCategory.emotional));
      });
    });

    group('Data Validation Tests', () {
      test('validates name data structure', () {
        final validNameData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'gender': 'male',
          'region': 'english',
        };

        expect(() => Name.fromJson(validNameData), returnsNormally);
      });

      test('validates trait data structure', () {
        final validTraitData = {
          'id': 'ambitious',
          'name': 'Ambitious',
          'description': 'A Sim who is driven to succeed',
          'category': 'emotional',
          'pack': 'base_game',
        };

        expect(() => Trait.fromJson(validTraitData), returnsNormally);
      });

      test('handles invalid enum values gracefully', () {
        final invalidNameData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'gender': 'invalid_gender',
          'region': 'english',
        };

        expect(
          () => Name.fromJson(invalidNameData),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Performance Tests', () {
      test('creates multiple names efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          Name(
            firstName: 'Name$i',
            lastName: 'Surname$i',
            gender: Gender.male,
            region: Region.english,
          );
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });

      test('creates multiple traits efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          Trait(
            id: 'trait$i',
            name: 'Trait $i',
            description: 'Description $i',
            category: TraitCategory.emotional,
            pack: 'base_game',
          );
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });

      test('creates multiple character profiles efficiently', () {
        const name = Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        );

        final traits = [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'A Sim who is driven to succeed',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ];

        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          CharacterProfile(
            name: name,
            traits: traits,
            generatedAt: DateTime.now(),
          );
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be reasonably fast
      });
    });
  });
} 