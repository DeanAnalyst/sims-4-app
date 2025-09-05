import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/name.dart';
import '../../models/enums.dart';
import '../../providers/character_providers.dart';
import '../../providers/state_providers.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/animations.dart';

/// Component that provides real-time Lithuanian surname customization
///
/// Shows customization controls when a Lithuanian female name is generated
/// and allows real-time surname updates without regeneration
class LithuanianNameCustomizerComponent extends ConsumerStatefulWidget {
  const LithuanianNameCustomizerComponent({super.key});

  @override
  ConsumerState<LithuanianNameCustomizerComponent> createState() =>
      _LithuanianNameCustomizerComponentState();
}

class _LithuanianNameCustomizerComponentState
    extends ConsumerState<LithuanianNameCustomizerComponent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  Name? _customizedName;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterGeneratorProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedGender = ref.watch(selectedGenderProvider);
    final selectedMaritalStatus = ref.watch(selectedMaritalStatusProvider);
    final selectedLifeStage = ref.watch(selectedLifeStageProvider);

    final generatedName = characterState.generatedName;

    // Only show for Lithuanian female names
    if (generatedName == null ||
        selectedRegion != Region.lithuanian ||
        selectedGender != Gender.female) {
      return const SizedBox.shrink();
    }

    // Update customized name when marital status or life stage changes
    ref.listen<MaritalStatus>(selectedMaritalStatusProvider, (previous, next) {
      if (previous != next) {
        _updateCustomizedName(generatedName, next, selectedLifeStage);
        _slideController.forward();
      }
    });

    ref.listen<LifeStage>(selectedLifeStageProvider, (previous, next) {
      if (previous != next) {
        _updateCustomizedName(generatedName, selectedMaritalStatus, next);
      }
    });

    // Initialize customized name if not set
    if (_customizedName == null) {
      _customizedName = _createCustomizedName(
        generatedName,
        selectedMaritalStatus,
        selectedLifeStage,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _slideController.forward();
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lithuanian Name Customization',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time surname updates based on life stage and marital status',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Original vs Customized name comparison
            _buildNameComparison(context, generatedName, _customizedName!),

            const SizedBox(height: 16),

            // Quick customization buttons
            _buildQuickCustomizationButtons(
              context,
              generatedName,
              selectedLifeStage,
            ),
          ],
        ),
      ),
    );
  }

  /// Build comparison between original and customized names
  Widget _buildNameComparison(
    BuildContext context,
    Name original,
    Name customized,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Original name
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Base name: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              Expanded(
                child: Text(
                  original.fullName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Customized name
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Customized: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  customized.fullName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Show marital status explanation
          if (customized.maritalStatus != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMaritalStatusExplanation(customized.maritalStatus!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build quick customization buttons
  Widget _buildQuickCustomizationButtons(
    BuildContext context,
    Name originalName,
    LifeStage lifeStage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Customization:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MaritalStatus.values.map((status) {
            final isSelected =
                ref.watch(selectedMaritalStatusProvider) == status;
            return AnimatedContainer(
              duration: AppTheme.shortAnimation,
              child: FilterChip(
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedMaritalStatusProvider.notifier).state =
                        status;
                  }
                },
                label: Text(_getMaritalStatusShortName(status)),
                selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                checkmarkColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                tooltip: _getMaritalStatusExplanation(status),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Update the customized name based on new parameters
  void _updateCustomizedName(
    Name baseName,
    MaritalStatus maritalStatus,
    LifeStage lifeStage,
  ) {
    setState(() {
      _customizedName = _createCustomizedName(
        baseName,
        maritalStatus,
        lifeStage,
      );
    });
  }

  /// Create a customized name from base name and parameters
  Name _createCustomizedName(
    Name baseName,
    MaritalStatus maritalStatus,
    LifeStage lifeStage,
  ) {
    // Use the NameRepository's customization method
    final nameRepository = ref.read(nameRepositoryProvider);
    return nameRepository.customizeLithuanianName(
      baseName,
      maritalStatus,
      lifeStage: lifeStage,
    );
  }

  /// Get short name for marital status
  String _getMaritalStatusShortName(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.single:
        return 'Single';
      case MaritalStatus.married:
        return 'Married';
      case MaritalStatus.daughter:
        return 'Daughter';
    }
  }

  /// Get explanation for marital status
  String _getMaritalStatusExplanation(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.single:
        return 'Unmarried woman (maiden name endings like -aitė, -utė)';
      case MaritalStatus.married:
        return 'Married woman (surname ends with -ienė)';
      case MaritalStatus.daughter:
        return 'Young daughter (traditional daughter endings)';
    }
  }
}
