class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;
  final String photo;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.photo,
  });

  // ✅ Add fullName getter
  String get fullName => '$firstName $lastName'.trim();

  // ✅ Factory constructor to parse JSON data safely
  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      id: jsonData['_id'] ?? '',
      email: jsonData['email'] ?? '',
      firstName: jsonData['firstName'] ?? jsonData['firstname'] ?? '',
      lastName: jsonData['lastName'] ?? jsonData['lastname'] ?? '',
      mobile: jsonData['mobile'] ?? '',
      photo: jsonData['photo'] ?? '',
    );
  }

  // ✅ Convert to JSON map (for saving to local storage or API)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'photo': photo,
    };
  }

  // ✅ Add copyWith() for easy updates
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? mobile,
    String? photo,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      photo: photo ?? this.photo,
    );
  }
}
