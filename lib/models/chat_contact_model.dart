class ChatContactModel {
  final String name;
  final String receiverID;
  final String lastMessage;
  final String dateTime;
  final String profilePic;

  const ChatContactModel({
    required this.name,
    required this.receiverID,
    required this.lastMessage,
    required this.dateTime,
    required this.profilePic,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "receiverID": receiverID,
      "lastMessage": lastMessage,
      "dateTime": dateTime,
      "profilePic": profilePic
    };
  }

  factory ChatContactModel.toMap(Map<String, dynamic> data) {
    return ChatContactModel(
      name: data['name'] ?? "",
      receiverID: data['receiverID'] ?? "",
      lastMessage: data['lastMessage'] ?? "",
      dateTime: data['dateTime'] ?? "",
      profilePic: data['profilePic'] ?? "",
    );
  }
}
