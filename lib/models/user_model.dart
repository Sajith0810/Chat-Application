class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.isOnline,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "uid": uid,
      "profilePic": profilePic,
      "isOnline": isOnline,
      "phoneNumber": phoneNumber
    };
  }

  factory UserModel.toMap(Map<String, dynamic> jsonData) {
    return UserModel(
      name: jsonData['name'] ?? "",
      uid: jsonData['uid'] ?? "",
      profilePic: jsonData['profilePic'] ?? "",
      isOnline: jsonData['isOnline'],
      phoneNumber: jsonData['phoneNumber'] ?? "",
    );
  }
}
