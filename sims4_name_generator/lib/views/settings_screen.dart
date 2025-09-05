import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/state_providers.dart';
import '../navigation/app_routes.dart';

/// Settings screen for the Sims 4 Name Generator app
///
/// Provides user preferences for:
/// - Theme selection (light, dark, system)
/// - Default region preference
/// - Default gender preference
/// - App information and version
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedGender = ref.watch(selectedGenderProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.goBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Settings Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ThemeMode>(
                      initialValue: themeMode,
                      decoration: const InputDecoration(
                        labelText: 'Theme',
                        prefixIcon: Icon(Icons.palette),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Default'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                      onChanged: (ThemeMode? newTheme) {
                        if (newTheme != null) {
                          ref.read(themeProvider.notifier).state = newTheme;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Default Preferences Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Default Region
                    DropdownButtonFormField<Region>(
                      initialValue: selectedRegion,
                      decoration: const InputDecoration(
                        labelText: 'Default Region',
                        prefixIcon: Icon(Icons.public),
                      ),
                      items: Region.values.map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(_getRegionDisplayName(region)),
                        );
                      }).toList(),
                      onChanged: (Region? newRegion) {
                        if (newRegion != null) {
                          ref.read(selectedRegionProvider.notifier).state =
                              newRegion;
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Default Gender
                    Text(
                      'Default Gender',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderToggleButton(
                            gender: Gender.male,
                            selectedGender: selectedGender,
                            onPressed: () {
                              ref.read(selectedGenderProvider.notifier).state =
                                  Gender.male;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenderToggleButton(
                            gender: Gender.female,
                            selectedGender: selectedGender,
                            onPressed: () {
                              ref.read(selectedGenderProvider.notifier).state =
                                  Gender.female;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // About Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Info
                    _buildAboutItem(
                      context,
                      'App Name',
                      'Sims 4 Name Generator',
                      Icons.apps,
                    ),
                    const SizedBox(height: 8),
                    _buildAboutItem(context, 'Version', '1.0.0', Icons.info),
                    const SizedBox(height: 8),
                    _buildAboutItem(
                      context,
                      'Description',
                      'Generate culturally diverse names and traits for The Sims 4',
                      Icons.description,
                    ),
                    const SizedBox(height: 16),

                    // Features List
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      '13 cultural regions with 500 names each',
                    ),
                    _buildFeatureItem(
                      context,
                      'All official Sims 4 traits from base game and expansions',
                    ),
                    _buildFeatureItem(context, 'Trait compatibility checking'),
                    _buildFeatureItem(context, 'Offline functionality'),
                    _buildFeatureItem(context, 'Cross-platform support'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Data Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildAboutItem(
                      context,
                      'Name Data',
                      '6,500 names (250 male, 250 female per region)',
                      Icons.person,
                    ),
                    const SizedBox(height: 8),
                    _buildAboutItem(
                      context,
                      'Trait Data',
                      'All official Sims 4 traits with descriptions',
                      Icons.psychology,
                    ),
                    const SizedBox(height: 8),
                    _buildAboutItem(
                      context,
                      'Storage',
                      'Local JSON files for offline access',
                      Icons.storage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an about item with icon, label, and value
  Widget _buildAboutItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a feature item in the features list
  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(feature, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  /// Get display name for region enum
  String _getRegionDisplayName(Region region) {
    switch (region) {
      case Region.english:
        return 'English';
      case Region.northAfrican:
        return 'North African';
      case Region.subSaharanAfrican:
        return 'Sub-Saharan African';
      case Region.eastAfrican:
        return 'East African';
      case Region.southAfrican:
        return 'South African';
      case Region.centralEuropean:
        return 'Central European';
      case Region.northernEuropean:
        return 'Northern European';
      case Region.easternEuropean:
        return 'Eastern European';
      case Region.middleEastern:
        return 'Middle Eastern';
      case Region.southAsian:
        return 'South Asian';
      case Region.eastAsian:
        return 'East Asian';
      case Region.oceania:
        return 'Oceania';
      case Region.lithuanian:
        return 'Lithuanian';
    }
  }
}

/// Custom widget for gender toggle buttons in settings
class _GenderToggleButton extends StatelessWidget {
  final Gender gender;
  final Gender selectedGender;
  final VoidCallback onPressed;

  const _GenderToggleButton({
    required this.gender,
    required this.selectedGender,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = gender == selectedGender;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(gender == Gender.male ? Icons.male : Icons.female),
      label: Text(gender == Gender.male ? 'Male' : 'Female'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
