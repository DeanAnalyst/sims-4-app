import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trait.dart';
import '../../models/enums.dart';
import '../../providers/character_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/animations.dart';

/// ConsumerWidget that displays generated traits with expansion and regeneration functionality
///
/// This component watches the character generator state and provides:
/// - Display of generated traits with expandable details
/// - Individual trait regeneration functionality
/// - Trait conflict notifications via snackbars
/// - Loading states during trait generation
/// - Error handling with user-friendly messages
class TraitDisplayComponent extends ConsumerStatefulWidget {
  const TraitDisplayComponent({super.key});

  @override
  ConsumerState<TraitDisplayComponent> createState() =>
      _TraitDisplayComponentState();
}

class _TraitDisplayComponentState extends ConsumerState<TraitDisplayComponent>
    with TickerProviderStateMixin {
  // Local state for expanded trait details
  final Set<String> _expandedTraits = <String>{};
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterGeneratorProvider);

    // Listen for trait conflicts and show snackbars
    ref.listen<CharacterGeneratorState>(characterGeneratorProvider, (
      previous,
      next,
    ) {
      if (next.error != null && next.error!.contains('conflict')) {
        _showConflictSnackbar(next.error!);
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTheme.createGradientCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and regenerate button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Generated Traits (${characterState.generatedTraits.length}/3)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (characterState.generatedTraits.isNotEmpty &&
                  !characterState.isGeneratingTraits)
                AnimatedContainer(
                  duration: AppTheme.mediumAnimation,
                  child: IconButton(
                    onPressed: () => _regenerateAllTraits(),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Generate new traits',
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

          // Content area - shows loading, error, or generated traits
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
    if (state.isGeneratingTraits) {
      return _buildLoadingState(context);
    }

    // Show error state
    if (state.error != null && !state.error!.contains('conflict')) {
      return _buildErrorState(context, state.error!);
    }

    // Show generated traits or empty state
    if (state.generatedTraits.isNotEmpty) {
      return _buildTraitsList(context, state.generatedTraits);
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
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: AppTheme.longAnimation,
              child: Text(
                'Generating traits...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
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
              'Error generating traits',
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

  /// Builds the empty state UI when no traits are generated
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No traits generated yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Generate Traits" to create random personality traits',
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

  /// Builds the list of generated traits
  Widget _buildTraitsList(BuildContext context, List<Trait> traits) {
    return AppAnimations.staggeredList(
      controller: _listController,
      staggerDelay: const Duration(milliseconds: 150),
      children: traits.map((trait) => _buildTraitCard(context, trait)).toList(),
    );
  }

  /// Builds an individual trait card with expansion functionality
  Widget _buildTraitCard(BuildContext context, Trait trait) {
    final isExpanded = _expandedTraits.contains(trait.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppTheme.mediumAnimation,
      margin: const EdgeInsets.only(bottom: 12),
      child: AppTheme.createGradientCard(
        isDark: isDark,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Trait header with basic info and actions
            AnimatedContainer(
              duration: AppTheme.shortAnimation,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTraitIcon(trait.category),
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  trait.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTraitCategory(trait.category),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Regenerate individual trait button
                    AnimatedContainer(
                      duration: AppTheme.shortAnimation,
                      child: IconButton(
                        onPressed: () => _regenerateIndividualTrait(trait),
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: 'Generate new trait',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    // Expand/collapse button
                    AnimatedContainer(
                      duration: AppTheme.shortAnimation,
                      child: IconButton(
                        onPressed: () => _toggleTraitExpansion(trait.id),
                        icon: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: AppTheme.mediumAnimation,
                          child: const Icon(Icons.expand_more, size: 18),
                        ),
                        tooltip: isExpanded ? 'Hide details' : 'Show details',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content with description and metadata
            AnimatedContainer(
              duration: AppTheme.mediumAnimation,
              height: isExpanded ? null : 0,
              child: isExpanded
                  ? Column(
                      children: [
                        Divider(
                          height: 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              if (trait.description.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Description',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    trait.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Metadata row
                              Row(
                                children: [
                                  // Pack information
                                  Expanded(
                                    child: _buildMetadataItem(
                                      context,
                                      'Pack',
                                      _formatPackName(trait.pack),
                                      Icons.games,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Category information
                                  Expanded(
                                    child: _buildMetadataItem(
                                      context,
                                      'Category',
                                      _formatTraitCategory(trait.category),
                                      Icons.category,
                                    ),
                                  ),
                                ],
                              ),

                              // Conflicting traits (if any)
                              if (trait.conflictingTraits.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Conflicts with',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: trait.conflictingTraits.map((
                                    conflictId,
                                  ) {
                                    return AnimatedContainer(
                                      duration: AppTheme.shortAnimation,
                                      child: Chip(
                                        label: Text(
                                          conflictId,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.errorContainer,
                                        labelStyle: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a metadata item for trait details
  Widget _buildMetadataItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Toggles the expansion state of a trait
  void _toggleTraitExpansion(String traitId) {
    setState(() {
      if (_expandedTraits.contains(traitId)) {
        _expandedTraits.remove(traitId);
      } else {
        _expandedTraits.add(traitId);
      }
    });
  }

  /// Regenerates all traits
  void _regenerateAllTraits() {
    ref.read(characterGeneratorProvider.notifier).generateTraits();
  }

  /// Regenerates an individual trait
  void _regenerateIndividualTrait(Trait trait) {
    ref
        .read(characterGeneratorProvider.notifier)
        .regenerateIndividualTrait(trait);
  }

  /// Shows a snackbar for trait conflicts
  void _showConflictSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Gets the appropriate icon for a trait category
  IconData _getTraitIcon(TraitCategory category) {
    switch (category) {
      case TraitCategory.emotional:
        return Icons.favorite;
      case TraitCategory.hobby:
        return Icons.sports_esports;
      case TraitCategory.lifestyle:
        return Icons.home;
      case TraitCategory.social:
        return Icons.people;
      case TraitCategory.toddler:
        return Icons.child_care;
      case TraitCategory.infant:
        return Icons.baby_changing_station;
    }
  }

  /// Formats trait category for display
  String _formatTraitCategory(TraitCategory category) {
    switch (category) {
      case TraitCategory.emotional:
        return 'Emotional';
      case TraitCategory.hobby:
        return 'Hobby';
      case TraitCategory.lifestyle:
        return 'Lifestyle';
      case TraitCategory.social:
        return 'Social';
      case TraitCategory.toddler:
        return 'Toddler';
      case TraitCategory.infant:
        return 'Infant';
    }
  }

  /// Formats pack name for display
  String _formatPackName(String pack) {
    switch (pack.toLowerCase()) {
      case 'base_game':
        return 'Base Game';
      case 'get_to_work':
        return 'Get to Work';
      case 'get_together':
        return 'Get Together';
      case 'city_living':
        return 'City Living';
      case 'cats_and_dogs':
        return 'Cats & Dogs';
      case 'seasons':
        return 'Seasons';
      case 'get_famous':
        return 'Get Famous';
      case 'island_living':
        return 'Island Living';
      case 'discover_university':
        return 'Discover University';
      case 'eco_lifestyle':
        return 'Eco Lifestyle';
      case 'snowy_escape':
        return 'Snowy Escape';
      case 'cottage_living':
        return 'Cottage Living';
      case 'high_school_years':
        return 'High School Years';
      case 'growing_together':
        return 'Growing Together';
      case 'horse_ranch':
        return 'Horse Ranch';
      case 'for_rent':
        return 'For Rent';
      default:
        return pack
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) {
              return word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '';
            })
            .join(' ');
    }
  }
}
