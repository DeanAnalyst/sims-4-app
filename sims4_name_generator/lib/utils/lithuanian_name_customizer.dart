import '../models/enums.dart';

/// Utility class for customizing Lithuanian names based on marital status and life stage
class LithuanianNameCustomizer {
  
  /// Maps base surname endings to their married form (-ienė)
  static const Map<String, String> _marriedEndingMap = {
    'as': 'ienė',      // Petraitis -> Petraitienė  
    'is': 'ienė',      // Kazlauskas -> Kazlauskienė
    'us': 'ienė',      // Stankevičius -> Stankevičienė
    'ys': 'ienė',      // Stonys -> Stonienė
    'ė': 'ienė',       // Mockė -> Mockienė
    'a': 'ienė',       // Navicka -> Navickienė
    'ūnas': 'ūnienė',  // Tamošiūnas -> Tamošiūnienė
    'auskas': 'auskienė', // Kazlauskas -> Kazlauskienė
    'evičius': 'evičienė', // Stankevičius -> Stankevičienė
  };

  /// Maps base surname endings to their unmarried daughter form
  static const Map<String, String> _daughterEndingMap = {
    'as': 'aitė',      // Petraitis -> Petraitaitė
    'is': 'ytė',       // Kazlauskas -> Kazlauskytė  
    'us': 'utė',       // Stankevičius -> Stankevičiutė
    'ys': 'ytė',       // Stonys -> Stonytė
    'ė': 'ė',          // Mockė -> Mockė (unchanged for female base names)
    'a': 'a',          // Navicka -> Navicka (unchanged for female base names)
    'auskas': 'auskaitė', // Kazlauskas -> Kazlauskaité
    'evičius': 'evičiutė', // Stankevičius -> Stankevičiutė
  };

  /// Maps base surname endings to their single/maiden form
  static const Map<String, String> _singleEndingMap = {
    'as': 'aitė',      // Petraitis -> Petraitaitė
    'is': 'ytė',       // Kazlauskas -> Kazlauskytė
    'us': 'utė',       // Stankevičius -> Stankevičiutė  
    'ys': 'ytė',       // Stonys -> Stonytė
    'ė': 'ė',          // Mockė -> Mockė (unchanged)
    'a': 'a',          // Navicka -> Navicka (unchanged)
    'auskas': 'auskaitė', // Kazlauskas -> Kazlauskaité
    'evičius': 'evičiutė', // Stankevičius -> Stankevičiutė
  };

  /// Transforms a Lithuanian surname based on marital status
  /// Returns the transformed surname or the original if no transformation rule applies
  static String transformSurname(String baseSurname, MaritalStatus maritalStatus) {
    if (baseSurname.isEmpty) return baseSurname;

    // Choose the appropriate transformation map
    Map<String, String> endingMap;
    switch (maritalStatus) {
      case MaritalStatus.married:
        endingMap = _marriedEndingMap;
        break;
      case MaritalStatus.daughter:
        endingMap = _daughterEndingMap;
        break;
      case MaritalStatus.single:
        endingMap = _singleEndingMap;
        break;
    }

    // Try to find matching ending and transform
    for (final entry in endingMap.entries) {
      if (baseSurname.endsWith(entry.key)) {
        final baseWithoutEnding = baseSurname.substring(0, baseSurname.length - entry.key.length);
        return baseWithoutEnding + entry.value;
      }
    }

    // If no transformation rule found, return original
    return baseSurname;
  }

  /// Gets the base (masculine) form of a Lithuanian surname
  /// This reverses any feminine transformations to get the root form
  static String getBaseSurname(String surname) {
    if (surname.isEmpty) return surname;

    // Check for married endings (-ienė)
    if (surname.endsWith('ienė')) {
      final base = surname.substring(0, surname.length - 4);
      // Try to determine original masculine ending
      if (base.endsWith('ausk')) return base + 'as';
      if (base.endsWith('evič')) return base + 'ius';
      if (base.endsWith('iūn')) return base + 'as';
      return base + 'as'; // Default assumption
    }

    // Check for daughter/single endings
    if (surname.endsWith('aitė')) {
      return surname.substring(0, surname.length - 4) + 'as';
    }
    if (surname.endsWith('ytė')) {
      final base = surname.substring(0, surname.length - 3);
      if (base.endsWith('ausk')) return base + 'as';
      return base + 'is';
    }
    if (surname.endsWith('utė')) {
      return surname.substring(0, surname.length - 3) + 'us';
    }

    // Return as-is if no feminine endings detected
    return surname;
  }

  /// Determines if a surname appears to be Lithuanian based on common endings
  static bool isLithuanianSurname(String surname) {
    if (surname.isEmpty) return false;
    
    final lithuanianEndings = [
      'as', 'is', 'us', 'ys', 'ė', 'a',
      'ienė', 'aitė', 'ytė', 'utė',
      'auskas', 'auskienė', 'auskaitė',
      'evičius', 'evičienė', 'evičiutė',
      'ūnas', 'ūnienė', 'ūnaitė'
    ];

    return lithuanianEndings.any((ending) => surname.endsWith(ending));
  }

  /// Gets appropriate marital status based on life stage
  /// This provides sensible defaults for life stage selection
  static MaritalStatus getDefaultMaritalStatus(LifeStage lifeStage) {
    switch (lifeStage) {
      case LifeStage.infant:
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
        return MaritalStatus.daughter;
      case LifeStage.youngAdult:
      case LifeStage.adult:
        return MaritalStatus.single; // Could be either, default to single
      case LifeStage.elder:
        return MaritalStatus.married; // More commonly married at elder age
    }
  }

  /// Validates if a surname transformation is appropriate
  /// Returns true if the transformation follows Lithuanian naming conventions
  static bool isValidTransformation(String originalSurname, String transformedSurname, MaritalStatus maritalStatus) {
    if (!isLithuanianSurname(originalSurname) && !isLithuanianSurname(transformedSurname)) {
      return false;
    }

    final expectedTransformed = transformSurname(getBaseSurname(originalSurname), maritalStatus);
    return expectedTransformed == transformedSurname;
  }

  /// Gets display label for marital status in Lithuanian context
  static String getMaritalStatusLabel(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.married:
        return 'Married (ends with -ienė)';
      case MaritalStatus.single:
        return 'Single (maiden name)';
      case MaritalStatus.daughter:
        return 'Daughter (traditional ending)';
    }
  }
}