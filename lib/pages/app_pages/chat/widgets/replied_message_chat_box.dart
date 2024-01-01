import 'package:chatapp/pages/app_pages/chat/widgets/replied_message_textbox.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepliedMessageChatBox extends ConsumerWidget {
  final String name;
  final String message;
  final String messageType;
  final bool showCloseIcon;
  final double margin;
  const RepliedMessageChatBox({
    super.key,
    required this.name,
    required this.message,
    required this.messageType,
    required this.showCloseIcon,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.only(left: margin),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorPallete.greenTheme,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name),
                    const SizedBox(
                      height: 5,
                    ),
                    messageType == "text"
                        ? RepliedMessageTextBox(
                            message: message,
                          )
                        : messageType == "image"
                            ? const RepliedMessageTextBox(message: "📷 Image")
                            : messageType == "video"
                                ? const RepliedMessageTextBox(
                                    message: "📹 Video",
                                  )
                                : messageType == "audio"
                                    ? const RepliedMessageTextBox(
                                        message: "🔉 Audio",
                                      )
                                    : const SizedBox(),
                  ],
                ),
              ),
              showCloseIcon
                  ? GestureDetector(
                      onTap: () {
                        ref
                            .read(chatReplyProvider.notifier)
                            .update((state) => null);
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
