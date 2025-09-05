import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import '../../models/regional_info.dart';
import '../../providers/state_providers.dart';
import '../../providers/map_providers.dart';
import '../../services/country_mapping_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/animations.dart';

/// A widget that displays an interactive world map with region highlighting
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

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _getResponsiveHeight(BuildContext context) {
    if (widget.height != null) return widget.height!;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use more screen height and consider aspect ratio
    final baseHeight = screenHeight * 0.65; // Increased from 0.5
    final aspectBasedHeight = screenWidth * 0.6; // World map aspect ratio consideration
    
    return baseHeight.clamp(300.0, aspectBasedHeight);
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
                    colorScheme.secondary.withValues(alpha: 0.02),
                    colorScheme.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: InteractiveViewer(
                minScale: 0.7,
                maxScale: 5.0,
                constrained: true,
                scaleEnabled: true,
                panEnabled: true,
                boundaryMargin: EdgeInsets.zero,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 2.0,
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
    final newRegion = CountryMappingService.getRegionForCountry(countryId);
    if (newRegion != null) {
      ref.read(selectedRegionProvider.notifier).state = newRegion;
      widget.onRegionSelected?.call();
    }
  }

  Map<String, Color> _getCountryColorsAsMap() {
    try {
      final selectedRegion = ref.watch(selectedRegionProvider);
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      debugPrint('Getting country colors for region: $selectedRegion');

      // Get countries that should be highlighted for this region
      final countriesInRegion = CountryMappingService.getCountryCodesForRegion(
        selectedRegion,
      );

      final Map<String, Color> colors = {};

      // Set all countries to default color first
      final allCountries = CountryMappingService.getAllCountryCodes();
      for (final countryCode in allCountries) {
        colors[countryCode] = theme.brightness == Brightness.dark
            ? colorScheme.outline.withValues(alpha: 0.3)
            : colorScheme.outline.withValues(alpha: 0.2);
      }

      // Highlight countries in the selected region
      for (final countryCode in countriesInRegion) {
        colors[countryCode] = colorScheme.secondary;
      }

      return colors;
    } catch (e) {
      debugPrint('Error getting country colors: $e');
      return {};
    }
  }

  void _showRegionalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regional Information'),
        content: const SingleChildScrollView(
          child: Text(
            'Select regions by tapping countries on the map. '
            'Each region has its own set of culturally appropriate names.',
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
  }

  Widget _buildRegionalInfoPanel(BuildContext context, RegionalInfo info) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  info.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoChip(
                  context,
                  'Population: ${info.formattedPopulation}',
                  Icons.people,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  'Languages: ${info.languages.length}',
                  Icons.language,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  info.namingTradition,
                  Icons.format_quote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
