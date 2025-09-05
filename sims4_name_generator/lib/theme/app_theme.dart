import 'package:flutter/material.dart';

/// App theme with dreamy sunset pastel color scheme
///
/// Uses a carefully crafted pastel pink-purple color palette that creates
/// a soft, magical, and welcoming atmosphere perfect for character creation.
class AppTheme {
  // Primary Colors
  static const Color _primaryMauve = Color(0xFFE1BEE7);
  static const Color _secondaryMistyRose = Color(0xFFF2D7D5);
  static const Color _accentLightMediumOrchid = Color(0xFFC8A2C8);

  // Background Colors
  static const Color _surfaceLavenderBlush = Color(0xFFF6F0F6);
  static const Color _textDarkCharcoal = Color(0xFF2D2D2D);

  // Enhanced gradient colors
  static const Color _gradientStart = Color(0xFFFEFBFE);
  static const Color _gradientEnd = Color(0xFFF6F0F6);
  static const Color _cardGradientStart = Color(0xFFF8F4F8);
  static const Color _cardGradientEnd = Color(0xFFF2E8F2);

  // Dark theme colors
  static const Color _darkPrimary = Color(
    0xFFE1BEE7,
  ); // Primary mauve from light theme
  static const Color _darkSecondary = Color(
    0xFFE1BEE7,
  ); // Primary mauve from light theme
  static const Color _darkSurface = Color(0xFF0A0A0A); // Deeper black
  static const Color _darkOnSurface = Color(0xFFF5F5F5); // Brighter white
  static const Color _darkGradientStart = Color(0xFF0A0A0A); // Deeper black
  static const Color _darkGradientEnd = Color(0xFF1A1A1A); // Dark gray

  // Animation durations
  static const Duration _shortAnimation = Duration(milliseconds: 200);
  static const Duration _mediumAnimation = Duration(milliseconds: 300);
  static const Duration _longAnimation = Duration(milliseconds: 500);

  /// Gradient background for light theme
  static LinearGradient get lightBackgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_gradientStart, _gradientEnd],
    stops: [0.0, 1.0],
  );

  /// Gradient background for dark theme
  static LinearGradient get darkBackgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkGradientStart, _darkGradientEnd],
    stops: [0.0, 1.0],
  );

  /// Card gradient for light theme
  static LinearGradient get lightCardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_cardGradientStart, _cardGradientEnd],
    stops: [0.0, 1.0],
  );

  /// Animation durations
  static Duration get shortAnimation => _shortAnimation;
  static Duration get mediumAnimation => _mediumAnimation;
  static Duration get longAnimation => _longAnimation;

  /// Light theme with dreamy sunset pastel colors
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryMauve,
        brightness: Brightness.light,
        primary: _primaryMauve,
        secondary: _secondaryMistyRose,
        tertiary: _accentLightMediumOrchid,
        surface: _surfaceLavenderBlush,
        onPrimary: _textDarkCharcoal,
        onSecondary: _textDarkCharcoal,
        onSurface: _textDarkCharcoal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryMauve,
        foregroundColor: _textDarkCharcoal,
        elevation: 0,
        centerTitle: true,
        shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.3),
        surfaceTintColor: _primaryMauve,
        titleTextStyle: const TextStyle(
          color: _textDarkCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: _primaryMauve,
              foregroundColor: _textDarkCharcoal,
              shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.4),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              animationDuration: _mediumAnimation,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return _accentLightMediumOrchid.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.pressed)) {
                  return _accentLightMediumOrchid.withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLavenderBlush,
        elevation: 4,
        shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLavenderBlush,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _accentLightMediumOrchid.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _accentLightMediumOrchid,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceLavenderBlush,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _accentLightMediumOrchid.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _surfaceLavenderBlush,
        elevation: 8,
        shadowColor: _accentLightMediumOrchid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      iconTheme: const IconThemeData(color: _textDarkCharcoal, size: 24),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _textDarkCharcoal,
          fontWeight: FontWeight.w500,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark theme with adapted pastel colors
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        brightness: Brightness.dark,
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _accentLightMediumOrchid,
        surface: _darkSurface,
        onPrimary: _darkSurface,
        onSecondary: _darkSurface,
        onSurface: _darkOnSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryMauve,
        foregroundColor: _textDarkCharcoal,
        elevation: 0,
        centerTitle: true,
        shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.3),
        surfaceTintColor: _darkPrimary,
        titleTextStyle: const TextStyle(
          color: _darkSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: _primaryMauve,
              foregroundColor: _textDarkCharcoal,
              shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.4),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              animationDuration: _mediumAnimation,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return _accentLightMediumOrchid.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.pressed)) {
                  return _accentLightMediumOrchid.withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 4,
        shadowColor: _accentLightMediumOrchid.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _accentLightMediumOrchid.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _accentLightMediumOrchid,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _accentLightMediumOrchid.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _darkSurface,
        elevation: 8,
        shadowColor: _accentLightMediumOrchid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      iconTheme: const IconThemeData(color: _darkOnSurface, size: 24),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Create a gradient container with theme colors
  static Widget createGradientContainer({
    required Widget child,
    required bool isDark,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkBackgroundGradient
            : AppTheme.lightBackgroundGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /// Create a gradient card with theme colors
  static Widget createGradientCard({
    required Widget child,
    required bool isDark,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double elevation = 4,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkBackgroundGradient
            : AppTheme.lightCardGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme._accentLightMediumOrchid.withValues(alpha: 0.2),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Create an animated button with theme colors
  static Widget createAnimatedButton({
    required Widget child,
    required VoidCallback? onPressed,
    required bool isDark,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return AnimatedContainer(
      duration: AppTheme._mediumAnimation,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ??
              (isDark ? AppTheme._darkPrimary : AppTheme._primaryMauve),
          foregroundColor: isDark
              ? AppTheme._darkOnSurface
              : AppTheme._textDarkCharcoal,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
          ),
          elevation: 3,
          animationDuration: AppTheme._mediumAnimation,
        ),
        child: child,
      ),
    );
  }

  /// Create a shimmer loading effect with theme colors
  static Widget createShimmerEffect({
    required Widget child,
    required bool isDark,
    Duration? duration,
  }) {
    return AnimatedContainer(
      duration: duration ?? AppTheme._longAnimation,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? AppTheme._darkSurface : AppTheme._surfaceLavenderBlush)
                .withValues(alpha: 0.3),
            (isDark ? AppTheme._darkPrimary : AppTheme._primaryMauve)
                .withValues(alpha: 0.1),
            (isDark ? AppTheme._darkSurface : AppTheme._surfaceLavenderBlush)
                .withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
