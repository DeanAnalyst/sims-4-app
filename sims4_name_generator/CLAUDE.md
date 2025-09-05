# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter cross-platform application called "Sims 4 Name & Trait Generator" that generates random character names and traits for The Sims 4 game. The app supports 13 cultural regions with 500 names per region and includes comprehensive Sims 4 trait compatibility.

## Development Commands

### Basic Flutter Commands
- **Install dependencies**: `flutter pub get`
- **Run app**: `flutter run`
- **Run tests**: `flutter test`
- **Run specific test**: `flutter test test/models/models_test.dart`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .`

### Build Commands
- **Android APK**: `flutter build apk --release`
- **iOS App**: `flutter build ios --release`
- **Windows**: `flutter build windows --release`
- **macOS**: `flutter build macos --release`
- **Web**: `flutter build web --release`

### Asset Generation
- **Generate launcher icons**: `flutter pub run flutter_launcher_icons`
- **Generate splash screens**: `flutter pub run flutter_native_splash:create`

### Testing
- **Run with coverage**: `flutter test --coverage`
- **All tests include**: Unit tests (21 tests), Integration tests (15 tests), Performance tests (17 tests), Repository tests (83 tests)

## Architecture Overview

### State Management
- Uses **Riverpod** for reactive state management
- Key providers located in `lib/providers/`
- State providers handle theme, region/gender selection, and character generation
- Data providers manage cached access to names and traits

### Project Structure
```
lib/
├── models/           # Data models (Name, Trait, CharacterProfile, enums)
├── services/         # Business logic and data services
├── repositories/     # Data access layer with caching
├── providers/        # Riverpod state management
├── views/            # UI screens and components
├── theme/            # App theming (custom "Dreamy Sunset Pastel" theme)
├── utils/            # Utility functions and performance monitoring
└── navigation/       # Route definitions and navigation helpers
```

### Data Flow
1. **Data Service**: `LocalDataService` loads JSON files from `assets/data/`
2. **Repositories**: `NameRepository` and `TraitRepository` provide cached access
3. **Providers**: Expose data through Riverpod with automatic cache management
4. **UI Components**: Consume providers for reactive updates

### Key Features
- **Performance Optimized**: Background isolates for JSON parsing, LRU caching, 30-minute name cache, 2-hour trait cache
- **Character Profiles**: Complete characters with names, traits, favorites, and sharing
- **Responsive Design**: Uses `responsive_layout.dart` for adaptive UI
- **Theme Support**: Dark/light themes with custom color scheme

### Data Organization
- **Names**: 13 regions × 2 genders × 250 names in `assets/data/names/`
- **Traits**: All Sims 4 traits with compatibility rules in `assets/data/traits/`
- **Character Storage**: Local persistence using SharedPreferences

### Testing Architecture
- **Unit Tests**: Core models and business logic
- **Integration Tests**: Provider interactions and data flow
- **Performance Tests**: Caching, memory usage, and optimization features
- **Repository Tests**: Data access layer validation

### Navigation
- Uses named routes through `AppRoutes` class
- Screens: Splash, Main, Settings, Trait Browser, Saved Characters, Favorites, Character History
- Helper methods for navigation patterns (push, replace, clear stack)

### Performance Considerations
- Large datasets handled in background isolates
- Configurable cache sizes with memory management
- Lazy loading for UI components
- Performance monitoring service tracks metrics