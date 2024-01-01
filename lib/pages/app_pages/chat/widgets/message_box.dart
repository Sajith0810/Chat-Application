import 'package:chatapp/pages/app_pages/chat/widgets/audio_player.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/hero_image_viewer.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/image_viewer.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/replied_message_chat_box.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/video_player.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageBox extends ConsumerStatefulWidget {
  final String message;
  final bool isSender;
  final String time;
  final bool isSeen;
  final String type;
  final String repliedMessage;
  final String repliedMessageType;
  final bool isCurrentUserRepliedHisMessage;
  final String name;
  final String messageID;
  final String receiverID;

  const MessageBox(
      {super.key,
      required this.message,
      required this.isSender,
      required this.time,
      required this.isSeen,
      required this.type,
      required this.repliedMessage,
      required this.repliedMessageType,
      required this.isCurrentUserRepliedHisMessage,
      required this.name,
      required this.messageID,
      required this.receiverID});

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
  void deleteMessage(
      {required String messageID,
      required String receiverID,
      required bool isMessageDeleteForEveryone}) {
    ref.read(chatFirebaseProvider).deleteMessageForEveryone(
        messageID: messageID,
        receiverID: receiverID,
        isEveryone: isMessageDeleteForEveryone,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentTextStyle:
                  const TextStyle(fontSize: 16, color: Colors.black),
              content: const Text("Delete message ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    deleteMessage(
                      messageID: widget.messageID,
                      receiverID: widget.receiverID,
                      isMessageDeleteForEveryone: true,
                    );
                  },
                  child: const Text("Delete for everyone"),
                ),
                TextButton(
                  onPressed: () {
                    deleteMessage(
                      messageID: widget.messageID,
                      receiverID: widget.receiverID,
                      isMessageDeleteForEveryone: false,
                    );
                  },
                  child: const Text("Delete for me"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      child: Align(
        alignment:
            widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isSender
                ? const Color(0xfff5bcba)
                : const Color(0xffe2d2fe),
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: 90,
            minHeight: 55,
          ),
          child: Stack(
            fit: StackFit.loose,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.repliedMessage != ""
                      ? RepliedMessageChatBox(
                          name: widget.isSender ==
                                  widget.isCurrentUserRepliedHisMessage
                              ? "You"
                              : widget.name,
                          message: widget.repliedMessage,
                          messageType: widget.repliedMessageType,
                          showCloseIcon: false,
                          margin: 0,
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.type == "text"
                        ? Text(
                            widget.message,
                            style: const TextStyle(fontSize: 14),
                          )
                        : widget.type == "image"
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HeroImageViewer(
                                        imageURL: widget.message,
                                        heroTag: widget
                                            .messageID, // Same tag as the Hero widget
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: widget.messageID,
                                  child: ImageViewer(imageURL: widget.message),
                                ),
                              )
                            : widget.type == "video"
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoPlayer(
                                            message: widget.message,
                                          ),
                                        ),
                                      );
                                    },
                                    child: VideoPlayer(
                                      message: widget.message,
                                    ),
                                  )
                                : widget.type == "audio"
                                    ? AudioPlayerWidget(
                                        audioFile: widget.message,
                                      )
                                    : const SizedBox(),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.time != ""
                            ? dateTimeConverter(
                                dateTime: widget.time,
                                format: "hh:mm a",
                              )
                            : "",
                        style: const TextStyle(fontSize: 10),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: widget.isSender
                            ? Icon(
                                Icons.done_all_rounded,
                                size: 15,
                                color:
                                    widget.isSeen ? Colors.blue : Colors.black,
                              )
                            : const SizedBox(),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
