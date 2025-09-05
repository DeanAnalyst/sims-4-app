import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/navigation/app_routes.dart';

void main() {
  group('AppRoutes Tests', () {
    test('should provide correct route names', () {
      expect(AppRoutes.home, equals('/'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.traitBrowser, equals('/trait-browser'));
      expect(AppRoutes.savedCharacters, equals('/saved-characters'));
      expect(AppRoutes.favorites, equals('/favorites'));
      expect(AppRoutes.characterHistory, equals('/character-history'));
    });

    test('should provide route builders', () {
      final routes = AppRoutes.routes;

      expect(routes, contains(AppRoutes.home));
      expect(routes, contains(AppRoutes.settings));
      expect(routes, contains(AppRoutes.traitBrowser));
      expect(routes, contains(AppRoutes.savedCharacters));
      expect(routes, contains(AppRoutes.favorites));
      expect(routes, contains(AppRoutes.characterHistory));
      expect(routes.length, equals(6));
    });

    test('should have builders for all routes', () {
      final routes = AppRoutes.routes;

      for (final routeName in routes.keys) {
        expect(routes[routeName], isNotNull);
        expect(routes[routeName], isA<Function>());
      }
    });
  });
}
