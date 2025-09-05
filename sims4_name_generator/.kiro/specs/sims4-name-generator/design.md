# Design Document

## Overview

The Sims 4 Name Generator is a cross-platform Flutter application that provides users with culturally diverse names and character traits for enhanced Sims 4 gameplay. The app follows Flutter's recommended MVVM (Model-View-ViewModel) architecture pattern with clear separation of concerns between UI, business logic, and data layers.

The application will store all data locally in organized JSON files to ensure offline functionality, fast loading times, and efficient parsing. The app will support 13 different cultural regions with 500 names each (250 male, 250 female) and include all official Sims 4 traits from the base game and expansion packs.

## Visual Design & Theme

### Color Scheme: Dreamy Sunset Pastel

The app uses a carefully crafted pastel pink-purple color palette that creates a soft, magical, and welcoming atmosphere perfect for character creation:

#### Primary Colors

- **Primary**: `#E1BEE7` (Mauve) - Main UI elements, buttons, headers
- **Secondary**: `#F2D7D5` (Misty Rose) - Secondary buttons, accents
- **Accent**: `#C8A2C8` (Light Medium Orchid) - Highlights, active states

#### Background Colors

- **Background**: `#FEFBFE` (White Smoke) - Main app background
- **Surface**: `#F6F0F6` (Lavender Blush) - Cards, containers, elevated surfaces
- **Text**: `#2D2D2D` (Dark Charcoal) - Primary text color

#### Flutter Theme Implementation

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE1BEE7), // Primary Mauve
        brightness: Brightness.light,
        primary: const Color(0xFFE1BEE7),
        secondary: const Color(0xFFF2D7D5),
        tertiary: const Color(0xFFC8A2C8),
        background: const Color(0xFFFEFBFE),
        surface: const Color(0xFFF6F0F6),
        onPrimary: const Color(0xFF2D2D2D),
        onSecondary: const Color(0xFF2D2D2D),
        onBackground: const Color(0xFF2D2D2D),
        onSurface: const Color(0xFF2D2D2D),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE1BEE7),
        foregroundColor: Color(0xFF2D2D2D),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE1BEE7),
          foregroundColor: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: const CardTheme(
        color: Color(0xFFF6F0F6),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
```

### Design Principles

- **Soft & Welcoming**: Pastel colors create a non-intimidating, friendly interface
- **Magical Atmosphere**: Pink-purple tones evoke creativity and fantasy
- **High Readability**: Dark charcoal text ensures excellent contrast
- **Modern Material Design**: Follows Material 3 guidelines with custom colors

## Architecture

### Riverpod Architecture Pattern

The application follows Flutter's recommended architecture using Riverpod for state management:

#### UI Layer (Views)

- **Views**: Flutter ConsumerWidgets that compose the user interface
- **Providers**: Manage UI state and handle user interactions using Riverpod
- Reactive UI updates through ref.watch() and ref.listen()

#### Data Layer

- **Repositories**: Source of truth for application data, exposed as Providers
- **Services**: Handle data loading from local JSON files using rootBundle.loadString()
- **Models**: Domain models representing names, traits, and character profiles

#### Provider Layer

- **StateProviders**: Simple state management for UI preferences
- **FutureProviders**: Asynchronous data loading operations
- **StateNotifierProviders**: Complex state management with business logic

### Key Architectural Principles

1. **Separation of Concerns**: Clear boundaries between UI, business logic, and data
2. **Single Source of Truth**: Providers manage all data access and state
3. **Reactive Programming**: Automatic UI updates when provider state changes
4. **Dependency Injection**: Providers automatically handle dependency injection
5. **Offline-First**: All data stored locally for offline functionality
6. **Testability**: Providers can be easily mocked and tested in isolation

## Components and Interfaces

### Core Models

#### Name Model

```dart
class Name {
  final String firstName;
  final String lastName;
  final Gender gender;
  final Region region;

  Name({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.region,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: Gender.values.byName(json['gender'] as String),
      region: Region.values.byName(json['region'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender.name,
      'region': region.name,
    };
  }
}
```

#### Trait Model

```dart
class Trait {
  final String id;
  final String name;
  final String description;
  final TraitCategory category;
  final String pack;
  final List<String> conflictingTraits;

  Trait({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pack,
    this.conflictingTraits = const [],
  });

  factory Trait.fromJson(Map<String, dynamic> json) {
    return Trait(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: TraitCategory.values.byName(json['category'] as String),
      pack: json['pack'] as String,
      conflictingTraits: (json['conflictingTraits'] as List<dynamic>?)
          ?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'pack': pack,
      'conflictingTraits': conflictingTraits,
    };
  }
}
```

#### Character Profile Model

```dart
class CharacterProfile {
  final Name name;
  final List<Trait> traits;
  final DateTime generatedAt;

  CharacterProfile({
    required this.name,
    required this.traits,
    required this.generatedAt,
  });
}
```

### Enums

#### Region Enum

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

#### Gender Enum

```dart
enum Gender {
  male,
  female,
}
```

#### Trait Category Enum

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

### Services

#### Data Service Interface

```dart
abstract class DataService {
  Future<List<Name>> loadNames(Region region, Gender gender);
  Future<List<Trait>> loadTraits();
  Future<void> initializeData();
}
```

#### Local Data Service Implementation

```dart
class LocalDataService implements DataService {
  final AssetBundle _assetBundle;

  LocalDataService(this._assetBundle);

  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    // Load names from markdown files in assets
  }

  @override
  Future<List<Trait>> loadTraits() async {
    // Load traits from markdown files in assets
  }

  @override
  Future<void> initializeData() async {
    // Initialize and cache data on app startup
  }
}
```

### Repositories

#### Name Repository

```dart
class NameRepository {
  final DataService _dataService;
  final Map<String, List<Name>> _nameCache = {};

  NameRepository(this._dataService);

  Future<List<Name>> getNames(Region region, Gender gender) async {
    // Return cached data or load from service
  }

  Name generateRandomName(Region region, Gender gender) {
    // Generate random name from available names
  }
}
```

#### Trait Repository

```dart
class TraitRepository {
  final DataService _dataService;
  List<Trait>? _traitsCache;

  TraitRepository(this._dataService);

  Future<List<Trait>> getAllTraits() async {
    // Return cached traits or load from service
  }

  List<Trait> generateRandomTraits({int maxTraits = 3}) {
    // Generate up to 3 compatible random traits
  }

  bool areTraitsCompatible(List<Trait> traits) {
    // Check for conflicting traits
  }
}
```

### Riverpod Providers

#### Core Data Providers

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

#### State Providers for UI Preferences

```dart
// User preference providers
final selectedRegionProvider = StateProvider<Region>((ref) => Region.english);
final selectedGenderProvider = StateProvider<Gender>((ref) => Gender.male);
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

#### Character Generation Providers

```dart
// Generated content providers
final generatedNameProvider = StateProvider<Name?>((ref) => null);
final generatedTraitsProvider = StateProvider<List<Trait>>((ref) => []);

// Character generation notifier
final characterGeneratorProvider = StateNotifierProvider<CharacterGeneratorNotifier, CharacterGeneratorState>((ref) {
  final nameRepository = ref.watch(nameRepositoryProvider);
  final traitRepository = ref.watch(traitRepositoryProvider);
  return CharacterGeneratorNotifier(nameRepository, traitRepository);
});

class CharacterGeneratorNotifier extends StateNotifier<CharacterGeneratorState> {
  final NameRepository _nameRepository;
  final TraitRepository _traitRepository;

  CharacterGeneratorNotifier(this._nameRepository, this._traitRepository)
      : super(const CharacterGeneratorState.initial());

  Future<void> generateName(Region region, Gender gender) async {
    state = state.copyWith(isGeneratingName: true);
    try {
      final name = _nameRepository.generateRandomName(region, gender);
      state = state.copyWith(
        generatedName: name,
        isGeneratingName: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingName: false,
        error: e.toString(),
      );
    }
  }

  Future<void> generateTraits() async {
    state = state.copyWith(isGeneratingTraits: true);
    try {
      final traits = _traitRepository.generateRandomTraits();
      state = state.copyWith(
        generatedTraits: traits,
        isGeneratingTraits: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingTraits: false,
        error: e.toString(),
      );
    }
  }

  Future<void> generateCompleteCharacter(Region region, Gender gender) async {
    await generateName(region, gender);
    await generateTraits();
  }
}
```

### Views

#### Main Screen

- Region selection dropdown
- Gender selection toggle
- Generate name button
- Generate traits button
- Generate complete character button
- Display area for generated content

#### Settings Screen

- Theme selection
- Default region preference
- Default gender preference
- About information

#### Trait Browser Screen

- Searchable list of all traits
- Filter by category
- Filter by expansion pack
- Trait details view

## Data Models

### Local Data Storage Structure

The application will store data in JSON files within the Flutter assets folder:

```
assets/
├── data/
│   ├── names/
│   │   ├── english_male.json
│   │   ├── english_female.json
│   │   ├── north_african_male.json
│   │   ├── north_african_female.json
│   │   └── ... (all regions and genders)
│   └── traits/
│       └── traits.json
```

### Name Data Format (JSON)

Each name file will contain structured data in JSON format:

```json
{
  "region": "english",
  "gender": "male",
  "firstNames": [
    "Alexander",
    "Benjamin",
    "Christopher",
    "Daniel",
    "Edward",
    "Frederick",
    "George",
    "Henry",
    "Isaac",
    "James",
    "Kenneth",
    "Lawrence",
    "Michael",
    "Nicholas",
    "Oliver"
  ],
  "lastNames": [
    "Anderson",
    "Brown",
    "Clark",
    "Davis",
    "Evans",
    "Fisher",
    "Green",
    "Harris",
    "Johnson",
    "King",
    "Lewis",
    "Miller",
    "Nelson",
    "Parker",
    "Roberts"
  ]
}
```

### Trait Data Format (JSON)

The traits file will contain comprehensive trait information:

```json
{
  "traits": [
    {
      "id": "ambitious",
      "name": "Ambitious",
      "description": "These Sims gain powerful Moodlets from career success, gain negative Moodlets from career failure, and may become Tense if not promoted.",
      "category": "emotional",
      "pack": "base_game",
      "conflictingTraits": ["lazy"]
    },
    {
      "id": "cheerful",
      "name": "Cheerful",
      "description": "These Sims tend to be Happier than other Sims.",
      "category": "emotional",
      "pack": "base_game",
      "conflictingTraits": ["gloomy"]
    }
  ]
}
```

## Error Handling

### Data Loading Errors

- Graceful fallback when JSON files are missing or malformed
- JSON parsing error handling with detailed error messages
- Asset loading error handling using try-catch blocks
- User-friendly error messages displayed through providers
- Retry mechanisms for transient failures

### Generation Errors

- Validation of trait compatibility
- Fallback to default selections when generation fails
- Clear error messages for users

### Network Independence

- All functionality works offline
- No network dependencies
- Local data validation on app startup

## Testing Strategy

### Unit Testing

- Test all business logic in ViewModels
- Test data parsing and validation
- Test trait compatibility logic
- Test random generation algorithms
- Mock dependencies for isolated testing

### Widget Testing

- Test UI components and interactions
- Test state changes and UI updates
- Test navigation between screens
- Test responsive design on different screen sizes

### Integration Testing

- Test complete user workflows
- Test data loading and caching
- Test cross-platform functionality
- Test performance with large datasets

### Test Coverage Goals

- Minimum 80% code coverage
- 100% coverage for critical business logic
- All user-facing features tested
- Performance benchmarks established

### Testing Tools

- Flutter's built-in testing framework
- Mockito for mocking dependencies
- Golden tests for UI consistency
- Integration test driver for end-to-end testing

## Performance Considerations

### Data Loading Optimization

- Lazy loading of name data by region
- Efficient caching strategies
- Background data initialization
- Memory management for large datasets

### UI Performance

- Efficient state management
- Minimal widget rebuilds
- Optimized list rendering
- Smooth animations and transitions

### App Startup

- Fast initial load time
- Progressive data loading
- Splash screen during initialization
- Background data preparation

### Memory Management

- Proper disposal of resources
- Efficient data structures
- Cache size limitations
- Memory leak prevention

This design provides a solid foundation for building a maintainable, scalable, and performant Sims 4 Name Generator app that meets all the specified requirements while following Flutter best practices.
