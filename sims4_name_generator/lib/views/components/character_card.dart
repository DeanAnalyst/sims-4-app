import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/character_profile.dart';
import '../../providers/providers.dart';

/// Reusable card component for displaying character profiles
class CharacterCard extends ConsumerWidget {
  final CharacterProfile character;
  final bool showSaveButton;
  final bool showDeleteButton;
  final bool showTimestamp;
  final VoidCallback? onDelete;

  const CharacterCard({
    super.key,
    required this.character,
    this.showSaveButton = false,
    this.showDeleteButton = false,
    this.showTimestamp = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storageNotifier = ref.watch(
      characterStorageNotifierProvider.notifier,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${character.name.region.name} • ${character.name.gender.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSaveButton) _buildSaveButton(storageNotifier),
                    if (showDeleteButton) _buildDeleteButton(),
                    _buildShareButton(storageNotifier),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Traits section
            if (character.traits.isNotEmpty) ...[
              Text(
                'Traits:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: character.traits
                    .map(
                      (trait) => Chip(
                        label: Text(
                          trait.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: theme.colorScheme.secondary.withValues(
                          alpha: 0.2,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ],

            // Timestamp
            if (showTimestamp) ...[
              const SizedBox(height: 12),
              Text(
                'Generated: ${_formatTimestamp(character.generatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(CharacterStorageNotifier storageNotifier) {
    return IconButton(
      icon: const Icon(Icons.bookmark_add),
      onPressed: () => storageNotifier.saveCharacter(character),
      tooltip: 'Save character',
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: onDelete,
      tooltip: 'Delete character',
    );
  }

  Widget _buildShareButton(CharacterStorageNotifier storageNotifier) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => storageNotifier.shareCharacter(character),
      tooltip: 'Share character',
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
