/// Enum representing different cultural regions for name generation
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

/// Enum representing gender options for name generation
enum Gender { male, female }

/// Enum representing different categories of Sims 4 traits
enum TraitCategory { emotional, hobby, lifestyle, social, toddler, infant }

/// Enum representing different life stages in The Sims 4
enum LifeStage { 
  infant, 
  toddler, 
  child, 
  teen, 
  youngAdult, 
  adult, 
  elder 
}

/// Enum representing marital status for Lithuanian name customization
enum MaritalStatus {
  single,    // Unmarried (uses maiden name endings like -aitė, -utė, -ytė)
  married,   // Married (uses -ienė endings)
  daughter   // Daughter (uses traditional daughter endings)
}

/// Class containing age-based trait limits for different life stages
class AgeBasedLimits {
  static const Map<LifeStage, int> traitLimits = {
    LifeStage.infant: 1,
    LifeStage.toddler: 1,
    LifeStage.child: 1,
    LifeStage.teen: 2,
    LifeStage.youngAdult: 3,
    LifeStage.adult: 3,
    LifeStage.elder: 3,
  };
  
  /// Gets the maximum number of traits allowed for a life stage
  static int getTraitLimit(LifeStage lifeStage) {
    return traitLimits[lifeStage] ?? 3;
  }
}
