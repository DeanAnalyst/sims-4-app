import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_profile.dart';
import '../providers/providers.dart';
import '../navigation/app_routes.dart';
import 'components/character_card.dart';

/// Screen displaying saved character profiles with management options
class SavedCharactersScreen extends ConsumerWidget {
  const SavedCharactersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCharactersAsync = ref.watch(savedCharactersProvider);
    final storageNotifier = ref.watch(
      characterStorageNotifierProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Characters'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.goBack(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog(context, storageNotifier);
                  break;
                case 'share_all':
                  final characters = savedCharactersAsync.value ?? [];
                  if (characters.isNotEmpty) {
                    await storageNotifier.shareCharacters(characters);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share_all',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: savedCharactersAsync.when(
        data: (characters) => _buildCharactersList(context, ref, characters),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading saved characters: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(savedCharactersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersList(
    BuildContext context,
    WidgetRef ref,
    List<CharacterProfile> characters,
  ) {
    if (characters.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No saved characters yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Generate characters and save them to see them here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          character: character,
          showSaveButton: false,
          showDeleteButton: true,
          onDelete: () => _showDeleteDialog(context, ref, character),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    CharacterProfile character,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text(
          'Are you sure you want to delete "${character.name.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(characterStorageNotifierProvider.notifier)
                  .deleteSavedCharacter(character);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    CharacterStorageNotifier storageNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Characters'),
        content: const Text(
          'Are you sure you want to delete all saved characters? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              storageNotifier.clearSavedCharacters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
