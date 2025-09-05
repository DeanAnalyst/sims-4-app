import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_profile.dart';
import '../models/trait.dart';

/// Service for managing saved character profiles using local storage
class CharacterStorageService {
  static const String _savedCharactersKey = 'saved_characters';
  static const String _favoritesKey = 'favorite_characters';
  static const String _historyKey = 'character_history';
  static const int _maxHistorySize = 50;

  /// Saves a character profile to the saved characters list
  Future<void> saveCharacter(CharacterProfile character) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCharacters = await getSavedCharacters();

    // Add the character with a unique ID based on timestamp
    final characterWithId = character.copyWith(generatedAt: DateTime.now());

    savedCharacters.add(characterWithId);

    // Convert to JSON and save
    final jsonList = savedCharacters.map((c) => c.toJson()).toList();
    await prefs.setString(_savedCharactersKey, jsonEncode(jsonList));
  }

  /// Retrieves all saved character profiles
  Future<List<CharacterProfile>> getSavedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedCharactersKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await prefs.remove(_savedCharactersKey);
      return [];
    }
  }

  /// Deletes a saved character profile
  Future<void> deleteSavedCharacter(CharacterProfile character) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCharacters = await getSavedCharacters();

    // Remove the character based on name and traits match (more reliable than timestamp)
    savedCharacters.removeWhere(
      (c) =>
          c.name.firstName == character.name.firstName &&
          c.name.lastName == character.name.lastName &&
          c.name.gender == character.name.gender &&
          c.name.region == character.name.region &&
          _traitsEqual(c.traits, character.traits),
    );

    // Save updated list
    final jsonList = savedCharacters.map((c) => c.toJson()).toList();
    await prefs.setString(_savedCharactersKey, jsonEncode(jsonList));
  }

  /// Adds a character to favorites
  Future<void> addToFavorites(CharacterProfile character) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteCharacters();

    if (!favorites.any((c) => c == character)) {
      favorites.add(character.copyWith(isFavorite: true));
      final jsonList = favorites.map((c) => c.toJson()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(jsonList));
    }
  }

  /// Removes a character from favorites
  Future<void> removeFromFavorites(CharacterProfile character) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteCharacters();

    favorites.removeWhere((c) => c == character);

    final jsonList = favorites.map((c) => c.toJson()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(jsonList));
  }

  /// Retrieves all favorite character profiles
  Future<List<CharacterProfile>> getFavoriteCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await prefs.remove(_favoritesKey);
      return [];
    }
  }

  /// Checks if a character is in favorites
  Future<bool> isFavorite(CharacterProfile character) async {
    final favorites = await getFavoriteCharacters();
    return favorites.any((c) => c == character);
  }

  /// Adds a character to generation history
  Future<void> addToHistory(CharacterProfile character) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getCharacterHistory();

    // Remove if already exists to avoid duplicates
    history.removeWhere(
      (c) =>
          c.name.firstName == character.name.firstName &&
          c.name.lastName == character.name.lastName &&
          c.name.gender == character.name.gender &&
          c.name.region == character.name.region &&
          _traitsEqual(c.traits, character.traits),
    );

    // Add to beginning of list (most recent first)
    history.insert(0, character);

    // Limit history size
    if (history.length > _maxHistorySize) {
      history.removeRange(_maxHistorySize, history.length);
    }

    final jsonList = history.map((c) => c.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Retrieves character generation history
  Future<List<CharacterProfile>> getCharacterHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => CharacterProfile.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await prefs.remove(_historyKey);
      return [];
    }
  }

  /// Clears character generation history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Clears all saved characters
  Future<void> clearSavedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedCharactersKey);
  }

  /// Clears all favorite characters
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  /// Exports a character profile as a formatted string
  String exportCharacter(CharacterProfile character) {
    return character.formattedProfile;
  }

  /// Exports multiple character profiles as a formatted string
  String exportCharacters(List<CharacterProfile> characters) {
    if (characters.isEmpty) {
      return 'No characters to export.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Sims 4 Character Profiles ===\n');

    for (int i = 0; i < characters.length; i++) {
      buffer.writeln('Character ${i + 1}:');
      buffer.writeln(characters[i].formattedProfile);
      if (i < characters.length - 1) {
        buffer.writeln('${'=' * 40}\n');
      }
    }

    return buffer.toString();
  }

  /// Gets statistics about saved data
  Future<Map<String, int>> getStorageStatistics() async {
    final savedCount = (await getSavedCharacters()).length;
    final favoritesCount = (await getFavoriteCharacters()).length;
    final historyCount = (await getCharacterHistory()).length;

    return {
      'saved': savedCount,
      'favorites': favoritesCount,
      'history': historyCount,
    };
  }

  /// Helper method to compare trait lists for equality
  bool _traitsEqual(List<Trait> traits1, List<Trait> traits2) {
    if (traits1.length != traits2.length) return false;

    // Sort both lists by trait ID for consistent comparison
    final sorted1 = List<Trait>.from(traits1)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sorted2 = List<Trait>.from(traits2)
      ..sort((a, b) => a.id.compareTo(b.id));

    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i].id != sorted2[i].id) return false;
    }

    return true;
  }
}
