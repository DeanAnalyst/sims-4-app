import '../models/enums.dart';

/// Service to map country codes to app regions for world map functionality
class CountryMappingService {
  static const Map<String, Region> _countryToRegionMap = {
    // English-speaking regions
    'us': Region.english, // United States
    'gb': Region.english, // United Kingdom
    'ca': Region.english, // Canada
    'au': Region.english, // Australia (also in oceania)
    'nz': Region.english, // New Zealand (also in oceania)
    'ie': Region.english, // Ireland
    // North African
    'eg': Region.northAfrican, // Egypt
    'dz': Region.northAfrican, // Algeria
    'sd': Region.northAfrican, // Sudan
    'ma': Region.northAfrican, // Morocco
    'tn': Region.northAfrican, // Tunisia
    'ly': Region.northAfrican, // Libya
    // Sub-Saharan African
    'ng': Region.subSaharanAfrican, // Nigeria
    'et': Region.subSaharanAfrican, // Ethiopia (also in eastAfrican)
    'za': Region.subSaharanAfrican, // South Africa (also in southAfrican)
    'ke': Region.subSaharanAfrican, // Kenya (also in eastAfrican)
    'ug': Region.subSaharanAfrican, // Uganda (also in eastAfrican)
    'gh': Region.subSaharanAfrican, // Ghana
    'cm': Region.subSaharanAfrican, // Cameroon
    'ci': Region.subSaharanAfrican, // Ivory Coast
    'bf': Region.subSaharanAfrican, // Burkina Faso
    'ml': Region.subSaharanAfrican, // Mali
    'ne': Region.subSaharanAfrican, // Niger
    'sn': Region.subSaharanAfrican, // Senegal
    'gn': Region.subSaharanAfrican, // Guinea
    'ss': Region.subSaharanAfrican, // South Sudan
    'cd': Region.subSaharanAfrican, // Democratic Republic of Congo
    'br': Region.english, // Brazil (English-speaking for now)
    // East African
    'tz': Region.eastAfrican, // Tanzania
    'rw': Region.eastAfrican, // Rwanda
    'bi': Region.eastAfrican, // Burundi
    'so': Region.eastAfrican, // Somalia
    'dj': Region.eastAfrican, // Djibouti
    'er': Region.eastAfrican, // Eritrea
    // South African
    'bw': Region.southAfrican, // Botswana
    'na': Region.southAfrican, // Namibia
    'ls': Region.southAfrican, // Lesotho
    'sz': Region.southAfrican, // Eswatini (Swaziland)
    'zw': Region.southAfrican, // Zimbabwe
    'zm': Region.southAfrican, // Zambia
    'mw': Region.southAfrican, // Malawi
    'mz': Region.southAfrican, // Mozambique
    // Central European
    'de': Region.centralEuropean, // Germany
    'cz': Region.centralEuropean, // Czech Republic
    'hu': Region.centralEuropean, // Hungary
    'at': Region.centralEuropean, // Austria
    'ch': Region.centralEuropean, // Switzerland
    'sk': Region.centralEuropean, // Slovakia
    'si': Region.centralEuropean, // Slovenia
    // Northern European
    'se': Region.northernEuropean, // Sweden
    'no': Region.northernEuropean, // Norway
    'fi': Region.northernEuropean, // Finland
    'dk': Region.northernEuropean, // Denmark
    'is': Region.northernEuropean, // Iceland
    // Eastern European
    'ru': Region.easternEuropean, // Russia
    'ua': Region.easternEuropean, // Ukraine
    'pl': Region.easternEuropean, // Poland
    'by': Region.easternEuropean, // Belarus
    'bg': Region.easternEuropean, // Bulgaria
    'ro': Region.easternEuropean, // Romania
    'md': Region.easternEuropean, // Moldova
    'ee': Region.easternEuropean, // Estonia
    'lv': Region.easternEuropean, // Latvia
    'mk': Region.easternEuropean, // North Macedonia
    'al': Region.easternEuropean, // Albania
    'ba': Region.easternEuropean, // Bosnia and Herzegovina
    'hr': Region.easternEuropean, // Croatia
    'me': Region.easternEuropean, // Montenegro
    'rs': Region.easternEuropean, // Serbia
    'xk': Region.easternEuropean, // Kosovo
    // Middle Eastern
    'tr': Region.middleEastern, // Turkey
    'ir': Region.middleEastern, // Iran
    'iq': Region.middleEastern, // Iraq
    'sa': Region.middleEastern, // Saudi Arabia
    'sy': Region.middleEastern, // Syria
    'jo': Region.middleEastern, // Jordan
    'il': Region.middleEastern, // Israel
    'lb': Region.middleEastern, // Lebanon
    'ps': Region.middleEastern, // Palestine
    'kw': Region.middleEastern, // Kuwait
    'qa': Region.middleEastern, // Qatar
    'ae': Region.middleEastern, // UAE
    'om': Region.middleEastern, // Oman
    'bh': Region.middleEastern, // Bahrain
    'ye': Region.middleEastern, // Yemen
    'cy': Region.middleEastern, // Cyprus
    'ge': Region.middleEastern, // Georgia
    'am': Region.middleEastern, // Armenia
    'az': Region.middleEastern, // Azerbaijan
    // South Asian
    'in': Region.southAsian, // India
    'pk': Region.southAsian, // Pakistan
    'bd': Region.southAsian, // Bangladesh
    'lk': Region.southAsian, // Sri Lanka
    'np': Region.southAsian, // Nepal
    'bt': Region.southAsian, // Bhutan
    'mv': Region.southAsian, // Maldives
    'af': Region.southAsian, // Afghanistan
    // East Asian
    'cn': Region.eastAsian, // China
    'jp': Region.eastAsian, // Japan
    'kr': Region.eastAsian, // South Korea
    'tw': Region.eastAsian, // Taiwan
    'mn': Region.eastAsian, // Mongolia
    'kp': Region.eastAsian, // North Korea
    'hk': Region.eastAsian, // Hong Kong
    'mo': Region.eastAsian, // Macau
    // Oceania
    'pg': Region.oceania, // Papua New Guinea
    'fj': Region.oceania, // Fiji
    'sb': Region.oceania, // Solomon Islands
    'vu': Region.oceania, // Vanuatu
    'nc': Region.oceania, // New Caledonia
    'pf': Region.oceania, // French Polynesia
    'ws': Region.oceania, // Samoa
    'ki': Region.oceania, // Kiribati
    'to': Region.oceania, // Tonga
    'nr': Region.oceania, // Nauru
    'tv': Region.oceania, // Tuvalu
    'pw': Region.oceania, // Palau
    'mh': Region.oceania, // Marshall Islands
    'fm': Region.oceania, // Micronesia
    'as': Region.oceania, // American Samoa
    'gu': Region.oceania, // Guam
    'mp': Region.oceania, // Northern Mariana Islands
    'ck': Region.oceania, // Cook Islands
    'nu': Region.oceania, // Niue
    // Lithuanian
    'lt': Region.lithuanian, // Lithuania
  };

  /// Get the region for a given country code
  static Region? getRegionForCountry(String countryCode) {
    return _countryToRegionMap[countryCode.toLowerCase()];
  }

  /// Get all country codes for a specific region
  static List<String> getCountryCodesForRegion(Region region) {
    return _countryToRegionMap.entries
        .where((entry) => entry.value == region)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get a map of colors for all countries based on the selected region
  static Map<String, String> getCountryColors({
    required Region? selectedRegion,
    required String selectedColor,
    required String defaultColor,
  }) {
    if (selectedRegion == null) {
      return {};
    }

    final Map<String, String> colors = {};

    // Set all countries to default color first
    for (final countryCode in _countryToRegionMap.keys) {
      colors[countryCode] = defaultColor;
    }

    // Highlight countries in the selected region
    for (final countryCode in getCountryCodesForRegion(selectedRegion)) {
      colors[countryCode] = selectedColor;
    }

    return colors;
  }

  /// Check if a country belongs to the selected region
  static bool isCountryInSelectedRegion(
    String countryCode,
    Region? selectedRegion,
  ) {
    if (selectedRegion == null) return false;
    return getRegionForCountry(countryCode) == selectedRegion;
  }

  /// Get display name for a region (utility method)
  static String getRegionDisplayName(Region region) {
    switch (region) {
      case Region.english:
        return 'English-speaking regions';
      case Region.northAfrican:
        return 'North African';
      case Region.subSaharanAfrican:
        return 'Sub-Saharan African';
      case Region.eastAfrican:
        return 'East African';
      case Region.southAfrican:
        return 'South African';
      case Region.centralEuropean:
        return 'Central European';
      case Region.northernEuropean:
        return 'Northern European';
      case Region.easternEuropean:
        return 'Eastern European';
      case Region.middleEastern:
        return 'Middle Eastern';
      case Region.southAsian:
        return 'South Asian';
      case Region.eastAsian:
        return 'East Asian';
      case Region.oceania:
        return 'Oceania';
      case Region.lithuanian:
        return 'Lithuanian';
    }
  }

  /// Get all country codes in the mapping
  static List<String> getAllCountryCodes() {
    return _countryToRegionMap.keys.toList();
  }

  /// Get the total number of countries mapped
  static int get totalCountriesMapped => _countryToRegionMap.length;

  /// Get the number of countries for a specific region
  static int getCountryCountForRegion(Region region) {
    return getCountryCodesForRegion(region).length;
  }
}
