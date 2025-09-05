import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sims4_name_generator/models/name.dart';
import 'package:sims4_name_generator/models/trait.dart';
import 'package:sims4_name_generator/models/enums.dart';
import 'package:sims4_name_generator/services/data_service.dart';

/// Sample data service that loads from sample data files for testing
class SampleDataService implements DataService {
  final AssetBundle _assetBundle;
  final Map<String, List<Name>> _nameCache = {};
  List<Trait>? _traitsCache;

  SampleDataService([AssetBundle? assetBundle])
    : _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<void> initializeData() async {
    // Pre-load traits since they're used frequently
    await loadTraits();
  }

  @override
  Future<List<Name>> loadNames(Region region, Gender gender) async {
    final cacheKey = '${region.name}_${gender.name}';

    // Return cached data if available
    if (_nameCache.containsKey(cacheKey)) {
      return _nameCache[cacheKey]!;
    }

    try {
      // Load the sample JSON file for the specific region and gender
      final fileName = '${region.name}_${gender.name}_sample.json';
      final jsonString = await _assetBundle.loadString(
        'assets/data/sample/$fileName',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate required fields
      if (!jsonData.containsKey('firstNames') ||
          !jsonData.containsKey('lastNames')) {
        throw FormatException(
          'Invalid JSON format: missing firstNames or lastNames',
        );
      }

      final List<String> firstNames = List<String>.from(jsonData['firstNames']);
      final List<String> lastNames = List<String>.from(jsonData['lastNames']);

      // Validate data
      if (firstNames.isEmpty || lastNames.isEmpty) {
        throw FormatException('Invalid data: empty name lists');
      }

      // Generate Name objects by combining first and last names
      final List<Name> names = [];
      for (final firstName in firstNames) {
        for (final lastName in lastNames) {
          names.add(
            Name(
              firstName: firstName,
              lastName: lastName,
              gender: gender,
              region: region,
            ),
          );
        }
      }

      // Cache the results
      _nameCache[cacheKey] = names;

      return names;
    } on FlutterError {
      throw Exception(
        'Failed to load sample names file for $region $gender: Asset not found',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Failed to parse sample names data for $region $gender: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Unexpected error loading sample names for $region $gender: $e',
      );
    }
  }

  @override
  Future<List<Trait>> loadTraits() async {
    // Return cached data if available
    if (_traitsCache != null) {
      return _traitsCache!;
    }

    try {
      // Load the sample traits JSON file
      final jsonString = await _assetBundle.loadString(
        'assets/data/sample/traits_sample.json',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate required fields
      if (!jsonData.containsKey('traits')) {
        throw FormatException('Invalid JSON format: missing traits array');
      }

      final List<dynamic> traitsJson = jsonData['traits'];

      // Convert JSON to Trait objects
      final List<Trait> traits = traitsJson.map((traitJson) {
        try {
          return Trait.fromJson(traitJson as Map<String, dynamic>);
        } catch (e) {
          throw FormatException('Invalid trait data: $e');
        }
      }).toList();

      // Validate data
      if (traits.isEmpty) {
        throw FormatException('Invalid data: empty traits list');
      }

      // Cache the results
      _traitsCache = traits;

      return traits;
    } on FlutterError {
      throw Exception('Failed to load sample traits file: Asset not found');
    } on FormatException catch (e) {
      throw Exception('Failed to parse sample traits data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading sample traits: $e');
    }
  }

  /// Clear all cached data (useful for testing)
  void clearCache() {
    _nameCache.clear();
    _traitsCache = null;
  }
}
