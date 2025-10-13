class UserModel {
  String id;
  String email;
  String firstName;
  String lastName;
  String mobile;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      id: jsonData['_id'] ?? '',
      email: jsonData['email'] ?? '',
      firstName: jsonData['firstname'] ?? '',
      lastName: jsonData['lastname'] ?? '',
      mobile: jsonData['mobile'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'mobile': mobile,
    };
  }
}