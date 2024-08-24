import 'dart:convert';

class User {
  String name;
  String gender;
  int dob;
  int regDate;
  bool isVerified;
  String state;
  String imageUrl;
  String nin;

  User({
    required this.name,
    required this.imageUrl,
    required this.gender,
    required this.dob,
    required this.regDate,
    required this.isVerified,
    required this.state,
    required this.nin,
  });

  static User fromMap(Map user) {
    return User(
      name: user['name'],
      imageUrl: user['imageUrl'] ?? '',
      gender: user['gender'],
      dob: user['dob'],
      regDate: user['regDate'],
      isVerified: user['isVerified'],
      state: user['state'],
      nin: user['nin'],
    );
  }

  toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'gender': gender,
      'dob': dob,
      'reg_date': regDate,
      'is_verified': isVerified,
    };
  }
}
