import 'package:flutter/material.dart';
import '../views/main_screen.dart';
import '../views/settings_screen.dart';
import '../views/trait_browser_screen.dart';
import '../views/saved_characters_screen.dart';
import '../views/favorites_screen.dart';
import '../views/character_history_screen.dart';
import '../views/splash_screen.dart';

/// App routes configuration for the Sims 4 Name Generator
///
/// Defines all named routes used throughout the application
/// for consistent navigation between screens.
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String traitBrowser = '/trait-browser';
  static const String savedCharacters = '/saved-characters';
  static const String favorites = '/favorites';
  static const String characterHistory = '/character-history';

  // Route generation
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const MainScreen(),
    settings: (context) => const SettingsScreen(),
    traitBrowser: (context) => const TraitBrowserScreen(),
    savedCharacters: (context) => const SavedCharactersScreen(),
    favorites: (context) => const FavoritesScreen(),
    characterHistory: (context) => const CharacterHistoryScreen(),
  };

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName) {
    return Navigator.of(context).pushNamed<T>(routeName);
  }

  /// Navigate to a named route and replace current screen
  static Future<T?> navigateToReplacement<T>(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.of(context).pushReplacementNamed<T, void>(routeName);
  }

  /// Navigate to a named route and clear the navigation stack
  static Future<T?> navigateToAndClear<T>(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.of(
      context,
    ).pushNamedAndRemoveUntil<T>(routeName, (route) => false);
  }

  /// Go back to previous screen
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}
