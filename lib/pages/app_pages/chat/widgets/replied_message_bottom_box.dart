import 'package:chatapp/models/replied_message_model.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/replied_message_chat_box.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepliedMessageBottomBox extends ConsumerStatefulWidget {
  const RepliedMessageBottomBox({
    super.key,
  });

  @override
  ConsumerState<RepliedMessageBottomBox> createState() => _RepliedMessageBottomBoxState();
}

class _RepliedMessageBottomBoxState extends ConsumerState<RepliedMessageBottomBox> {
  @override
  Widget build(BuildContext context) {
    final RepliedMessageModel? repliedMessageData =
        ref.watch(chatReplyProvider);
    return RepliedMessageChatBox(
      name: repliedMessageData!.repliedMessageBelongsToCurrentUser
          ? "You"
          : repliedMessageData.name,
      message: repliedMessageData.repliedMessage,
      messageType: repliedMessageData.repliedMessageType,
      showCloseIcon: true,
      margin: 10,
    );
  }
}
