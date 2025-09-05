import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims4_name_generator/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('should provide light theme with correct properties', () {
      final lightTheme = AppTheme.lightTheme;

      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.brightness, equals(Brightness.light));

      // Check primary colors
      expect(lightTheme.colorScheme.primary, equals(const Color(0xFFE1BEE7)));
      expect(lightTheme.colorScheme.secondary, equals(const Color(0xFFF2D7D5)));
      expect(lightTheme.colorScheme.tertiary, equals(const Color(0xFFC8A2C8)));

      // Check surface color
      expect(lightTheme.colorScheme.surface, equals(const Color(0xFFF6F0F6)));

      // Check text colors
      expect(lightTheme.colorScheme.onPrimary, equals(const Color(0xFF2D2D2D)));
      expect(
        lightTheme.colorScheme.onSecondary,
        equals(const Color(0xFF2D2D2D)),
      );
      expect(lightTheme.colorScheme.onSurface, equals(const Color(0xFF2D2D2D)));
    });

    test('should provide dark theme with correct properties', () {
      final darkTheme = AppTheme.darkTheme;

      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.brightness, equals(Brightness.dark));

      // Check that dark theme has different colors from light theme
      expect(
        darkTheme.colorScheme.surface,
        isNot(equals(AppTheme.lightTheme.colorScheme.surface)),
      );
    });

    test('should configure app bar theme correctly', () {
      final lightTheme = AppTheme.lightTheme;

      expect(
        lightTheme.appBarTheme.backgroundColor,
        equals(const Color(0xFFE1BEE7)),
      );
      expect(
        lightTheme.appBarTheme.foregroundColor,
        equals(const Color(0xFF2D2D2D)),
      );
      expect(lightTheme.appBarTheme.elevation, equals(0));
      expect(lightTheme.appBarTheme.centerTitle, isTrue);
    });

    test('should configure elevated button theme correctly', () {
      final lightTheme = AppTheme.lightTheme;
      final buttonStyle = lightTheme.elevatedButtonTheme.style;

      expect(buttonStyle, isNotNull);

      // Check button colors
      final backgroundColor = buttonStyle!.backgroundColor?.resolve({});
      final foregroundColor = buttonStyle.foregroundColor?.resolve({});

      expect(backgroundColor, equals(const Color(0xFFE1BEE7)));
      expect(foregroundColor, equals(const Color(0xFF2D2D2D)));

      // Check button shape (actual implementation uses 16.0)
      final shape = buttonStyle.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, equals(BorderRadius.circular(16)));
    });

    test('should configure card theme correctly', () {
      final lightTheme = AppTheme.lightTheme;

      expect(lightTheme.cardTheme.color, equals(const Color(0xFFF6F0F6)));
      expect(
        lightTheme.cardTheme.elevation,
        equals(4.0),
      ); // Actual value is 4.0

      final shape = lightTheme.cardTheme.shape as RoundedRectangleBorder?;
      expect(
        shape?.borderRadius,
        equals(const BorderRadius.all(Radius.circular(16))),
      );
    });

    test('should provide consistent color scheme', () {
      final lightTheme = AppTheme.lightTheme;
      final colorScheme = lightTheme.colorScheme;

      // Ensure all required colors are defined
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.tertiary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.onPrimary, isNotNull);
      expect(colorScheme.onSecondary, isNotNull);
      expect(colorScheme.onSurface, isNotNull);
    });

    test('should have different themes for light and dark modes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, isNot(equals(darkTheme.brightness)));
      expect(
        lightTheme.colorScheme.surface,
        isNot(equals(darkTheme.colorScheme.surface)),
      );
    });

    test('should provide gradient backgrounds', () {
      final lightGradient = AppTheme.lightBackgroundGradient;
      final darkGradient = AppTheme.darkBackgroundGradient;

      expect(lightGradient, isA<LinearGradient>());
      expect(darkGradient, isA<LinearGradient>());
      expect(lightGradient.colors.length, equals(2));
      expect(darkGradient.colors.length, equals(2));
    });

    test('should provide animation durations', () {
      expect(
        AppTheme.shortAnimation,
        equals(const Duration(milliseconds: 200)),
      );
      expect(
        AppTheme.mediumAnimation,
        equals(const Duration(milliseconds: 300)),
      );
      expect(AppTheme.longAnimation, equals(const Duration(milliseconds: 500)));
    });

    test('should create gradient containers', () {
      final lightContainer = AppTheme.createGradientContainer(
        child: const Text('Test'),
        isDark: false,
      );

      final darkContainer = AppTheme.createGradientContainer(
        child: const Text('Test'),
        isDark: true,
      );

      expect(lightContainer, isA<Container>());
      expect(darkContainer, isA<Container>());
    });

    test('should create gradient cards', () {
      final lightCard = AppTheme.createGradientCard(
        child: const Text('Test'),
        isDark: false,
      );

      final darkCard = AppTheme.createGradientCard(
        child: const Text('Test'),
        isDark: true,
      );

      expect(lightCard, isA<Container>());
      expect(darkCard, isA<Container>());
    });

    test('should create animated buttons', () {
      final lightButton = AppTheme.createAnimatedButton(
        child: const Text('Test'),
        onPressed: () {},
        isDark: false,
      );

      final darkButton = AppTheme.createAnimatedButton(
        child: const Text('Test'),
        onPressed: () {},
        isDark: true,
      );

      expect(lightButton, isA<AnimatedContainer>());
      expect(darkButton, isA<AnimatedContainer>());
    });
  });
}
