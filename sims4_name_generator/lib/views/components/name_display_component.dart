import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/name.dart';
import '../../models/enums.dart';
import '../../providers/character_providers.dart';
import '../../providers/state_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/animations.dart';

/// ConsumerWidget that displays generated names with regeneration and copy functionality
///
/// This component watches the character generator state and provides:
/// - Display of generated names with cultural context
/// - Loading states during name generation
/// - Error handling with user-friendly messages
/// - Regeneration functionality
/// - Copy-to-clipboard feature
class NameDisplayComponent extends ConsumerStatefulWidget {
  const NameDisplayComponent({super.key});

  @override
  ConsumerState<NameDisplayComponent> createState() =>
      _NameDisplayComponentState();
}

class _NameDisplayComponentState extends ConsumerState<NameDisplayComponent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterGeneratorProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedGender = ref.watch(selectedGenderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for name generation completion to trigger animations
    ref.listen<CharacterGeneratorState>(characterGeneratorProvider, (
      previous,
      next,
    ) {
      if (previous?.generatedName != next.generatedName &&
          next.generatedName != null) {
        _slideController.reset();
        _slideController.forward();
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    });

    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and regenerate button
          AppAnimations.slideInFromRight(
            controller: _slideController,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generated Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (characterState.generatedName != null &&
                    !characterState.isGeneratingName)
                  AppAnimations.scaleIn(
                    controller: _slideController,
                    delay: const Duration(milliseconds: 200),
                    child: IconButton(
                      onPressed: () =>
                          _regenerateName(selectedRegion, selectedGender),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Generate new name',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content area - shows loading, error, or generated name
          _buildContentArea(context, characterState),
        ],
      ),
    );
  }

  /// Builds the main content area based on current state
  Widget _buildContentArea(
    BuildContext context,
    CharacterGeneratorState state,
  ) {
    // Show loading state
    if (state.isGeneratingName) {
      return _buildLoadingState(context);
    }

    // Show error state
    if (state.error != null) {
      return _buildErrorState(context, state.error!);
    }

    // Show generated name or empty state
    if (state.generatedName != null) {
      return _buildNameDisplay(context, state.generatedName!);
    } else {
      return _buildEmptyState(context);
    }
  }

  /// Builds the loading state UI
  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAnimations.scaleIn(
              controller: _slideController,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppAnimations.fadeIn(
              controller: _slideController,
              delay: const Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generating name',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppAnimations.loadingDots(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state UI
  Widget _buildErrorState(BuildContext context, String error) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error generating name',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(characterGeneratorProvider.notifier).clearError(),
              icon: const Icon(Icons.close),
              label: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state UI when no name is generated
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No name generated yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Generate Name" to create a random name',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the name display UI with copy functionality
  Widget _buildNameDisplay(BuildContext context, Name name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppTheme.mediumAnimation,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkBackgroundGradient
            : AppTheme.lightCardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full name display with animation
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: AnimatedSwitcher(
                        duration: AppTheme.mediumAnimation,
                        transitionBuilder: (child, animation) {
                          return AppAnimations.slideInFromBottom(
                            controller: AnimationController(
                              duration: AppTheme.mediumAnimation,
                              vsync: this,
                            )..forward(),
                            child: child,
                          );
                        },
                        child: Text(
                          name.fullName,
                          key: ValueKey(name.fullName),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedContainer(
                duration: AppTheme.shortAnimation,
                child: IconButton(
                  onPressed: () => _copyToClipboard(context, name.fullName),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy name to clipboard',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name details with enhanced styling
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildNameDetail(
                  context,
                  'First Name',
                  name.firstName,
                  Icons.person_outline,
                ),
                const SizedBox(height: 8),
                _buildNameDetail(
                  context,
                  'Last Name',
                  name.lastName,
                  Icons.family_restroom,
                ),
                const SizedBox(height: 8),
                _buildNameDetail(
                  context,
                  'Region',
                  _formatRegionName(name.region),
                  Icons.public,
                ),
                const SizedBox(height: 8),
                _buildNameDetail(
                  context,
                  'Gender',
                  _formatGenderName(name.gender),
                  name.gender == Gender.male ? Icons.male : Icons.female,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons with animations
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: AppTheme.mediumAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, name.fullName),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Name'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedContainer(
                  duration: AppTheme.mediumAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () => _regenerateName(name.region, name.gender),
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Name'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a name detail row with icon
  Widget _buildNameDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// Regenerates a name using the character generator
  void _regenerateName(Region region, Gender gender) {
    ref.read(characterGeneratorProvider.notifier).generateName(region, gender);
  }

  /// Copies text to clipboard and shows a snackbar
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied "$text" to clipboard'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy to clipboard: $e'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Formats region enum to display name
  String _formatRegionName(Region region) {
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

  /// Formats gender enum to display name
  String _formatGenderName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }
}
