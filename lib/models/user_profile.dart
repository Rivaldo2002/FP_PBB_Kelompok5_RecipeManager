import 'package:age_calculator/age_calculator.dart';

class UserProfile {
  String userId;
  String? fullName;
  String email;
  String? profilePictureUrl;
  DateTime? dateOfBirth;
  String? gender;
  double? weight;
  double? height;
  double? bmi;

  UserProfile({
    required this.userId,
    this.fullName,
    required this.email,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.bmi,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'bmi': bmi,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'],
      fullName: map['fullName'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'],
      weight: map['weight'],
      height: map['height'],
      bmi: map['bmi'],
    );
  }

  int? get age {
    if (dateOfBirth == null) return null;
    DateDuration duration = AgeCalculator.age(dateOfBirth!);
    return duration.years;
  }
}