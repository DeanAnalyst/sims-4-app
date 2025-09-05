import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/character_profile.dart';
import '../providers/providers.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import 'components/name_display_component.dart';
import 'components/trait_display_component.dart';
import 'components/lithuanian_name_customizer_component.dart';
import 'components/world_map_component.dart';

/// Main screen of the Sims 4 Name Generator app
///
/// Provides the primary interface for generating names and traits
/// with region and gender selection controls.
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedGender = ref.watch(selectedGenderProvider);
    final selectedLifeStage = ref.watch(selectedLifeStageProvider);
    final selectedMaritalStatus = ref.watch(selectedMaritalStatusProvider);
    final characterState = ref.watch(characterGeneratorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sims 4 Name Generator'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            child: IconButton(
              onPressed: () =>
                  AppRoutes.navigateTo(context, AppRoutes.traitBrowser),
              icon: const Icon(Icons.psychology),
              tooltip: 'Browse Traits',
            ),
          ),
          AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            child: IconButton(
              onPressed: () =>
                  AppRoutes.navigateTo(context, AppRoutes.settings),
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: AppTheme.createGradientContainer(
        isDark: isDark,
        child: ResponsiveLayout.responsiveContainer(
          context: context,
          child: SingleChildScrollView(
            child: ResponsiveLayout.responsiveLayout(
              context: context,
              mobile: _buildMobileLayout(
                context,
                ref,
                selectedRegion,
                selectedGender,
                selectedLifeStage,
                selectedMaritalStatus,
                characterState,
                isDark,
              ),
              tablet: _buildTabletLayout(
                context,
                ref,
                selectedRegion,
                selectedGender,
                selectedLifeStage,
                selectedMaritalStatus,
                characterState,
                isDark,
              ),
              desktop: _buildDesktopLayout(
                context,
                ref,
                selectedRegion,
                selectedGender,
                selectedLifeStage,
                selectedMaritalStatus,
                characterState,
                isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build mobile layout (single column)
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    Gender selectedGender,
    LifeStage selectedLifeStage,
    MaritalStatus selectedMaritalStatus,
    CharacterGeneratorState characterState,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildControlsSection(
          context,
          ref,
          selectedRegion,
          selectedGender,
          selectedLifeStage,
          selectedMaritalStatus,
          characterState,
          isDark,
        ),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
        const NameDisplayComponent(),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
        const LithuanianNameCustomizerComponent(),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
        const TraitDisplayComponent(),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
        if (characterState.currentCharacterProfile != null)
          _buildCharacterActions(
            context,
            ref,
            characterState.currentCharacterProfile!,
          ),
      ],
    );
  }

  /// Build tablet layout (two columns)
  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    Gender selectedGender,
    LifeStage selectedLifeStage,
    MaritalStatus selectedMaritalStatus,
    CharacterGeneratorState characterState,
    bool isDark,
  ) {
    return Column(
      children: [
        // Controls section
        _buildControlsSection(
          context,
          ref,
          selectedRegion,
          selectedGender,
          selectedLifeStage,
          selectedMaritalStatus,
          characterState,
          isDark,
        ),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),

        // Two column layout for results
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const NameDisplayComponent(),
                  SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
                  const LithuanianNameCustomizerComponent(),
                  SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
                  if (characterState.currentCharacterProfile != null)
                    _buildCharacterActions(
                      context,
                      ref,
                      characterState.currentCharacterProfile!,
                    ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
            const Expanded(child: TraitDisplayComponent()),
          ],
        ),
      ],
    );
  }

  /// Build desktop layout (three columns)
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    Gender selectedGender,
    LifeStage selectedLifeStage,
    MaritalStatus selectedMaritalStatus,
    CharacterGeneratorState characterState,
    bool isDark,
  ) {
    return Column(
      children: [
        // First row: Basic controls
        Row(
          children: [
            Expanded(
              child: _buildRegionSelection(
                context,
                ref,
                selectedRegion,
                isDark,
              ),
            ),
            SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
            Expanded(
              child: _buildGenderSelection(
                context,
                ref,
                selectedGender,
                isDark,
              ),
            ),
            SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
            Expanded(
              child: _buildLifeStageSelection(
                context,
                ref,
                selectedLifeStage,
                isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
        // Second row: Extended controls and generation
        Row(
          children: [
            if (selectedRegion == Region.lithuanian &&
                selectedGender == Gender.female) ...[
              Expanded(
                child: _buildMaritalStatusSelection(
                  context,
                  ref,
                  selectedMaritalStatus,
                  isDark,
                ),
              ),
              SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
              Expanded(
                flex: 2,
                child: _buildGenerationButtons(
                  context,
                  ref,
                  selectedRegion,
                  selectedGender,
                  selectedLifeStage,
                  selectedMaritalStatus,
                  characterState,
                  isDark,
                ),
              ),
            ] else
              Expanded(
                child: _buildGenerationButtons(
                  context,
                  ref,
                  selectedRegion,
                  selectedGender,
                  selectedLifeStage,
                  selectedMaritalStatus,
                  characterState,
                  isDark,
                ),
              ),
          ],
        ),
        SizedBox(height: ResponsiveLayout.getCardSpacing(context)),

        // Second row: Three column layout for results
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const NameDisplayComponent(),
                  SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
                  const LithuanianNameCustomizerComponent(),
                ],
              ),
            ),
            SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
            const Expanded(flex: 3, child: TraitDisplayComponent()),
            SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
            Expanded(
              flex: 2,
              child: characterState.currentCharacterProfile != null
                  ? _buildCharacterActions(
                      context,
                      ref,
                      characterState.currentCharacterProfile!,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  /// Build controls section for mobile/tablet
  Widget _buildControlsSection(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    Gender selectedGender,
    LifeStage selectedLifeStage,
    MaritalStatus selectedMaritalStatus,
    CharacterGeneratorState characterState,
    bool isDark,
  ) {
    if (ResponsiveLayout.isMobile(context)) {
      return Column(
        children: [
          _buildRegionSelection(context, ref, selectedRegion, isDark),
          SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          const WorldMapComponent(),
          SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          _buildGenderSelection(context, ref, selectedGender, isDark),
          SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          _buildLifeStageSelection(context, ref, selectedLifeStage, isDark),
          SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          if (selectedRegion == Region.lithuanian &&
              selectedGender == Gender.female)
            _buildMaritalStatusSelection(
              context,
              ref,
              selectedMaritalStatus,
              isDark,
            ),
          if (selectedRegion == Region.lithuanian &&
              selectedGender == Gender.female)
            SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          _buildGenerationButtons(
            context,
            ref,
            selectedRegion,
            selectedGender,
            selectedLifeStage,
            selectedMaritalStatus,
            characterState,
            isDark,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // First row: region, gender, life stage
          Row(
            children: [
              Expanded(
                child: _buildRegionSelection(
                  context,
                  ref,
                  selectedRegion,
                  isDark,
                ),
              ),
              SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
              Expanded(
                child: _buildGenderSelection(
                  context,
                  ref,
                  selectedGender,
                  isDark,
                ),
              ),
              SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
              Expanded(
                child: _buildLifeStageSelection(
                  context,
                  ref,
                  selectedLifeStage,
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveLayout.getCardSpacing(context)),
          // Second row: marital status (if applicable) and generation buttons
          Row(
            children: [
              if (selectedRegion == Region.lithuanian &&
                  selectedGender == Gender.female) ...[
                Expanded(
                  child: _buildMaritalStatusSelection(
                    context,
                    ref,
                    selectedMaritalStatus,
                    isDark,
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getCardSpacing(context)),
              ],
              Expanded(
                flex:
                    selectedRegion == Region.lithuanian &&
                        selectedGender == Gender.female
                    ? 1
                    : 2,
                child: _buildGenerationButtons(
                  context,
                  ref,
                  selectedRegion,
                  selectedGender,
                  selectedLifeStage,
                  selectedMaritalStatus,
                  characterState,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Build region selection card
  Widget _buildRegionSelection(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    bool isDark,
  ) {
    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.public,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveLayout.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Select Region',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize! *
                        ResponsiveLayout.getFontScale(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: DropdownButtonFormField<Region>(
                  initialValue: selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Cultural Region',
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
              ),
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final random = Random();
                    final randomRegion =
                        Region.values[random.nextInt(Region.values.length)];
                    ref.read(selectedRegionProvider.notifier).state =
                        randomRegion;
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random Region'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build gender selection card
  Widget _buildGenderSelection(
    BuildContext context,
    WidgetRef ref,
    Gender selectedGender,
    bool isDark,
  ) {
    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveLayout.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Select Gender',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize! *
                        ResponsiveLayout.getFontScale(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveLayout.responsiveRowColumn(
            context: context,
            spacing: 12,
            children: [
              _GenderToggleButton(
                gender: Gender.male,
                selectedGender: selectedGender,
                onPressed: () {
                  ref.read(selectedGenderProvider.notifier).state = Gender.male;
                },
              ),
              _GenderToggleButton(
                gender: Gender.female,
                selectedGender: selectedGender,
                onPressed: () {
                  ref.read(selectedGenderProvider.notifier).state =
                      Gender.female;
                },
              ),
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final random = Random();
                    final randomGender =
                        Gender.values[random.nextInt(Gender.values.length)];
                    ref.read(selectedGenderProvider.notifier).state =
                        randomGender;
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build life stage selection card
  Widget _buildLifeStageSelection(
    BuildContext context,
    WidgetRef ref,
    LifeStage selectedLifeStage,
    bool isDark,
  ) {
    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveLayout.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Life Stage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize! *
                        ResponsiveLayout.getFontScale(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: DropdownButtonFormField<LifeStage>(
                  initialValue: selectedLifeStage,
                  decoration: const InputDecoration(
                    labelText: 'Sims 4 Life Stage',
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  items: LifeStage.values.map((stage) {
                    final traitLimit = AgeBasedLimits.getTraitLimit(stage);
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(
                        '${_getLifeStageDisplayName(stage)} ($traitLimit traits)',
                      ),
                    );
                  }).toList(),
                  onChanged: (LifeStage? newStage) {
                    if (newStage != null) {
                      ref.read(selectedLifeStageProvider.notifier).state =
                          newStage;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final random = Random();
                    final randomStage = LifeStage
                        .values[random.nextInt(LifeStage.values.length)];
                    ref.read(selectedLifeStageProvider.notifier).state =
                        randomStage;
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random Life Stage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build marital status selection card (only for Lithuanian female names)
  Widget _buildMaritalStatusSelection(
    BuildContext context,
    WidgetRef ref,
    MaritalStatus selectedMaritalStatus,
    bool isDark,
  ) {
    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveLayout.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Marital Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize! *
                        ResponsiveLayout.getFontScale(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lithuanian surname endings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                child: DropdownButtonFormField<MaritalStatus>(
                  initialValue: selectedMaritalStatus,
                  decoration: const InputDecoration(
                    labelText: 'Surname Form',
                    prefixIcon: Icon(Icons.favorite),
                  ),
                  items: MaritalStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getMaritalStatusDisplayName(status)),
                    );
                  }).toList(),
                  onChanged: (MaritalStatus? newStatus) {
                    if (newStatus != null) {
                      ref.read(selectedMaritalStatusProvider.notifier).state =
                          newStatus;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build generation buttons card
  Widget _buildGenerationButtons(
    BuildContext context,
    WidgetRef ref,
    Region selectedRegion,
    Gender selectedGender,
    LifeStage selectedLifeStage,
    MaritalStatus selectedMaritalStatus,
    CharacterGeneratorState characterState,
    bool isDark,
  ) {
    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveLayout.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Generate Content',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize! *
                        ResponsiveLayout.getFontScale(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Generate Name Button
          AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            child: ElevatedButton.icon(
              onPressed: characterState.isGeneratingName
                  ? null
                  : () {
                      ref
                          .read(characterGeneratorProvider.notifier)
                          .generateName(
                            selectedRegion,
                            selectedGender,
                            lifeStage: selectedLifeStage,
                            maritalStatus: selectedMaritalStatus,
                          );
                    },
              icon: characterState.isGeneratingName
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.person),
              label: Text(
                characterState.isGeneratingName
                    ? 'Generating...'
                    : 'Generate Name',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Generate Traits Button
          AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            child: ElevatedButton.icon(
              onPressed: characterState.isGeneratingTraits
                  ? null
                  : () {
                      ref
                          .read(characterGeneratorProvider.notifier)
                          .generateTraits();
                    },
              icon: characterState.isGeneratingTraits
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.psychology),
              label: Text(
                characterState.isGeneratingTraits
                    ? 'Generating...'
                    : 'Generate Traits',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Generate Complete Character Button
          AnimatedContainer(
            duration: AppTheme.mediumAnimation,
            child: ElevatedButton.icon(
              onPressed: characterState.isLoading
                  ? null
                  : () {
                      ref
                          .read(characterGeneratorProvider.notifier)
                          .generateCompleteCharacter(
                            selectedRegion,
                            selectedGender,
                            lifeStage: selectedLifeStage,
                            maritalStatus: selectedMaritalStatus,
                          );
                    },
              icon: characterState.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                characterState.isLoading
                    ? 'Generating...'
                    : ResponsiveLayout.isMobile(context)
                    ? 'Complete'
                    : 'Generate Complete',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build character action buttons
  Widget _buildCharacterActions(
    BuildContext context,
    WidgetRef ref,
    CharacterProfile character,
  ) {
    final storageNotifier = ref.watch(
      characterStorageNotifierProvider.notifier,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.manage_accounts,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Character Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: AppTheme.mediumAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () => storageNotifier.saveCharacter(character),
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Save'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: AppTheme.mediumAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () => storageNotifier.shareCharacter(character),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the navigation drawer
  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Character Manager',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your Sims characters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Saved Characters'),
            onTap: () {
              Navigator.pop(context);
              AppRoutes.navigateTo(context, AppRoutes.savedCharacters);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Generation History'),
            onTap: () {
              Navigator.pop(context);
              AppRoutes.navigateTo(context, AppRoutes.characterHistory);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('Browse Traits'),
            onTap: () {
              Navigator.pop(context);
              AppRoutes.navigateTo(context, AppRoutes.traitBrowser);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              AppRoutes.navigateTo(context, AppRoutes.settings);
            },
          ),
          const Divider(),
          // Storage statistics
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(storageStatisticsProvider);
              return statsAsync.when(
                data: (stats) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Statistics',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Saved: ${stats['saved']}'),
                      Text('History: ${stats['history']}'),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
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

  /// Get display name for life stage enum
  String _getLifeStageDisplayName(LifeStage lifeStage) {
    switch (lifeStage) {
      case LifeStage.infant:
        return 'Infant';
      case LifeStage.toddler:
        return 'Toddler';
      case LifeStage.child:
        return 'Child';
      case LifeStage.teen:
        return 'Teen';
      case LifeStage.youngAdult:
        return 'Young Adult';
      case LifeStage.adult:
        return 'Adult';
      case LifeStage.elder:
        return 'Elder';
    }
  }

  /// Get display name for marital status enum
  String _getMaritalStatusDisplayName(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.single:
        return 'Single (maiden name)';
      case MaritalStatus.married:
        return 'Married (ends with -ienė)';
      case MaritalStatus.daughter:
        return 'Daughter (traditional ending)';
    }
  }
}

/// Custom widget for gender toggle buttons
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

    return AnimatedContainer(
      duration: AppTheme.mediumAnimation,
      curve: Curves.easeInOut,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: AppTheme.shortAnimation,
          child: Icon(
            gender == Gender.male ? Icons.male : Icons.female,
            key: ValueKey(gender),
          ),
        ),
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
            width: isSelected ? 2 : 1,
          ),
          elevation: isSelected ? 4 : 1,
          shadowColor: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : null,
          animationDuration: AppTheme.mediumAnimation,
        ),
      ),
    );
  }
}
