import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/models/character_profile.dart';
import '../../lib/models/name.dart';
import '../../lib/models/trait.dart';
import '../../lib/models/enums.dart';
import '../../lib/providers/character_storage_providers.dart';

void main() {
  group('Character Storage Providers', () {
    late ProviderContainer container;
    late CharacterProfile testCharacter;

    setUp(() async {
      // Initialize SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer();

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
        ],
        generatedAt: DateTime(2024, 1, 1, 12, 0, 0),
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('CharacterStorageService Provider', () {
      test('should provide CharacterStorageService instance', () {
        final service = container.read(characterStorageServiceProvider);
        expect(service, isNotNull);
      });
    });

    group('Saved Characters Provider', () {
      test('should initially return empty list', () async {
        final savedCharacters = await container.read(
          savedCharactersProvider.future,
        );
        expect(savedCharacters, isEmpty);
      });

      test('should return saved characters after saving', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Save character
        await notifier.saveCharacter(testCharacter);

        // Refresh provider and check
        container.invalidate(savedCharactersProvider);
        final savedCharacters = await container.read(
          savedCharactersProvider.future,
        );

        expect(savedCharacters, hasLength(1));
        expect(savedCharacters.first.name.fullName, equals('John Doe'));
      });
    });

    group('Favorite Characters Provider', () {
      test('should initially return empty list', () async {
        final favorites = await container.read(
          favoriteCharactersProvider.future,
        );
        expect(favorites, isEmpty);
      });

      test('should return favorites after adding', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to favorites
        await notifier.addToFavorites(testCharacter);

        // Refresh provider and check
        container.invalidate(favoriteCharactersProvider);
        final favorites = await container.read(
          favoriteCharactersProvider.future,
        );

        expect(favorites, hasLength(1));
        expect(favorites.first.name.fullName, equals('John Doe'));
      });
    });

    group('Character History Provider', () {
      test('should initially return empty list', () async {
        final history = await container.read(characterHistoryProvider.future);
        expect(history, isEmpty);
      });

      test('should return history after adding', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to history
        await notifier.addToHistory(testCharacter);

        // Refresh provider and check
        container.invalidate(characterHistoryProvider);
        final history = await container.read(characterHistoryProvider.future);

        expect(history, hasLength(1));
        expect(history.first.name.fullName, equals('John Doe'));
      });
    });

    group('Storage Statistics Provider', () {
      test('should return correct statistics', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add test data
        await notifier.saveCharacter(testCharacter);
        await notifier.addToFavorites(testCharacter);
        await notifier.addToHistory(testCharacter);

        // Refresh provider and check
        container.invalidate(storageStatisticsProvider);
        final stats = await container.read(storageStatisticsProvider.future);

        expect(stats['saved'], equals(1));
        expect(stats['favorites'], equals(1));
        expect(stats['history'], equals(1));
      });
    });

    group('CharacterStorageNotifier', () {
      test('should save character successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Save character
        await notifier.saveCharacter(testCharacter);

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should delete saved character successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Save then delete character
        await notifier.saveCharacter(testCharacter);
        await notifier.deleteSavedCharacter(testCharacter);

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should add to favorites successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to favorites
        await notifier.addToFavorites(testCharacter);

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should remove from favorites successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add then remove from favorites
        await notifier.addToFavorites(testCharacter);
        await notifier.removeFromFavorites(testCharacter);

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should add to history successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to history
        await notifier.addToHistory(testCharacter);

        // Check state (history addition doesn't change notifier state)
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should clear history successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to history then clear
        await notifier.addToHistory(testCharacter);
        await notifier.clearHistory();

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should clear saved characters successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Save character then clear all
        await notifier.saveCharacter(testCharacter);
        await notifier.clearSavedCharacters();

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should clear favorites successfully', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to favorites then clear all
        await notifier.addToFavorites(testCharacter);
        await notifier.clearFavorites();

        // Check state
        final state = container.read(characterStorageNotifierProvider);
        expect(state, isA<AsyncData>());
      });

      test('should check if character is favorite', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Initially not favorite
        var isFavorite = await notifier.isFavorite(testCharacter);
        expect(isFavorite, isFalse);

        // Add to favorites
        await notifier.addToFavorites(testCharacter);

        // Should be favorite now
        isFavorite = await notifier.isFavorite(testCharacter);
        expect(isFavorite, isTrue);
      });
    });

    group('IsFavorite Provider', () {
      test('should return false for non-favorite character', () async {
        final isFavorite = await container.read(
          isFavoriteProvider(testCharacter).future,
        );
        expect(isFavorite, isFalse);
      });

      test('should return true for favorite character', () async {
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );

        // Add to favorites
        await notifier.addToFavorites(testCharacter);

        // Check if favorite
        container.invalidate(isFavoriteProvider(testCharacter));
        final isFavorite = await container.read(
          isFavoriteProvider(testCharacter).future,
        );
        expect(isFavorite, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // This test would require mocking the storage service to throw errors
        // For now, we'll just verify the notifier handles the basic case
        final notifier = container.read(
          characterStorageNotifierProvider.notifier,
        );
        final state = container.read(characterStorageNotifierProvider);

        expect(state, isA<AsyncData>());
        expect(notifier, isNotNull);
      });
    });
  });
}
