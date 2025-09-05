import '../models/enums.dart';

class RegionalInfo {
  final Region region;
  final String displayName;
  final String description;
  final List<CountryInfo> countries;
  final List<String> languages;
  final String namingTradition;
  final int totalPopulation;

  const RegionalInfo({
    required this.region,
    required this.displayName,
    required this.description,
    required this.countries,
    required this.languages,
    required this.namingTradition,
    required this.totalPopulation,
  });

  factory RegionalInfo.fromJson(Map<String, dynamic> json) {
    return RegionalInfo(
      region: Region.values.firstWhere(
        (r) => r.toString().split('.').last == json['region'],
      ),
      displayName: json['displayName'],
      description: json['description'],
      countries: (json['countries'] as List)
          .map((c) => CountryInfo.fromJson(c))
          .toList(),
      languages: List<String>.from(json['languages']),
      namingTradition: json['namingTradition'],
      totalPopulation: json['totalPopulation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region.toString().split('.').last,
      'displayName': displayName,
      'description': description,
      'countries': countries.map((c) => c.toJson()).toList(),
      'languages': languages,
      'namingTradition': namingTradition,
      'totalPopulation': totalPopulation,
    };
  }

  String get formattedPopulation {
    if (totalPopulation >= 1000000000) {
      return '${(totalPopulation / 1000000000).toStringAsFixed(1)}B';
    } else if (totalPopulation >= 1000000) {
      return '${(totalPopulation / 1000000).toStringAsFixed(0)}M';
    } else if (totalPopulation >= 1000) {
      return '${(totalPopulation / 1000).toStringAsFixed(0)}K';
    }
    return totalPopulation.toString();
  }

  List<CountryInfo> get topCountriesByPopulation {
    final sorted = List<CountryInfo>.from(countries);
    sorted.sort((a, b) => b.population.compareTo(a.population));
    return sorted.take(3).toList();
  }
}

class CountryInfo {
  final String name;
  final String countryCode;
  final int population;
  final String capital;

  const CountryInfo({
    required this.name,
    required this.countryCode,
    required this.population,
    required this.capital,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      name: json['name'],
      countryCode: json['countryCode'],
      population: json['population'],
      capital: json['capital'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'countryCode': countryCode,
      'population': population,
      'capital': capital,
    };
  }

  String get formattedPopulation {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(1)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(0)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }
}