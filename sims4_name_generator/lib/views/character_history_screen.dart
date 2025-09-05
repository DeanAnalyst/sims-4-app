import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_profile.dart';
import '../providers/providers.dart';
import '../navigation/app_routes.dart';
import 'components/character_card.dart';

/// Screen displaying character generation history
class CharacterHistoryScreen extends ConsumerWidget {
  const CharacterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(characterHistoryProvider);
    final storageNotifier = ref.watch(
      characterStorageNotifierProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character History'),
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
                  final characters = historyAsync.value ?? [];
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
                    Icon(Icons.history_toggle_off),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: historyAsync.when(
        data: (characters) => _buildCharactersList(context, ref, characters),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading history: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(characterHistoryProvider),
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
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No character history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Generate complete characters to see them in history',
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
          showSaveButton: true,
          showTimestamp: true,
        );
      },
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    CharacterStorageNotifier storageNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all character generation history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              storageNotifier.clearHistory();
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
