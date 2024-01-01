// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatapp/models/replied_message_model.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/replied_message_bottom_box.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/uploadBox.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class BottomTextBox extends ConsumerStatefulWidget {
  final String name;
  final String uid;
  final String profilePic;

  const BottomTextBox({
    super.key,
    required this.name,
    required this.uid,
    required this.profilePic,
  });

  @override
  ConsumerState<BottomTextBox> createState() => _BottomTextBoxState();
}

class _BottomTextBoxState extends ConsumerState<BottomTextBox> {
  final TextEditingController _messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool showEmoji = false;
  bool isMic = true;
  bool isRecording = false;
  final AudioRecorder record = AudioRecorder();
  bool showRepliedBox = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      if (_messageController.text.isEmpty) {
        setState(() {
          isMic = true;
        });
      } else if (_messageController.text.isNotEmpty) {
        setState(() {
          isMic = false;
        });
      }
    });
  }

  void storeChatToFireStore({
    required String uid,
    required String text,
    required String type,
    required String repliedMessage,
    required String repliedMessageType,
    required bool isBelongToCurrentUser,
  }) {
    ref.read(chatFirebaseProvider).storeChatDataToFireBase(
          receiverID: uid,
          dateTime: DateTime.now().millisecondsSinceEpoch.toString(),
          message: text,
          type: type,
          repliedMessage: repliedMessage,
          repliedMessageType: repliedMessageType,
          isBelongToCurrentUser: isBelongToCurrentUser,
        );
  }

  void storeFileToFirestore({required bool isReply, File? file}) async {
    File? media;
    if (file == null) {
      media = await pickImageFromGallery(context: context);
    } else {
      media = file;
    }

    String messageType = "";

    if (media != null) {
      final String fileType =
          fileTypeSeperator(fileName: media.path).toLowerCase();
      switch (fileType) {
        case "mp4":
        case "mpeg":
        case "mkv":
          messageType = "video";
          break;
        case "mp3":
        case "aac":
        case "wav":
          messageType = "audio";
          break;
        case "jpeg":
        case "jpg":
        case "png":
          messageType = "image";
          break;
      }
      final repliedMessage = ref.read(chatReplyProvider);
      ref.read(chatFirebaseProvider).storeFileDataToFirebase(
            file: media,
            type: messageType,
            context: context,
            receiverID: widget.uid,
            repliedMessage: isReply ? repliedMessage!.repliedMessage : "",
            repliedMessageType:
                isReply ? repliedMessage!.repliedMessageType : "",
            isBelongToCurrentUser: repliedMessage != null
                ? repliedMessage.repliedMessageBelongsToCurrentUser
                : false,
          );
    }
  }

  void onEmojiPressed() {
    if (showEmoji) {
      setState(() {
        showEmoji = false;
      });
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
      setState(() {
        showEmoji = true;
      });
    }
  }

  void sendingAudioOrTextData({required bool isReply}) async {
    if (_messageController.text.isNotEmpty) {
      RepliedMessageModel? repliedMessage = ref.read(chatReplyProvider);
      storeChatToFireStore(
        uid: widget.uid,
        text: _messageController.text.trim(),
        type: "text",
        repliedMessage: isReply ? repliedMessage!.repliedMessage : "",
        repliedMessageType: isReply ? repliedMessage!.repliedMessageType : "",
        isBelongToCurrentUser: repliedMessage != null
            ? repliedMessage.repliedMessageBelongsToCurrentUser
            : false,
      );
      ref.read(chatReplyProvider.notifier).update((state) => null);
      setState(() => _messageController.text = "");
    } else if (_messageController.text.isEmpty) {
      if (await Permission.storage.status.isGranted ||
          await Permission.videos.status.isGranted) {
        final Directory? directory = await getDownloadsDirectory();
        if (isRecording) {
          setState(() {
            isMic = true;
            isRecording = false;
          });
          await record.stop();
          storeFileToFirestore(
            file: File("${directory!.path}/song.aac"),
            isReply: isReply,
          );
        } else {
          setState(() {
            isMic = false;
            isRecording = true;
          });
          if (await Permission.microphone.status.isGranted) {
            await record.start(
              const RecordConfig(
                noiseSuppress: true,
              ),
              path: "${directory!.path}/song.aac",
            );
          } else {
            openSettingsdialog(
              context: context,
              alertMessage: "Open Setting and enable microphone permission",
            );
          }
        }
      } else {
        openSettingsdialog(
          context: context,
          alertMessage: "Open Setting and enable storage permission",
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repliedMessageProviderData = ref.watch(chatReplyProvider);
    bool isReplyOn = repliedMessageProviderData != null ? true : false;
    final uploadProgressData = ref.watch(uploadProgressProvider);
    return Column(
      children: [
        repliedMessageProviderData != null
            ? const RepliedMessageBottomBox()
            : const SizedBox(),
        uploadProgressData != null ? UploadBox(uploadProgressModel: uploadProgressData,) : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  bottom: 5,
                  top: 5,
                  right: 0,
                ),
                child: TextField(
                  focusNode: focusNode,
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(
                        showEmoji
                            ? Icons.keyboard_alt_rounded
                            : Icons.emoji_emotions_outlined,
                      ),
                      onPressed: onEmojiPressed,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        if (await Permission.storage.status.isGranted ||
                            await Permission.videos.status.isGranted) {
                          storeFileToFirestore(isReply: isReplyOn, file: null);
                        } else {
                          openSettingsdialog(
                              context: context,
                              alertMessage:
                                  "Turn on Storage Permission to access");
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Type Message",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                      borderSide:
                          BorderSide(width: 0.5, color: ColorPallete.darkBlack),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                      borderSide:
                          BorderSide(width: 1.3, color: ColorPallete.darkBlack),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  onTap: () {
                    if (showEmoji) {
                      setState(() {
                        showEmoji = false;
                      });
                      focusNode.requestFocus();
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 5, top: 5, bottom: 5, left: 3),
              child: IconButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorPallete.blue,
                  alignment: Alignment.center,
                ),
                onPressed: () {
                  sendingAudioOrTextData(isReply: isReplyOn);
                },
                icon: Center(
                  child: Icon(
                    isMic
                        ? Icons.mic_rounded
                        : isRecording
                            ? Icons.close_rounded
                            : Icons.send_rounded,
                    size: 22,
                    color: ColorPallete.white,
                  ),
                ),
              ),
            )
          ],
        ),
        showEmoji
            ? SizedBox(
                height: 280,
                child: EmojiPicker(
                  config: const Config(
                    bgColor: Color(0xffe9f5db),
                    indicatorColor: Color(0xffe6ccb2),
                    iconColorSelected: Color(0xff9c6644),
                    enableSkinTones: true,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                  },
                ))
            : const SizedBox()
      ],
    );
  }
}
