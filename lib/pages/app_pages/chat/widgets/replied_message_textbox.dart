import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';

class RepliedMessageTextBox extends StatelessWidget {
  final String message;
  const RepliedMessageTextBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: ColorPallete.labelGrey,
        fontSize: 13,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
