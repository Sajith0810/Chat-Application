import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';


class ChatContactBox extends StatefulWidget {
  final String profilePic;
  final String name;
  final String lastMessage;
  final String time;
  const ChatContactBox({
    super.key,
    required this.profilePic,
    required this.name,
    required this.lastMessage,
    required this.time,
  });

  @override
  State<ChatContactBox> createState() => _ChatContactBoxState();
}

class _ChatContactBoxState extends State<ChatContactBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.profilePic),
            radius: 25,
          ),
          Expanded(
            child: ListTile(
              title: Text(
                widget.name,
                style: const TextStyle(fontSize: 17),
              ),
              subtitle: Text(
                widget.lastMessage,
                style: TextStyle(color: ColorPallete.labelGrey, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Text(
            dateTimeConverter(dateTime: widget.time, format: "hh:mm a"),
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}
