// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:io';
import 'package:chatapp/utils/colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

void toShowPopup({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorPallete.lightGreenTheme,
      elevation: 15,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(
            Icons.dangerous,
            color: ColorPallete.dangerRed,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            message,
            style: TextStyle(color: ColorPallete.darkBlack, fontSize: 16),
          )
        ],
      ),
    ),
  );
}

void loading({context, required String message, bool isShow = true}) {
  isShow
      ? showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  message.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        )
      : const SizedBox();
}

Future<File?> pickImageFromGallery({required BuildContext context}) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickMedia(requestFullMetadata: true,imageQuality: 10);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    toShowPopup(context: context, message: e.toString());
  }
  return image;
}

Future<String> checkDeviceOsVersion() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.release;
}

void openSettingsdialog(
    {required BuildContext context, required String alertMessage}) {
  showDialog(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return AlertDialog.adaptive(
        title: const Text("Permissions"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: ColorPallete.lightPurple,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorPallete.darkBlack,
          fontSize: 23,
        ),
        content: Text(
          alertMessage.toString(),
          style: TextStyle(
            color: ColorPallete.darkBlack,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Settings"),
          ),
        ],
      );
    },
  );
}

String dateTimeConverter({required String dateTime, required String format}) {
  final convertedDate = DateFormat(format)
      .format(
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(dateTime),
        ),
      )
      .toLowerCase();

  return convertedDate;
}

String fileTypeSeperator({required String fileName}) {
  List<String> separatedList = fileName.split(".");
  return separatedList[separatedList.length - 1];
}
