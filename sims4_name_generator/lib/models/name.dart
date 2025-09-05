import 'enums.dart';

/// Model representing a generated name with cultural context
class Name {
  final String firstName;
  final String lastName;
  final Gender gender;
  final Region region;
  final LifeStage? lifeStage;
  final MaritalStatus? maritalStatus;

  const Name({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.region,
    this.lifeStage,
    this.maritalStatus,
  });

  /// Creates a Name instance from JSON data
  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: Gender.values.byName(json['gender'] as String),
      region: Region.values.byName(json['region'] as String),
      lifeStage: json['lifeStage'] != null 
          ? LifeStage.values.byName(json['lifeStage'] as String)
          : null,
      maritalStatus: json['maritalStatus'] != null 
          ? MaritalStatus.values.byName(json['maritalStatus'] as String)
          : null,
    );
  }

  /// Converts the Name instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender.name,
      'region': region.name,
      if (lifeStage != null) 'lifeStage': lifeStage!.name,
      if (maritalStatus != null) 'maritalStatus': maritalStatus!.name,
    };
  }

  /// Returns the full name as a single string
  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Name &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.gender == gender &&
        other.region == region &&
        other.lifeStage == lifeStage &&
        other.maritalStatus == maritalStatus;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        gender.hashCode ^
        region.hashCode ^
        (lifeStage?.hashCode ?? 0) ^
        (maritalStatus?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Name(firstName: $firstName, lastName: $lastName, gender: $gender, region: $region, lifeStage: $lifeStage, maritalStatus: $maritalStatus)';
  }

  /// Creates a copy of this Name with optionally updated fields
  Name copyWith({
    String? firstName,
    String? lastName,
    Gender? gender,
    Region? region,
    LifeStage? lifeStage,
    MaritalStatus? maritalStatus,
  }) {
    return Name(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      lifeStage: lifeStage ?? this.lifeStage,
      maritalStatus: maritalStatus ?? this.maritalStatus,
    );
  }
}
