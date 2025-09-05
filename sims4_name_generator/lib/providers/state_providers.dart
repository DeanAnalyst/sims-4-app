import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/name.dart';
import '../models/trait.dart';

/// Provider for the currently selected region
///
/// Manages the user's region selection for name generation.
/// Defaults to English region.
final selectedRegionProvider = StateProvider<Region>((ref) => Region.english);

/// Provider for the currently selected gender
///
/// Manages the user's gender selection for name generation.
/// Defaults to male gender.
final selectedGenderProvider = StateProvider<Gender>((ref) => Gender.male);

/// Provider for app theme management
///
/// Manages the user's theme preference (light, dark, or system).
/// Defaults to system theme mode.
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider for the currently generated name
///
/// Stores the most recently generated name for display in the UI.
/// Null when no name has been generated yet.
final generatedNameProvider = StateProvider<Name?>((ref) => null);

/// Provider for the currently generated traits
///
/// Stores the most recently generated list of traits for display in the UI.
/// Empty list when no traits have been generated yet.
final generatedTraitsProvider = StateProvider<List<Trait>>((ref) => []);

/// Provider for the currently selected life stage
///
/// Manages the user's life stage selection for age-appropriate trait filtering
/// and Lithuanian name customization. Defaults to young adult.
final selectedLifeStageProvider = StateProvider<LifeStage>((ref) => LifeStage.youngAdult);

/// Provider for the currently selected marital status
///
/// Manages the marital status selection for Lithuanian surname customization.
/// Only relevant when Lithuanian region is selected. Defaults to single.
final selectedMaritalStatusProvider = StateProvider<MaritalStatus>((ref) => MaritalStatus.single);
