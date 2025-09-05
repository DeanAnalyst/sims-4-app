# API Documentation

## Overview

This document provides comprehensive API documentation for the Sims 4 Name & Trait Generator application. The app follows a clean architecture pattern with clear separation between data models, services, repositories, and state management.

## Table of Contents

1. [Models](#models)
2. [Services](#services)
3. [Repositories](#repositories)
4. [Providers](#providers)
5. [Utilities](#utilities)

## Models

### Name Model

Represents a character name with cultural region and gender information.

```dart
class Name {
  final String firstName;
  final String lastName;
  final Gender gender;
  final Region region;
}
```

**Properties:**
- `firstName` (String): The character's first name
- `lastName` (String): The character's last name
- `gender` (Gender): The character's gender (male/female)
- `region` (Region): The cultural region of the name

**Methods:**
- `fromJson(Map<String, dynamic>)`: Factory constructor from JSON
- `toJson()`: Convert to JSON representation
- `toString()`: String representation for debugging

### Trait Model

Represents a Sims 4 character trait with category and compatibility information.

```dart
class Trait {
  final String id;
  final String name;
  final String description;
  final TraitCategory category;
  final String pack;
  final List<String> conflictingTraits;
}
```

**Properties:**
- `id` (String): Unique identifier for the trait
- `name` (String): Display name of the trait
- `description` (String): Detailed description of the trait
- `category` (TraitCategory): Category classification
- `pack` (String): Expansion pack the trait belongs to
- `conflictingTraits` (List<String>): IDs of incompatible traits

**Methods:**
- `fromJson(Map<String, dynamic>)`: Factory constructor from JSON
- `toJson()`: Convert to JSON representation
- `isCompatibleWith(Trait other)`: Check compatibility with another trait

### CharacterProfile Model

Represents a complete character with name, traits, and metadata.

```dart
class CharacterProfile {
  final Name name;
  final List<Trait> traits;
  final DateTime generatedAt;
  final bool isFavorite;
  final String? notes;
}
```

**Properties:**
- `name` (Name): The character's name
- `traits` (List<Trait>): List of character traits (max 3)
- `generatedAt` (DateTime): When the character was created
- `isFavorite` (bool): Whether the character is marked as favorite
- `notes` (String?): Optional user notes about the character

## Enums

### Region Enum

Defines the supported cultural regions for name generation.

```dart
enum Region {
  english,
  northAfrican,
  subSaharanAfrican,
  eastAfrican,
  southAfrican,
  centralEuropean,
  northernEuropean,
  easternEuropean,
  middleEastern,
  southAsian,
  eastAsian,
  oceania,
  lithuanian,
}
```

### Gender Enum

Defines the supported genders for name generation.

```dart
enum Gender {
  male,
  female,
}
```

### TraitCategory Enum

Defines the categories for Sims 4 traits.

```dart
enum TraitCategory {
  emotional,
  hobby,
  lifestyle,
  social,
  toddler,
  infant,
}
```

## Services

### DataService Interface

Abstract interface for data loading operations.

```dart
abstract class DataService {
  Future<List<Name>> loadNames(Region region, Gender gender);
  Future<List<Trait>> loadTraits();
  Future<void> initializeData();
}
```

**Methods:**
- `loadNames(Region region, Gender gender)`: Load names for specific region and gender
- `loadTraits()`: Load all available traits
- `initializeData()`: Initialize and cache data on app startup

### LocalDataService Implementation

Concrete implementation using local JSON files.

```dart
class LocalDataService implements DataService {
  final AssetBundle _assetBundle;
  final Map<String, List<Name>> _nameCache;
  final List<Trait>? _traitsCache;
}
```

**Features:**
- Background processing for large JSON files
- Memory-managed caching with size limits
- Efficient JSON parsing with ByteData loading
- Automatic cache expiry and cleanup

### CharacterStorageService

Manages local storage of character profiles.

```dart
class CharacterStorageService {
  Future<void> saveCharacter(CharacterProfile character);
  Future<List<CharacterProfile>> loadCharacters();
  Future<void> deleteCharacter(String id);
  Future<void> toggleFavorite(String id);
}
```

**Methods:**
- `saveCharacter(CharacterProfile)`: Save a character profile
- `loadCharacters()`: Load all saved characters
- `deleteCharacter(String)`: Delete a character by ID
- `toggleFavorite(String)`: Toggle favorite status
- `searchCharacters(String query)`: Search characters by name or traits

## Repositories

### NameRepository

Manages name data access and generation logic.

```dart
class NameRepository {
  final DataService _dataService;
  final Map<String, List<Name>> _nameCache;
}
```

**Methods:**
- `getNames(Region region, Gender gender)`: Get names for region/gender
- `generateRandomName(Region region, Gender gender)`: Generate random name
- `getAvailableRegions()`: Get list of available regions
- `getAvailableGenders()`: Get list of available genders

### TraitRepository

Manages trait data access and generation logic.

```dart
class TraitRepository {
  final DataService _dataService;
  final List<Trait>? _traitsCache;
}
```

**Methods:**
- `getAllTraits()`: Get all available traits
- `getTraitsByCategory(TraitCategory category)`: Get traits by category
- `generateRandomTraits({int maxTraits = 3})`: Generate compatible random traits
- `areTraitsCompatible(List<Trait> traits)`: Check trait compatibility
- `getConflictingTraits(Trait trait)`: Get traits that conflict with given trait

## Providers

### Core Data Providers

Riverpod providers for data access.

```dart
// Repository providers
final nameRepositoryProvider = Provider<NameRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return NameRepository(dataService);
});

final traitRepositoryProvider = Provider<TraitRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return TraitRepository(dataService);
});

final dataServiceProvider = Provider<DataService>((ref) {
  return LocalDataService();
});
```

### State Providers

Providers for UI state management.

```dart
// User preference providers
final selectedRegionProvider = StateProvider<Region>((ref) => Region.english);
final selectedGenderProvider = StateProvider<Gender>((ref) => Gender.male);
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Generated content providers
final generatedNameProvider = StateProvider<Name?>((ref) => null);
final generatedTraitsProvider = StateProvider<List<Trait>>((ref) => []);
```

### Character Generation Provider

Complex state management for character generation.

```dart
final characterGeneratorProvider = StateNotifierProvider<CharacterGeneratorNotifier, CharacterGeneratorState>((ref) {
  final nameRepository = ref.watch(nameRepositoryProvider);
  final traitRepository = ref.watch(traitRepositoryProvider);
  return CharacterGeneratorNotifier(nameRepository, traitRepository);
});
```

**Methods:**
- `generateName(Region region, Gender gender)`: Generate a random name
- `generateTraits()`: Generate compatible random traits
- `generateCompleteCharacter(Region region, Gender gender)`: Generate full character
- `regenerateTrait(int index)`: Regenerate a specific trait
- `saveCharacter()`: Save current character to storage

## Utilities

### Performance Monitoring

Built-in performance tracking utilities.

```dart
class PerformanceMonitoringService {
  static void trackOperation(String operationName, Function operation);
  static Map<String, dynamic> getPerformanceStats();
  static void clearStats();
}
```

### Responsive Layout

Utilities for responsive design.

```dart
class ResponsiveLayout {
  static bool isMobile(BuildContext context);
  static bool isTablet(BuildContext context);
  static bool isDesktop(BuildContext context);
  static double getScreenWidth(BuildContext context);
  static double getScreenHeight(BuildContext context);
}
```

### Animations

Custom animation utilities.

```dart
class AnimationUtils {
  static Animation<double> createFadeInAnimation(AnimationController controller);
  static Animation<double> createSlideInAnimation(AnimationController controller);
  static Widget buildAnimatedWidget(Widget child, Animation<double> animation);
}
```

## Error Handling

### Custom Exceptions

```dart
class DataLoadException implements Exception {
  final String message;
  final String? details;
}

class TraitCompatibilityException implements Exception {
  final String message;
  final List<Trait> conflictingTraits;
}

class StorageException implements Exception {
  final String message;
  final String? operation;
}
```

### Error Recovery

The app implements comprehensive error handling with:
- Graceful degradation for missing data
- Automatic retry mechanisms
- User-friendly error messages
- Fallback to default values
- Detailed error logging for debugging

## Testing

### Mock Implementations

```dart
class MockDataService extends Mock implements DataService {}
class MockNameRepository extends Mock implements NameRepository {}
class MockTraitRepository extends Mock implements TraitRepository {}
```

### Test Utilities

```dart
class TestUtils {
  static Name createTestName({Region? region, Gender? gender});
  static Trait createTestTrait({TraitCategory? category});
  static CharacterProfile createTestCharacter();
  static List<Name> createTestNameList(int count);
  static List<Trait> createTestTraitList(int count);
}
```

## Performance Considerations

### Caching Strategy

- **Name Cache**: 30-minute expiry with LRU eviction
- **Trait Cache**: 2-hour expiry with size limits
- **Memory Management**: Configurable cache sizes
- **Background Processing**: Isolate-based JSON parsing

### Optimization Features

- **Lazy Loading**: On-demand data loading
- **Pagination**: Configurable page sizes for large datasets
- **Efficient Parsing**: ByteData-based JSON loading
- **Memory Monitoring**: Automatic leak detection

## Usage Examples

### Basic Name Generation

```dart
// Get a name repository
final nameRepo = ref.read(nameRepositoryProvider);

// Generate a random name
final name = nameRepo.generateRandomName(Region.english, Gender.male);
print('${name.firstName} ${name.lastName}');
```

### Trait Generation

```dart
// Get a trait repository
final traitRepo = ref.read(traitRepositoryProvider);

// Generate compatible traits
final traits = traitRepo.generateRandomTraits(maxTraits: 3);
traits.forEach((trait) => print(trait.name));
```

### Character Generation

```dart
// Use the character generator
final generator = ref.read(characterGeneratorProvider.notifier);

// Generate a complete character
await generator.generateCompleteCharacter(Region.eastAsian, Gender.female);

// Access the generated character
final state = ref.read(characterGeneratorProvider);
final character = CharacterProfile(
  name: state.generatedName!,
  traits: state.generatedTraits,
  generatedAt: DateTime.now(),
);
```

### State Management

```dart
// Watch for state changes
final state = ref.watch(characterGeneratorProvider);

// React to loading states
if (state.isGeneratingName) {
  return CircularProgressIndicator();
}

// Access generated content
if (state.generatedName != null) {
  return Text('${state.generatedName!.firstName} ${state.generatedName!.lastName}');
}
```

---

For more detailed information about specific components, refer to the inline documentation in the source code. 