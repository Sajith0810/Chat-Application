class RepliedMessageModel {
  final String name;
  final String repliedMessage;
  final String repliedMessageType;
  final bool repliedMessageBelongsToCurrentUser;

  RepliedMessageModel({
    required this.name,
    required this.repliedMessage,
    required this.repliedMessageType,
    required this.repliedMessageBelongsToCurrentUser,
  });
}
