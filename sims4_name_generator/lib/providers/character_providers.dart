import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/name.dart';
import '../models/trait.dart';
import '../models/character_profile.dart';
import '../repositories/name_repository.dart';
import '../repositories/trait_repository.dart';
import '../services/character_storage_service.dart';
import 'data_providers.dart';

/// State class for character generation
///
/// Represents the current state of character generation including
/// loading states, generated content, and any errors.
class CharacterGeneratorState {
  final Name? generatedName;
  final List<Trait> generatedTraits;
  final bool isGeneratingName;
  final bool isGeneratingTraits;
  final String? error;

  const CharacterGeneratorState({
    this.generatedName,
    this.generatedTraits = const [],
    this.isGeneratingName = false,
    this.isGeneratingTraits = false,
    this.error,
  });

  /// Initial state with no generated content
  const CharacterGeneratorState.initial()
    : generatedName = null,
      generatedTraits = const [],
      isGeneratingName = false,
      isGeneratingTraits = false,
      error = null;

  /// Loading state for name generation
  const CharacterGeneratorState.loadingName()
    : generatedName = null,
      generatedTraits = const [],
      isGeneratingName = true,
      isGeneratingTraits = false,
      error = null;

  /// Loading state for trait generation
  const CharacterGeneratorState.loadingTraits()
    : generatedName = null,
      generatedTraits = const [],
      isGeneratingName = false,
      isGeneratingTraits = true,
      error = null;

  /// Error state
  const CharacterGeneratorState.error(String errorMessage)
    : generatedName = null,
      generatedTraits = const [],
      isGeneratingName = false,
      isGeneratingTraits = false,
      error = errorMessage;

  /// Copy with method for state updates
  CharacterGeneratorState copyWith({
    Name? generatedName,
    List<Trait>? generatedTraits,
    bool? isGeneratingName,
    bool? isGeneratingTraits,
    String? error,
    bool clearName = false,
    bool clearTraits = false,
    bool clearError = false,
  }) {
    return CharacterGeneratorState(
      generatedName: clearName ? null : (generatedName ?? this.generatedName),
      generatedTraits: clearTraits
          ? []
          : (generatedTraits ?? this.generatedTraits),
      isGeneratingName: isGeneratingName ?? this.isGeneratingName,
      isGeneratingTraits: isGeneratingTraits ?? this.isGeneratingTraits,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Check if any generation is in progress
  bool get isLoading => isGeneratingName || isGeneratingTraits;

  /// Check if there's generated content to display
  bool get hasContent => generatedName != null || generatedTraits.isNotEmpty;

  /// Get the current character profile if both name and traits are available
  CharacterProfile? get currentCharacterProfile {
    if (generatedName != null && generatedTraits.isNotEmpty) {
      return CharacterProfile(
        name: generatedName!,
        traits: generatedTraits,
        generatedAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterGeneratorState &&
        other.generatedName == generatedName &&
        other.generatedTraits == generatedTraits &&
        other.isGeneratingName == isGeneratingName &&
        other.isGeneratingTraits == isGeneratingTraits &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      generatedName,
      generatedTraits,
      isGeneratingName,
      isGeneratingTraits,
      error,
    );
  }

  @override
  String toString() {
    return 'CharacterGeneratorState('
        'generatedName: $generatedName, '
        'generatedTraits: $generatedTraits, '
        'isGeneratingName: $isGeneratingName, '
        'isGeneratingTraits: $isGeneratingTraits, '
        'error: $error)';
  }
}

/// StateNotifier for managing character generation logic
///
/// Handles name generation, trait generation, and complete character
/// generation with proper error handling and loading states.
class CharacterGeneratorNotifier
    extends StateNotifier<CharacterGeneratorState> {
  final NameRepository _nameRepository;
  final TraitRepository _traitRepository;
  final CharacterStorageService _storageService;

  CharacterGeneratorNotifier(
    this._nameRepository,
    this._traitRepository,
    this._storageService,
  ) : super(const CharacterGeneratorState.initial());

  /// Generate a random name for the specified region and gender
  /// Uses enhanced generation with preferences
  Future<void> generateName(
    Region region,
    Gender gender, {
    bool avoidDuplicates = true,
    LifeStage? lifeStage,
    MaritalStatus? maritalStatus,
  }) async {
    state = state.copyWith(isGeneratingName: true, error: null);

    try {
      final name = await _nameRepository.generateRandomName(
        region,
        gender,
        avoidDuplicates: avoidDuplicates,
        lifeStage: lifeStage,
        maritalStatus: maritalStatus,
      );
      state = state.copyWith(generatedName: name, isGeneratingName: false);
    } catch (e) {
      state = state.copyWith(
        isGeneratingName: false,
        error: 'Failed to generate name: ${e.toString()}',
      );
    }
  }

  /// Generate random compatible traits (up to 3)
  /// Uses enhanced generation with preferences
  Future<void> generateTraits({
    int maxTraits = 3,
    bool avoidDuplicates = true,
    List<TraitCategory>? preferredCategories,
    List<String>? preferredPacks,
  }) async {
    state = state.copyWith(isGeneratingTraits: true, error: null);

    try {
      final traits = await _traitRepository.generateRandomTraits(
        maxTraits: maxTraits,
        avoidDuplicates: avoidDuplicates,
        preferredCategories: preferredCategories,
        preferredPacks: preferredPacks,
      );
      state = state.copyWith(
        generatedTraits: traits,
        isGeneratingTraits: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingTraits: false,
        error: 'Failed to generate traits: ${e.toString()}',
      );
    }
  }

  /// Generate a complete character with both name and traits
  Future<void> generateCompleteCharacter(
    Region region,
    Gender gender, {
    LifeStage? lifeStage,
    MaritalStatus? maritalStatus,
  }) async {
    // Clear any previous error
    state = state.copyWith(error: null);

    // Generate name and traits concurrently
    await Future.wait([
      generateName(
        region,
        gender,
        lifeStage: lifeStage,
        maritalStatus: maritalStatus,
      ),
      generateTraits(),
    ]);

    // Add to history if both name and traits were generated successfully
    if (state.generatedName != null && state.generatedTraits.isNotEmpty) {
      try {
        final character = CharacterProfile(
          name: state.generatedName!,
          traits: state.generatedTraits,
          generatedAt: DateTime.now(),
        );
        await _storageService.addToHistory(character);
      } catch (e) {
        // Don't fail the generation if history addition fails
        // Could log this error if needed
      }
    }
  }

  /// Clear all generated content and reset to initial state
  void clearGeneration() {
    state = const CharacterGeneratorState.initial();
  }

  /// Clear only the generated name
  void clearName() {
    state = state.copyWith(clearName: true);
  }

  /// Clear only the generated traits
  void clearTraits() {
    state = state.copyWith(clearTraits: true);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Regenerate an individual trait while keeping other traits
  Future<void> regenerateIndividualTrait(Trait traitToReplace) async {
    state = state.copyWith(isGeneratingTraits: true, error: null);

    try {
      // Find the index of the trait to replace
      final currentTraits = List<Trait>.from(state.generatedTraits);
      final traitIndex = currentTraits.indexWhere(
        (trait) => trait.id == traitToReplace.id,
      );

      if (traitIndex == -1) {
        throw Exception('Trait not found in current selection');
      }

      // Get traits excluding the one to replace
      final otherTraits = List<Trait>.from(currentTraits);
      otherTraits.removeAt(traitIndex);

      // Generate a new trait that's compatible with existing ones
      final newTrait = await _traitRepository.generateRandomTraitCompatibleWith(
        otherTraits,
      );

      // Replace the trait at the same position
      currentTraits[traitIndex] = newTrait;

      state = state.copyWith(
        generatedTraits: currentTraits,
        isGeneratingTraits: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingTraits: false,
        error: 'Failed to regenerate trait: ${e.toString()}',
      );
    }
  }
}

/// Provider for the character generator notifier
///
/// Manages character generation state and provides methods for
/// generating names, traits, and complete characters.
final characterGeneratorProvider =
    StateNotifierProvider<CharacterGeneratorNotifier, CharacterGeneratorState>((
      ref,
    ) {
      final nameRepository = ref.watch(nameRepositoryProvider);
      final traitRepository = ref.watch(traitRepositoryProvider);
      final storageService = CharacterStorageService();
      return CharacterGeneratorNotifier(
        nameRepository,
        traitRepository,
        storageService,
      );
    });
