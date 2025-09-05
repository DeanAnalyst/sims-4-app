import '../models/name.dart';
import '../models/trait.dart';
import '../models/enums.dart';

/// Abstract interface for data loading services
abstract class DataService {
  /// Load names for a specific region and gender
  Future<List<Name>> loadNames(Region region, Gender gender);

  /// Load all available traits
  Future<List<Trait>> loadTraits();

  /// Initialize the data service and perform any necessary setup
  Future<void> initializeData();
}
