import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import '../../models/enums.dart';
import '../../models/regional_info.dart';
import '../../providers/state_providers.dart';
import '../../providers/map_providers.dart';
import '../../services/country_mapping_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/animations.dart';
import '../../utils/responsive_layout.dart';

// Fixed: Updated country codes to lowercase to match map package
class WorldMapComponent extends ConsumerStatefulWidget {
  final bool showRegionalInfo;
  final double? height;
  final VoidCallback? onRegionSelected;

  const WorldMapComponent({
    super.key,
    this.showRegionalInfo = true,
    this.height,
    this.onRegionSelected,
  });

  @override
  ConsumerState<WorldMapComponent> createState() => _WorldMapComponentState();
}

class _WorldMapComponentState extends ConsumerState<WorldMapComponent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  TransformationController? _transformationController;
  Animation<Matrix4>? _resetAnimation;
  late AnimationController _resetController;

  void _onInteractionEnd(ScaleEndDetails details) {
    // Reset zoom if scale is too small
    if (_transformationController!.value.getMaxScaleOnAxis() < 0.8) {
      _resetAnimation =
          Matrix4Tween(
            begin: _transformationController!.value,
            end: Matrix4.identity(),
          ).animate(
            CurvedAnimation(parent: _resetController, curve: Curves.easeInOut),
          );
      _resetController.forward(from: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _transformationController = TransformationController();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resetController.addListener(() {
      if (_resetAnimation != null) {
        _transformationController!.value = _resetAnimation!.value;
      }
    });
    _fadeController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _resetController.dispose();
    _transformationController?.dispose();
    super.dispose();
  }

  double _getResponsiveHeight(BuildContext context) {
    if (widget.height != null) return widget.height!;

    // Calculate responsive height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;

    if (ResponsiveLayout.isMobile(context)) {
      // Mobile: 50% of screen height, min 500px, max 600px
      return (screenHeight * 0.5).clamp(500.0, 600.0);
    } else if (ResponsiveLayout.isTablet(context)) {
      // Tablet: 55% of screen height, min 600px, max 750px
      return (screenHeight * 0.55).clamp(600.0, 750.0);
    } else {
      // Desktop: 60% of screen height, min 650px, max 800px
      return (screenHeight * 0.6).clamp(650.0, 800.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final regionalInfoAsync = ref.watch(regionalInfoProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppAnimations.slideInFromBottom(
      controller: _slideController,
      child: AppTheme.createGradientCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.public, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'World Regions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                if (widget.showRegionalInfo)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showRegionalInfoDialog(context),
                    tooltip: 'Regional Information',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive World Map
            Container(
              height: _getResponsiveHeight(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.05),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Stack(
                    children: [
                      // Interactive World Map with zoom capability
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(50),
                        constrained: false,
                        scaleEnabled: true,
                        panEnabled: true,
                        onInteractionEnd: _onInteractionEnd,
                        transformationController: _transformationController,
                        child: SimpleMap(
                          key: ValueKey('world_map_${selectedRegion.name}'),
                          instructions: SMapWorld.instructions,
                          defaultColor: isDark
                              ? colorScheme.outline.withValues(alpha: 0.3)
                              : colorScheme.outline.withValues(alpha: 0.2),
                          colors: _getCountryColorsAsMap(),
                          callback: (id, name, tapDetails) =>
                              _handleCountryTap(id, name),
                          countryBorder: CountryBorder(
                            color: colorScheme.outline.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                      ),
                      // Overlay with region selection guide
                      if (_showSelectionGuide())
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Tap on any country to select its cultural region',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Current selection indicator
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                CountryMappingService.getRegionDisplayName(
                                  selectedRegion,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (widget.showRegionalInfo) ...[
              const SizedBox(height: 16),

              // Regional Information Panel
              regionalInfoAsync.when(
                data: (regionalInfoList) {
                  final currentRegionInfo = regionalInfoList.firstWhere(
                    (info) => info.region == selectedRegion,
                    orElse: () => regionalInfoList.first,
                  );
                  return _buildRegionalInfoPanel(context, currentRegionInfo);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Failed to load regional information',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleCountryTap(String countryId, String countryName) {
    try {
      debugPrint('Country tapped: $countryId ($countryName)');
      final region = CountryMappingService.getRegionForCountry(countryId);
      debugPrint('Mapped to region: $region');
      if (region != null) {
        ref.read(selectedRegionProvider.notifier).state = region;
        widget.onRegionSelected?.call();

        // Show a brief feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Selected ${CountryMappingService.getRegionDisplayName(region)} region ($countryName)',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        // Handle unmapped countries
        debugPrint(
          'Country $countryId ($countryName) not mapped to any region',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$countryName is not available in our cultural regions',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling country tap: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error selecting region. Please try again.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Map<String, Color> _getCountryColorsAsMap() {
    try {
      final selectedRegion = ref.watch(selectedRegionProvider);
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      // Get colors for the map
      final selectedColor = colorScheme.secondary;
      final defaultColor = theme.brightness == Brightness.dark
          ? colorScheme.outline.withValues(alpha: 0.3)
          : colorScheme.outline.withValues(alpha: 0.2);

      debugPrint('Getting country colors for region: $selectedRegion');
      debugPrint(
        'Selected color: ${_colorToHex(selectedColor)}, Default color: ${_colorToHex(defaultColor)}',
      );

      // Get countries that should be highlighted for this region
      final countriesInRegion = CountryMappingService.getCountryCodesForRegion(
        selectedRegion,
      );
      debugPrint(
        'Countries in $selectedRegion: ${countriesInRegion.join(', ')} (${countriesInRegion.length} total)',
      );

      final Map<String, Color> colors = {};

      // Set all countries to default color first
      final allCountries = CountryMappingService.getAllCountryCodes();
      for (final countryCode in allCountries) {
        colors[countryCode] = defaultColor;
      }

      // Highlight countries in the selected region with brighter color
      for (final countryCode in countriesInRegion) {
        colors[countryCode] = selectedColor;
      }

      debugPrint('Generated ${colors.length} country colors');

      // Debug: Show which countries are getting the selected color
      final highlightedCountries = colors.entries
          .where((entry) => entry.value == selectedColor)
          .map((entry) => entry.key)
          .toList();
      debugPrint(
        'Countries set to highlight color: ${highlightedCountries.join(', ')} (${highlightedCountries.length} total)',
      );

      return colors;
    } catch (e) {
      debugPrint('Error getting country colors: $e');
      // Return empty map as fallback
      return {};
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  bool _showSelectionGuide() {
    final selectedRegion = ref.watch(selectedRegionProvider);
    return selectedRegion == Region.english; // Show guide for default selection
  }

  Widget _buildRegionalInfoPanel(BuildContext context, RegionalInfo info) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(info.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  context,
                  'Population',
                  info.formattedPopulation,
                  Icons.people,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  context,
                  'Languages',
                  '${info.languages.length}',
                  Icons.language,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoChip(
            context,
            'Top Countries',
            info.topCountriesByPopulation.map((c) => c.name).join(', '),
            Icons.location_on,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegionalInfoDialog(BuildContext context) {
    final regionalInfoAsync = ref.read(regionalInfoProvider);

    regionalInfoAsync.when(
      data: (regionalInfoList) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Regional Information'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: regionalInfoList.length,
                itemBuilder: (context, index) {
                  final info = regionalInfoList[index];
                  return ListTile(
                    title: Text(info.displayName),
                    subtitle: Text(info.namingTradition),
                    trailing: Text(info.formattedPopulation),
                    onTap: () {
                      ref.read(selectedRegionProvider.notifier).state =
                          info.region;
                      Navigator.of(context).pop();
                      widget.onRegionSelected?.call();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }
}
