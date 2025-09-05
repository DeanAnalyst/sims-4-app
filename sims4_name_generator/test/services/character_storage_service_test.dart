import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/models/character_profile.dart';
import '../../lib/models/name.dart';
import '../../lib/models/trait.dart';
import '../../lib/models/enums.dart';
import '../../lib/services/character_storage_service.dart';

void main() {
  group('CharacterStorageService', () {
    late CharacterStorageService service;
    late CharacterProfile testCharacter;

    setUp(() async {
      // Initialize SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});
      service = CharacterStorageService();

      // Create test character
      testCharacter = CharacterProfile(
        name: const Name(
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.male,
          region: Region.english,
        ),
        traits: [
          const Trait(
            id: 'ambitious',
            name: 'Ambitious',
            description: 'Test trait',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
          const Trait(
            id: 'cheerful',
            name: 'Cheerful',
            description: 'Test trait 2',
            category: TraitCategory.emotional,
            pack: 'base_game',
          ),
        ],
        generatedAt: DateTime(2024, 1, 1, 12, 0, 0),
      );
    });

    group('Saved Characters', () {
      test('should save and retrieve characters', () async {
        // Initially empty
        var savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, isEmpty);

        // Save character
        await service.saveCharacter(testCharacter);

        // Retrieve and verify
        savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, hasLength(1));
        expect(savedCharacters.first.name.fullName, equals('John Doe'));
        expect(savedCharacters.first.traits, hasLength(2));
      });

      test('should delete saved characters', () async {
        // Save character first
        await service.saveCharacter(testCharacter);
        var savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, hasLength(1));

        // Delete character
        await service.deleteSavedCharacter(testCharacter);

        // Verify deletion
        savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, isEmpty);
      });

      test('should clear all saved characters', () async {
        // Save multiple characters
        await service.saveCharacter(testCharacter);
        await service.saveCharacter(
          testCharacter.copyWith(
            name: testCharacter.name.copyWith(firstName: 'Jane'),
          ),
        );

        var savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, hasLength(2));

        // Clear all
        await service.clearSavedCharacters();

        // Verify cleared
        savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, isEmpty);
      });
    });

    group('Favorite Characters', () {
      test('should add and retrieve favorites', () async {
        // Initially empty
        var favorites = await service.getFavoriteCharacters();
        expect(favorites, isEmpty);

        // Add to favorites
        await service.addToFavorites(testCharacter);

        // Retrieve and verify
        favorites = await service.getFavoriteCharacters();
        expect(favorites, hasLength(1));
        expect(favorites.first.name.fullName, equals('John Doe'));
      });

      test('should not add duplicate favorites', () async {
        // Add to favorites twice
        await service.addToFavorites(testCharacter);
        await service.addToFavorites(testCharacter);

        // Should only have one
        final favorites = await service.getFavoriteCharacters();
        expect(favorites, hasLength(1));
      });

      test('should remove from favorites', () async {
        // Add to favorites first
        await service.addToFavorites(testCharacter);
        var favorites = await service.getFavoriteCharacters();
        expect(favorites, hasLength(1));

        // Remove from favorites
        await service.removeFromFavorites(testCharacter);

        // Verify removal
        favorites = await service.getFavoriteCharacters();
        expect(favorites, isEmpty);
      });

      test('should check if character is favorite', () async {
        // Initially not favorite
        var isFavorite = await service.isFavorite(testCharacter);
        expect(isFavorite, isFalse);

        // Add to favorites
        await service.addToFavorites(testCharacter);

        // Should be favorite now
        isFavorite = await service.isFavorite(testCharacter);
        expect(isFavorite, isTrue);
      });

      test('should clear all favorites', () async {
        // Add multiple favorites
        await service.addToFavorites(testCharacter);
        await service.addToFavorites(
          testCharacter.copyWith(
            name: testCharacter.name.copyWith(firstName: 'Jane'),
          ),
        );

        var favorites = await service.getFavoriteCharacters();
        expect(favorites, hasLength(2));

        // Clear all
        await service.clearFavorites();

        // Verify cleared
        favorites = await service.getFavoriteCharacters();
        expect(favorites, isEmpty);
      });
    });

    group('Character History', () {
      test('should add and retrieve history', () async {
        // Initially empty
        var history = await service.getCharacterHistory();
        expect(history, isEmpty);

        // Add to history
        await service.addToHistory(testCharacter);

        // Retrieve and verify
        history = await service.getCharacterHistory();
        expect(history, hasLength(1));
        expect(history.first.name.fullName, equals('John Doe'));
      });

      test('should maintain history order (most recent first)', () async {
        final character1 = testCharacter.copyWith(
          name: testCharacter.name.copyWith(firstName: 'John'),
          generatedAt: DateTime(2024, 1, 1, 12, 0, 0),
        );
        final character2 = testCharacter.copyWith(
          name: testCharacter.name.copyWith(firstName: 'Jane'),
          generatedAt: DateTime(2024, 1, 1, 13, 0, 0),
        );

        // Add characters in order
        await service.addToHistory(character1);
        await service.addToHistory(character2);

        // History should have most recent first
        final history = await service.getCharacterHistory();
        expect(history, hasLength(2));
        expect(history.first.name.firstName, equals('Jane'));
        expect(history.last.name.firstName, equals('John'));
      });

      test('should limit history size', () async {
        // Add more than max history size (50)
        for (int i = 0; i < 55; i++) {
          final character = testCharacter.copyWith(
            name: testCharacter.name.copyWith(firstName: 'Character$i'),
            generatedAt: DateTime(2024, 1, 1, 12, i, 0),
          );
          await service.addToHistory(character);
        }

        // Should be limited to 50
        final history = await service.getCharacterHistory();
        expect(history, hasLength(50));

        // Should have most recent characters
        expect(history.first.name.firstName, equals('Character54'));
        expect(history.last.name.firstName, equals('Character5'));
      });

      test('should remove duplicates from history', () async {
        // Add same character twice
        await service.addToHistory(testCharacter);
        await service.addToHistory(testCharacter);

        // Should only have one entry
        final history = await service.getCharacterHistory();
        expect(history, hasLength(1));
      });

      test('should clear history', () async {
        // Add to history
        await service.addToHistory(testCharacter);
        var history = await service.getCharacterHistory();
        expect(history, hasLength(1));

        // Clear history
        await service.clearHistory();

        // Verify cleared
        history = await service.getCharacterHistory();
        expect(history, isEmpty);
      });
    });

    group('Export and Share', () {
      test('should export single character', () async {
        final exportText = service.exportCharacter(testCharacter);

        expect(exportText, contains('John Doe'));
        expect(exportText, contains('english'));
        expect(exportText, contains('male'));
        expect(exportText, contains('Ambitious'));
        expect(exportText, contains('Cheerful'));
      });

      test('should export multiple characters', () async {
        final characters = [
          testCharacter,
          testCharacter.copyWith(
            name: testCharacter.name.copyWith(firstName: 'Jane'),
          ),
        ];

        final exportText = service.exportCharacters(characters);

        expect(exportText, contains('Sims 4 Character Profiles'));
        expect(exportText, contains('John Doe'));
        expect(exportText, contains('Jane Doe'));
        expect(exportText, contains('Character 1:'));
        expect(exportText, contains('Character 2:'));
      });

      test('should handle empty character list export', () async {
        final exportText = service.exportCharacters([]);
        expect(exportText, equals('No characters to export.'));
      });
    });

    group('Storage Statistics', () {
      test('should return correct statistics', () async {
        // Add test data
        await service.saveCharacter(testCharacter);
        await service.addToFavorites(testCharacter);
        await service.addToHistory(testCharacter);

        final stats = await service.getStorageStatistics();

        expect(stats['saved'], equals(1));
        expect(stats['favorites'], equals(1));
        expect(stats['history'], equals(1));
      });

      test('should return zero statistics when empty', () async {
        final stats = await service.getStorageStatistics();

        expect(stats['saved'], equals(0));
        expect(stats['favorites'], equals(0));
        expect(stats['history'], equals(0));
      });
    });

    group('Error Handling', () {
      test('should handle corrupted data gracefully', () async {
        // Manually set corrupted data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_characters', 'invalid json');

        // Should return empty list and clear corrupted data
        final savedCharacters = await service.getSavedCharacters();
        expect(savedCharacters, isEmpty);

        // Corrupted data should be cleared
        final clearedData = prefs.getString('saved_characters');
        expect(clearedData, isNull);
      });
    });
  });
}
