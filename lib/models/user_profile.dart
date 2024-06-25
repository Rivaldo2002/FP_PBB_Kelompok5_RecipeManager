class UserProfile {
  String userId;
  String? fullName;
  String email;
  String? profilePicturePath;
  DateTime? dateOfBirth;
  String? gender;
  double? weight;
  double? height;
  double? bmi;
  int? age;
  bool isAdmin;

  UserProfile({
    required this.userId,
    this.fullName,
    required this.email,
    this.profilePicturePath,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.bmi,
    this.age,
    required this.isAdmin,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'profilePicturePath': profilePicturePath,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'age': age,
      'isAdmin': isAdmin,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'],
      fullName: map['fullName'],
      email: map['email'],
      profilePicturePath: map['profilePicturePath'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'],
      weight: map['weight'],
      height: map['height'],
      bmi: map['bmi'],
      age: map['age'],
      isAdmin: map['isAdmin'],
    );
  }
}