// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider = Provider((ref) => PermissionProvider(ref: ref));

final osVersionProvider =
    StateProvider<int>((ref) => 0);

class PermissionProvider {
  final ProviderRef ref;

  PermissionProvider({required this.ref});

  void toCheckPermission({required BuildContext context}) async {
    final osVersion = int.parse(await checkDeviceOsVersion());
    ref.read(osVersionProvider.notifier).update((state) => osVersion);
    Map<Permission, PermissionStatus> status;
    if (osVersion < 13) {
      status = {
        Permission.contacts: await Permission.contacts.status,
        Permission.storage: await Permission.storage.status,
        Permission.microphone:await Permission.microphone.status,
      };
    } else {
      status = {
        Permission.contacts: await Permission.contacts.status,
        Permission.audio: await Permission.audio.status,
        Permission.videos: await Permission.videos.status,
        Permission.microphone:await Permission.microphone.status,
      };
    }

    for (Permission permission in status.keys) {
      if (status[permission]!.isDenied) {
        await permission.request();
      } 
    }
  }
}
