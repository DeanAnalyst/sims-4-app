import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character_profile.dart';
import '../services/character_storage_service.dart';

/// Provider for the character storage service
final characterStorageServiceProvider = Provider<CharacterStorageService>((
  ref,
) {
  return CharacterStorageService();
});

/// Provider for saved characters
final savedCharactersProvider = FutureProvider<List<CharacterProfile>>((
  ref,
) async {
  final storageService = ref.watch(characterStorageServiceProvider);
  return await storageService.getSavedCharacters();
});

/// Provider for favorite characters
final favoriteCharactersProvider = FutureProvider<List<CharacterProfile>>((
  ref,
) async {
  final storageService = ref.watch(characterStorageServiceProvider);
  return await storageService.getFavoriteCharacters();
});

/// Provider for character history
final characterHistoryProvider = FutureProvider<List<CharacterProfile>>((
  ref,
) async {
  final storageService = ref.watch(characterStorageServiceProvider);
  return await storageService.getCharacterHistory();
});

/// Provider for storage statistics
final storageStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final storageService = ref.watch(characterStorageServiceProvider);
  return await storageService.getStorageStatistics();
});

/// State notifier for managing character storage operations
class CharacterStorageNotifier extends StateNotifier<AsyncValue<void>> {
  final CharacterStorageService _storageService;
  final Ref _ref;

  CharacterStorageNotifier(this._storageService, this._ref)
    : super(const AsyncValue.data(null));

  /// Saves a character profile
  Future<void> saveCharacter(CharacterProfile character) async {
    state = const AsyncValue.loading();
    try {
      await _storageService.saveCharacter(character);
      state = const AsyncValue.data(null);

      // Refresh the saved characters list
      _ref.invalidate(savedCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletes a saved character
  Future<void> deleteSavedCharacter(CharacterProfile character) async {
    state = const AsyncValue.loading();
    try {
      await _storageService.deleteSavedCharacter(character);
      state = const AsyncValue.data(null);

      // Refresh the saved characters list
      _ref.invalidate(savedCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Adds a character to favorites
  Future<void> addToFavorites(CharacterProfile character) async {
    state = const AsyncValue.loading();
    try {
      await _storageService.addToFavorites(character);
      state = const AsyncValue.data(null);

      // Refresh the favorites list
      _ref.invalidate(favoriteCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Removes a character from favorites
  Future<void> removeFromFavorites(CharacterProfile character) async {
    state = const AsyncValue.loading();
    try {
      await _storageService.removeFromFavorites(character);
      state = const AsyncValue.data(null);

      // Refresh the favorites list
      _ref.invalidate(favoriteCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Adds a character to history
  Future<void> addToHistory(CharacterProfile character) async {
    try {
      await _storageService.addToHistory(character);

      // Refresh the history list
      _ref.invalidate(characterHistoryProvider);
    } catch (error) {
      // History addition shouldn't block the UI, so we don't update state
      // but we could log the error
    }
  }

  /// Clears character history
  Future<void> clearHistory() async {
    state = const AsyncValue.loading();
    try {
      await _storageService.clearHistory();
      state = const AsyncValue.data(null);

      // Refresh the history list
      _ref.invalidate(characterHistoryProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clears all saved characters
  Future<void> clearSavedCharacters() async {
    state = const AsyncValue.loading();
    try {
      await _storageService.clearSavedCharacters();
      state = const AsyncValue.data(null);

      // Refresh the saved characters list
      _ref.invalidate(savedCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clears all favorites
  Future<void> clearFavorites() async {
    state = const AsyncValue.loading();
    try {
      await _storageService.clearFavorites();
      state = const AsyncValue.data(null);

      // Refresh the favorites list
      _ref.invalidate(favoriteCharactersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Shares a single character
  Future<void> shareCharacter(CharacterProfile character) async {
    try {
      final exportText = _storageService.exportCharacter(character);
      await Share.share(
        exportText,
        subject: 'Sims 4 Character: ${character.name.fullName}',
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Shares multiple characters
  Future<void> shareCharacters(List<CharacterProfile> characters) async {
    try {
      final exportText = _storageService.exportCharacters(characters);
      await Share.share(
        exportText,
        subject: 'Sims 4 Characters (${characters.length})',
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Checks if a character is in favorites
  Future<bool> isFavorite(CharacterProfile character) async {
    return await _storageService.isFavorite(character);
  }
}

/// Provider for the character storage notifier
final characterStorageNotifierProvider =
    StateNotifierProvider<CharacterStorageNotifier, AsyncValue<void>>((ref) {
      final storageService = ref.watch(characterStorageServiceProvider);
      return CharacterStorageNotifier(storageService, ref);
    });

/// Provider to check if a specific character is a favorite
final isFavoriteProvider = FutureProvider.family<bool, CharacterProfile>((
  ref,
  character,
) async {
  final storageService = ref.watch(characterStorageServiceProvider);
  return await storageService.isFavorite(character);
});
