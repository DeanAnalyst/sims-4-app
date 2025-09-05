import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trait.dart';
import '../models/enums.dart';
import '../providers/data_providers.dart';
import '../navigation/app_routes.dart';

/// Trait browser screen for exploring all available Sims 4 traits
///
/// Provides functionality for:
/// - Searching traits by name or description
/// - Filtering by category and expansion pack
/// - Viewing detailed trait information
/// - Browsing trait compatibility
class TraitBrowserScreen extends ConsumerStatefulWidget {
  const TraitBrowserScreen({super.key});

  @override
  ConsumerState<TraitBrowserScreen> createState() => _TraitBrowserScreenState();
}

class _TraitBrowserScreenState extends ConsumerState<TraitBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  TraitCategory? _selectedCategory;
  String? _selectedPack;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traitsAsync = ref.watch(traitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trait Browser'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.goBack(context),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter traits',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search traits...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters Display
          if (_selectedCategory != null || _selectedPack != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Filters: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_formatTraitCategory(_selectedCategory!)),
                      onDeleted: () => setState(() => _selectedCategory = null),
                    ),
                  if (_selectedPack != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_formatPackName(_selectedPack!)),
                      onDeleted: () => setState(() => _selectedPack = null),
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Traits List
          Expanded(
            child: traitsAsync.when(
              data: (traits) => _buildTraitsList(_filterTraits(traits)),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load traits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(traitsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of filtered traits
  Widget _buildTraitsList(List<Trait> traits) {
    if (traits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No traits found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: traits.length,
      itemBuilder: (context, index) {
        final trait = traits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getTraitIcon(trait.category),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              trait.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trait.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        _formatTraitCategory(trait.category),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        _formatPackName(trait.pack),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTraitDetails(trait),
          ),
        );
      },
    );
  }

  /// Filters traits based on search query and selected filters
  List<Trait> _filterTraits(List<Trait> traits) {
    return traits.where((trait) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            trait.name.toLowerCase().contains(query) ||
            trait.description.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Apply category filter
      if (_selectedCategory != null && trait.category != _selectedCategory) {
        return false;
      }

      // Apply pack filter
      if (_selectedPack != null && trait.pack != _selectedPack) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Shows the filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedCategory: _selectedCategory,
        selectedPack: _selectedPack,
        onApply: (category, pack) {
          setState(() {
            _selectedCategory = category;
            _selectedPack = pack;
          });
        },
      ),
    );
  }

  /// Shows trait details dialog
  void _showTraitDetails(Trait trait) {
    showDialog(
      context: context,
      builder: (context) => _TraitDetailsDialog(trait: trait),
    );
  }

  /// Clears the search query
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  /// Clears all filters
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedPack = null;
    });
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

/// Dialog for filtering traits
class _FilterDialog extends ConsumerStatefulWidget {
  final TraitCategory? selectedCategory;
  final String? selectedPack;
  final Function(TraitCategory?, String?) onApply;

  const _FilterDialog({
    required this.selectedCategory,
    required this.selectedPack,
    required this.onApply,
  });

  @override
  ConsumerState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<_FilterDialog> {
  TraitCategory? _selectedCategory;
  String? _selectedPack;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedPack = widget.selectedPack;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(traitCategoriesProvider);
    final packsAsync = ref.watch(traitPacksProvider);

    return AlertDialog(
      title: const Text('Filter Traits'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Filter
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<TraitCategory?>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(_formatTraitCategory(category)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text('Failed to load categories'),
            ),

            const SizedBox(height: 16),

            // Pack Filter
            packsAsync.when(
              data: (packs) => DropdownButtonFormField<String?>(
                initialValue: _selectedPack,
                decoration: const InputDecoration(
                  labelText: 'Expansion Pack',
                  prefixIcon: Icon(Icons.games),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Packs')),
                  ...packs.map(
                    (pack) => DropdownMenuItem(
                      value: pack,
                      child: Text(_formatPackName(pack)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPack = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text('Failed to load packs'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedCategory, _selectedPack);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
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

/// Dialog for displaying trait details
class _TraitDetailsDialog extends StatelessWidget {
  final Trait trait;

  const _TraitDetailsDialog({required this.trait});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(trait.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Description
            if (trait.description.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(trait.description),
              const SizedBox(height: 16),
            ],

            // Category and Pack
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Category',
                    _formatTraitCategory(trait.category),
                    Icons.category,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Pack',
                    _formatPackName(trait.pack),
                    Icons.games,
                  ),
                ),
              ],
            ),

            // Conflicting Traits
            if (trait.conflictingTraits.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Conflicts with',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: trait.conflictingTraits.map((conflictId) {
                  return Chip(
                    label: Text(
                      conflictId,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Builds a detail item with icon, label, and value
  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
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
