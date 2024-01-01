import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/replied_message_model.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/bottom_text_box.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/message_box.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:chatapp/utils/widgets/errorScreen.dart';
import 'package:chatapp/utils/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../models/user_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String name;
  final String uid;
  final String profilePic;
  const ChatPage({
    super.key,
    required this.name,
    required this.uid,
    required this.profilePic,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  // Variables
  final ScrollController _messagePageScrollController = ScrollController();
  String zeroIndexDate = "";
  bool showDate = false;
  bool showRepliedBox = false;
  List<String> menuItems = ["Clear Chats"];

  @override
  void dispose() {
    super.dispose();
    _messagePageScrollController.dispose();
  }

  void messageSeenStatus(
      {required bool isSeen,
      required String receiverID,
      required String currentUser,
      required String messageID}) {
    if (!isSeen && receiverID == currentUser) {
      ref.read(chatFirebaseProvider).updatingIsSeenStatus(
            context: context,
            messageID: messageID,
            receiverID: widget.uid,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.profilePic),
              radius: 24,
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  widget.name,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: StreamBuilder<UserModel>(
                  stream: ref
                      .read(firebaseProvider)
                      .getOnlineStatus(uid: widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("");
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return snapshot.data!.isOnline
                          ? const Text(
                              "online",
                              style: TextStyle(fontSize: 13),
                            )
                          : const Text(
                              "offline",
                              style: TextStyle(fontSize: 13),
                            );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
              offset: const Offset(-20, 40),
              elevation: 10,
              itemBuilder: (context) {
                return [const PopupMenuItem(child: Text("Clear Chats"))];
              })
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<List<MessageModel>>(
            stream: ref
                .watch(chatFirebaseProvider)
                .getChatMessageData(receiverID: widget.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                return ErrorSCreen(errorMessage: snapshot.error.toString());
              } else {
                SchedulerBinding.instance.addPostFrameCallback(
                  (_) {
                    _messagePageScrollController.animateTo(
                      _messagePageScrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  },
                );
                return ListView.builder(
                  controller: _messagePageScrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final singleMessage = snapshot.data![index];
                    final convertedDate = singleMessage.dateTime != ""
                        ? dateTimeConverter(
                            dateTime: singleMessage.dateTime,
                            format: "dd-MM-yyyy",
                          )
                        : "";
                    // To Show Data
                    if (zeroIndexDate == convertedDate && index > 0) {
                      showDate = false;
                    } else {
                      showDate = true;
                      zeroIndexDate = convertedDate;
                    }
                    // To set message blue tick
                    messageSeenStatus(
                      isSeen: singleMessage.isSeen,
                      receiverID: singleMessage.receiverID,
                      currentUser: FirebaseAuth.instance.currentUser!.uid,
                      messageID: singleMessage.messageID,
                    );

                    return Column(
                      children: [
                        showDate
                            ? Align(
                                alignment: Alignment.center,
                                child: Card(
                                  elevation: 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(zeroIndexDate),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        SwipeTo(
                          onRightSwipe: (DragUpdateDetails value) {
                            String replyBoxUserName =
                                widget.uid == singleMessage.senderID
                                    ? widget.name
                                    : "You";
                            ref.read(chatReplyProvider.notifier).update(
                                  (state) => RepliedMessageModel(
                                    name: replyBoxUserName,
                                    repliedMessage: singleMessage.message,
                                    repliedMessageType: singleMessage.type,
                                    repliedMessageBelongsToCurrentUser:
                                        replyBoxUserName == "You"
                                            ? true
                                            : false,
                                  ),
                                );
                          },
                          child: MessageBox(
                            message: singleMessage.message,
                            isSender: singleMessage.senderID ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? true
                                : false,
                            time: singleMessage.dateTime,
                            isSeen: singleMessage.isSeen,
                            type: singleMessage.type,
                            repliedMessage: singleMessage.repliedMessage,
                            repliedMessageType:
                                singleMessage.repliedMessageType,
                            isCurrentUserRepliedHisMessage:
                                singleMessage.isMessageBelongsCurrentUser,
                            name: widget.name,
                            messageID: singleMessage.messageID,
                            receiverID: widget.uid,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          )),
          BottomTextBox(
            name: widget.name,
            profilePic: widget.profilePic,
            uid: widget.uid,
          )
        ],
      ),
    );
  }
}
