import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_service.dart';
import '../services/local_data_service.dart';
import '../repositories/name_repository.dart';
import '../repositories/trait_repository.dart';
import '../models/trait.dart';
import '../models/enums.dart';

/// Provider for the data service implementation
///
/// Uses LocalDataService as the concrete implementation for loading
/// names and traits from local JSON assets.
final dataServiceProvider = Provider<DataService>((ref) {
  return LocalDataService();
});

/// Provider for the name repository
///
/// Manages name data loading, caching, and random name generation.
/// Depends on the data service provider for data loading operations.
final nameRepositoryProvider = Provider<NameRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return NameRepository(dataService);
});

/// Provider for the trait repository
///
/// Manages trait data loading, caching, and random trait generation
/// with compatibility checking. Depends on the data service provider.
final traitRepositoryProvider = Provider<TraitRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return TraitRepository(dataService);
});

/// Provider for all traits
///
/// Loads and caches all available traits from the trait repository.
final traitsProvider = FutureProvider<List<Trait>>((ref) async {
  final traitRepository = ref.watch(traitRepositoryProvider);
  return await traitRepository.getAllTraits();
});

/// Provider for trait categories
///
/// Loads all available trait categories from the trait repository.
final traitCategoriesProvider = FutureProvider<List<TraitCategory>>((
  ref,
) async {
  final traitRepository = ref.watch(traitRepositoryProvider);
  return await traitRepository.getAvailableCategories();
});

/// Provider for trait packs
///
/// Loads all available expansion packs from the trait repository.
final traitPacksProvider = FutureProvider<List<String>>((ref) async {
  final traitRepository = ref.watch(traitRepositoryProvider);
  return await traitRepository.getAvailablePacks();
});
