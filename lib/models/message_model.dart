class MessageModel {
  final String type;
  final String message;
  final String dateTime;
  final String receiverID;
  final String senderID;
  final bool isSeen;
  final String messageID;
  final String repliedMessage;
  final String repliedMessageType;
  final bool isMessageBelongsCurrentUser;

  MessageModel({
    required this.type,
    required this.message,
    required this.dateTime,
    required this.receiverID,
    required this.senderID,
    required this.isSeen,
    required this.messageID,
    required this.repliedMessage,
    required this.repliedMessageType,
    required this.isMessageBelongsCurrentUser,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "message": message,
      "dateTime": dateTime,
      "receiverID": receiverID,
      "senderID": senderID,
      "isSeen": isSeen,
      "messageID": messageID,
      "repliedMessage": repliedMessage,
      "repliedMessageType": repliedMessageType,
      "isMessageBelongsCurrentUser": isMessageBelongsCurrentUser
    };
  }

  factory MessageModel.toMap(Map<String, dynamic> data) {
    return MessageModel(
        type: data["type"] ?? "",
        message: data["message"] ?? "",
        dateTime: data['dateTime'] ?? "",
        receiverID: data["receiverID"] ?? "",
        senderID: data["senderID"] ?? "",
        isSeen: data["isSeen"] ?? "",
        messageID: data['messageID'] ?? "",
        repliedMessage: data['repliedMessage'] ?? "",
        repliedMessageType: data['repliedMessageType'] ?? "",
        isMessageBelongsCurrentUser : data['isMessageBelongsCurrentUser'] ?? ""
        );
  }
}
