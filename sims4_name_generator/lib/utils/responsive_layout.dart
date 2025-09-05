import 'package:flutter/material.dart';

/// Utility class for responsive layout calculations and breakpoints
class ResponsiveLayout {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if the current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get the number of columns for a grid based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16);
    if (isTablet(context)) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  /// Get appropriate card spacing based on screen size
  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 20;
    return 24;
  }

  /// Get appropriate font scale based on screen size
  static double getFontScale(BuildContext context) {
    if (isMobile(context)) return 1.0;
    if (isTablet(context)) return 1.1;
    return 1.2;
  }

  /// Get appropriate button size based on screen size
  static Size getButtonSize(BuildContext context) {
    if (isMobile(context)) return const Size(double.infinity, 48);
    if (isTablet(context)) return const Size(200, 52);
    return const Size(240, 56);
  }

  /// Get appropriate icon size based on screen size
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 28;
    return 32;
  }

  /// Get appropriate app bar height based on screen size
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return kToolbarHeight;
    if (isTablet(context)) return kToolbarHeight + 8;
    return kToolbarHeight + 16;
  }

  /// Get appropriate drawer width based on screen size
  static double getDrawerWidth(BuildContext context) {
    if (isMobile(context)) return 280;
    if (isTablet(context)) return 320;
    return 360;
  }

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get appropriate layout for different screen sizes
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Create a responsive grid view
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final columns = getGridColumns(context);
    final spacing = getCardSpacing(context);

    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  /// Create a responsive row/column layout
  static Widget responsiveRowColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double spacing = 16,
  }) {
    if (isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .expand((child) => [child, SizedBox(height: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .expand(
              (child) => [Expanded(child: child), SizedBox(width: spacing)],
            )
            .take(children.length * 2 - 1)
            .toList(),
      );
    }
  }

  /// Create a responsive wrap layout
  static Widget responsiveWrap({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 8,
    double runSpacing = 8,
    WrapAlignment alignment = WrapAlignment.start,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: children,
    );
  }

  /// Get appropriate max width for content based on screen size
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    return 1200;
  }

  /// Create a responsive container with max width
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: getMaxContentWidth(context)),
      padding: padding ?? getScreenPadding(context),
      child: child,
    );
  }
}
