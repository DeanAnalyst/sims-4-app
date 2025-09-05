# Developer Guide - Sims 4 Name & Trait Generator

## Overview

This guide is for developers who want to contribute to or extend the Sims 4 Name & Trait Generator application. The app is built with Flutter using the MVVM architecture pattern and Riverpod for state management.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Architecture Overview](#architecture-overview)
3. [Project Structure](#project-structure)
4. [Adding New Features](#adding-new-features)
5. [Testing Guidelines](#testing-guidelines)
6. [Performance Considerations](#performance-considerations)
7. [Code Style & Standards](#code-style--standards)
8. [Deployment](#deployment)
9. [Contributing Guidelines](#contributing-guidelines)

## Development Setup

### Prerequisites

- **Flutter SDK**: 3.10.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sims4-name-generator.git
   cd sims4-name-generator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

### IDE Configuration

**VS Code Extensions:**
- Flutter
- Dart
- Flutter Widget Snippets
- Flutter Intl

**Android Studio Plugins:**
- Flutter
- Dart

### Code Generation

The project uses code generation for testing mocks:

```bash
# Generate mock classes
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch
```

## Architecture Overview

### MVVM Pattern

The app follows the Model-View-ViewModel (MVVM) architecture:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│      View       │    │   ViewModel      │    │      Model      │
│   (UI Layer)    │◄──►│  (Business       │◄──►│   (Data Layer)  │
│                 │    │   Logic)         │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### State Management with Riverpod

Riverpod provides reactive state management with dependency injection:

```dart
// Provider definition
final characterGeneratorProvider = StateNotifierProvider<CharacterGeneratorNotifier, CharacterGeneratorState>((ref) {
  final nameRepository = ref.watch(nameRepositoryProvider);
  final traitRepository = ref.watch(traitRepositoryProvider);
  return CharacterGeneratorNotifier(nameRepository, traitRepository);
});

// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterGeneratorProvider);
    final notifier = ref.read(characterGeneratorProvider.notifier);
    
    return // widget implementation
  }
}
```

### Dependency Injection

Providers handle dependency injection automatically:

```dart
// Service providers
final dataServiceProvider = Provider<DataService>((ref) {
  return LocalDataService();
});

// Repository providers
final nameRepositoryProvider = Provider<NameRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return NameRepository(dataService);
});
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── name.dart            # Name model
│   ├── trait.dart           # Trait model
│   ├── character_profile.dart # Character profile model
│   ├── enums.dart           # Enum definitions
│   └── models.dart          # Model exports
├── services/                 # Business logic services
│   ├── data_service.dart    # Data loading interface
│   ├── local_data_service.dart # Local data implementation
│   ├── character_storage_service.dart # Character storage
│   └── services.dart        # Service exports
├── repositories/             # Data access layer
│   ├── name_repository.dart # Name data access
│   ├── trait_repository.dart # Trait data access
│   └── repositories.dart    # Repository exports
├── providers/                # Riverpod state management
│   ├── data_providers.dart  # Data service providers
│   ├── character_providers.dart # Character generation
│   ├── state_providers.dart # UI state providers
│   └── providers.dart       # Provider exports
├── views/                    # UI screens
│   ├── main_screen.dart     # Main generation screen
│   ├── trait_browser_screen.dart # Trait browser
│   ├── saved_characters_screen.dart # Character history
│   ├── settings_screen.dart # Settings screen
│   └── components/          # Reusable UI components
├── theme/                    # App theming
│   └── app_theme.dart       # Theme configuration
├── utils/                    # Utility functions
│   ├── animations.dart      # Animation utilities
│   ├── performance_utils.dart # Performance helpers
│   └── responsive_layout.dart # Responsive design
└── navigation/               # App routing
    └── app_routes.dart      # Route definitions
```

## Adding New Features

### 1. Define the Feature Requirements

Start by clearly defining what the feature should do:

```dart
// Example: Adding a new cultural region
enum Region {
  english,
  northAfrican,
  // ... existing regions
  newRegion, // Add new region here
}
```

### 2. Update Data Models

Extend the data models to support the new feature:

```dart
// Example: Adding a new field to Name model
class Name {
  final String firstName;
  final String lastName;
  final Gender gender;
  final Region region;
  final String? pronunciation; // New field
  
  Name({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.region,
    this.pronunciation, // Add to constructor
  });
  
  // Update fromJson and toJson methods
}
```

### 3. Update Services

Modify services to handle the new feature:

```dart
// Example: Adding pronunciation support to DataService
abstract class DataService {
  Future<List<Name>> loadNames(Region region, Gender gender);
  Future<List<Trait>> loadTraits();
  Future<void> initializeData();
  Future<String?> getPronunciation(String name); // New method
}
```

### 4. Update Repositories

Extend repositories with new business logic:

```dart
// Example: Adding pronunciation to NameRepository
class NameRepository {
  // ... existing code ...
  
  Future<String?> getPronunciation(Name name) async {
    // Implementation for pronunciation lookup
  }
}
```

### 5. Create Providers

Add new providers for state management:

```dart
// Example: Pronunciation provider
final pronunciationProvider = FutureProvider.family<String?, Name>((ref, name) async {
  final nameRepository = ref.watch(nameRepositoryProvider);
  return await nameRepository.getPronunciation(name);
});
```

### 6. Update UI

Create or modify UI components:

```dart
// Example: Adding pronunciation display
class NameDisplayWidget extends ConsumerWidget {
  final Name name;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pronunciationAsync = ref.watch(pronunciationProvider(name));
    
    return Column(
      children: [
        Text('${name.firstName} ${name.lastName}'),
        pronunciationAsync.when(
          data: (pronunciation) => pronunciation != null 
            ? Text('($pronunciation)', style: TextStyle(fontStyle: FontStyle.italic))
            : SizedBox.shrink(),
          loading: () => CircularProgressIndicator(),
          error: (_, __) => SizedBox.shrink(),
        ),
      ],
    );
  }
}
```

### 7. Add Tests

Create comprehensive tests for the new feature:

```dart
// Example: Testing pronunciation feature
group('Pronunciation Feature', () {
  test('should return pronunciation for valid name', () async {
    final name = Name(
      firstName: 'Test',
      lastName: 'Name',
      gender: Gender.male,
      region: Region.english,
    );
    
    final pronunciation = await nameRepository.getPronunciation(name);
    expect(pronunciation, isNotNull);
  });
  
  test('should return null for name without pronunciation', () async {
    // Test implementation
  });
});
```

## Testing Guidelines

### Test Structure

Follow this structure for all tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';

// Generate mocks
@GenerateMocks([DataService])
import 'name_repository_test.mocks.dart';

void main() {
  group('NameRepository', () {
    late MockDataService mockDataService;
    late NameRepository nameRepository;
    
    setUp(() {
      mockDataService = MockDataService();
      nameRepository = NameRepository(mockDataService);
    });
    
    group('generateRandomName', () {
      test('should generate valid name for given region and gender', () {
        // Arrange
        final testNames = [
          Name(firstName: 'John', lastName: 'Doe', gender: Gender.male, region: Region.english),
        ];
        when(mockDataService.loadNames(Region.english, Gender.male))
            .thenAnswer((_) async => testNames);
        
        // Act
        final result = nameRepository.generateRandomName(Region.english, Gender.male);
        
        // Assert
        expect(result, isA<Name>());
        expect(result.region, equals(Region.english));
        expect(result.gender, equals(Gender.male));
      });
    });
  });
}
```

### Test Categories

1. **Unit Tests**: Test individual functions and methods
2. **Integration Tests**: Test interactions between components
3. **Widget Tests**: Test UI components and user interactions
4. **Performance Tests**: Test performance characteristics

### Mocking Guidelines

Use Mockito for creating mocks:

```dart
// Generate mocks
@GenerateMocks([DataService, NameRepository])
import 'test_file.mocks.dart';

// Use mocks in tests
final mockDataService = MockDataService();
when(mockDataService.loadNames(any, any))
    .thenAnswer((_) async => testData);
```

### Test Coverage

Maintain high test coverage:

```bash
# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Performance Considerations

### Data Loading

- **Use background isolates** for large JSON parsing
- **Implement caching** with appropriate expiry times
- **Lazy load** data when needed
- **Monitor memory usage** and implement cleanup

### UI Performance

- **Minimize widget rebuilds** using const constructors
- **Use ListView.builder** for large lists
- **Implement pagination** for large datasets
- **Optimize animations** and transitions

### Memory Management

```dart
// Example: Proper disposal of resources
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }
  
  @override
  void dispose() {
    _controller.dispose(); // Clean up resources
    super.dispose();
  }
}
```

## Code Style & Standards

### Dart Style Guide

Follow the official Dart style guide:

```dart
// Good: Clear, descriptive names
class CharacterProfileService {
  Future<List<CharacterProfile>> loadSavedCharacters() async {
    // Implementation
  }
}

// Bad: Unclear names
class CPS {
  Future<List<CP>> load() async {
    // Implementation
  }
}
```

### Flutter Best Practices

1. **Use const constructors** when possible
2. **Extract widgets** for reusability
3. **Use meaningful variable names**
4. **Add documentation** for public APIs

```dart
/// A widget that displays character information.
/// 
/// This widget shows the character's name, traits, and generation date.
/// It also provides options to save, share, or delete the character.
class CharacterCard extends StatelessWidget {
  /// The character profile to display.
  final CharacterProfile character;
  
  /// Callback when the character is saved.
  final VoidCallback? onSave;
  
  const CharacterCard({
    super.key,
    required this.character,
    this.onSave,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('${character.name.firstName} ${character.name.lastName}'),
          // ... rest of implementation
        ],
      ),
    );
  }
}
```

### Error Handling

Implement comprehensive error handling:

```dart
// Example: Service with error handling
class LocalDataService implements DataService {
  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    try {
      final jsonString = await _assetBundle.loadString(
        'assets/data/names/${region.name}_${gender.name}.json'
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return (jsonData['names'] as List)
          .map((nameJson) => Name.fromJson(nameJson))
          .toList();
    } catch (e) {
      throw DataLoadException(
        'Failed to load names for $region $gender: $e',
        details: e.toString(),
      );
    }
  }
}
```

## Deployment

### Building for Production

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

**iOS:**
```bash
# Build for iOS
flutter build ios --release
```

**Web:**
```bash
# Build for web
flutter build web --release
```

### App Store Preparation

1. **Update version numbers** in pubspec.yaml
2. **Create app store assets** (screenshots, descriptions)
3. **Test thoroughly** on target devices
4. **Prepare release notes**

### Continuous Integration

Set up CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk
```

## Contributing Guidelines

### Pull Request Process

1. **Create a feature branch** from main
2. **Write tests** for new functionality
3. **Update documentation** as needed
4. **Run all tests** and ensure they pass
5. **Submit a pull request** with clear description

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Performance impact is considered
- [ ] Error handling is implemented
- [ ] Accessibility is maintained

### Commit Message Format

Use conventional commit format:

```
feat: add pronunciation support for names
fix: resolve trait compatibility issue
docs: update API documentation
test: add unit tests for name repository
refactor: improve data loading performance
```

### Issue Reporting

When reporting issues, include:

- **App version** and platform
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots or logs** if applicable
- **Device information** (for mobile issues)

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/cookbook/testing)

## Support

For developer support:

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Documentation**: Check inline code documentation
- **Community**: Join our developer community

---

*This guide is maintained by the development team. For questions or suggestions, please open an issue on GitHub.* 