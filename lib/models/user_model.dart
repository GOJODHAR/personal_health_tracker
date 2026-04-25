class UserModel {
  final String id;
  final String email;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final int notificationHour;
  final int notificationMinute;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    this.gender = 'Not set',
    required this.heightCm,
    this.weightKg = 0.0,
    this.notificationHour = 20,
    this.notificationMinute = 0,
  });

  /// Alias for id to support older code or Firebase conventions
  String get uid => id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Not set',
      heightCm: (map['heightCm'] ?? 0).toDouble(),
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      notificationHour: map['notificationHour'] ?? 20,
      notificationMinute: map['notificationMinute'] ?? 0,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }
}
