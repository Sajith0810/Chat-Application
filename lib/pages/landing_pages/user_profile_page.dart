// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/popup_message.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  File? image;
  final TextEditingController _nameController = TextEditingController();
  String defaultImageURL =
      "https://w7.pngwing.com/pngs/312/283/png-transparent-man-s-face-avatar-computer-icons-user-profile-business-user-avatar-blue-face-heroes-thumbnail.png";

  void toSelectProfileImage() async {
    image = await pickImageFromGallery(context: context);
    setState(() {});
  }

  void saveUserData() {
    if (_nameController.text.isNotEmpty) {
      loading(context: context, message: "Initializing");
      ref.read(firebaseProvider).toSaveLoggedUserData(
            name: _nameController.text.trim(),
            profilePic: image,
            context: context,
          );
    } else {
      toShowPopup(context: context, message: "Enter your name");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final osVersion = ref.watch(osVersionProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(100)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: image == null
                      ? CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(defaultImageURL),
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(image!),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    style: ButtonStyle(
                      alignment: Alignment.center,
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => ColorPallete.lightOrange,
                      ),
                      padding: MaterialStateProperty.resolveWith(
                        (states) => const EdgeInsets.all(4),
                      ),
                    ),
                    onPressed: () async {
                      if (await Permission.storage.status.isGranted ||
                          await Permission.videos.status.isGranted) {
                        toSelectProfileImage();
                      } else {
                        openSettingsdialog(
                          context: context,
                          alertMessage:
                              "Turn on storage permission in settings",
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.89,
              height: 80,
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  hintText: "Name",
                  hintFadeDuration: const Duration(milliseconds: 250),
                  icon: Icon(
                    Icons.account_box_rounded,
                    size: 30,
                    color: ColorPallete.darkBlack,
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  filled: true,
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide:
                        BorderSide(width: 1.5, color: ColorPallete.lightPurple),
                  ),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveUserData,
        child: const Icon(Icons.arrow_forward_rounded),
      ),
    );
  }
}
