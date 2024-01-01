// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatapp/models/upload_progress_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/app_pages/chat/pages/chat_page.dart';
import 'package:chatapp/pages/app_pages/home_page.dart';
import 'package:chatapp/pages/landing_pages/otp_page.dart';
import 'package:chatapp/pages/landing_pages/user_profile_page.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final firebaseProvider = Provider(
  (ref) => FireBaseAuthStore(
    auth: FirebaseAuth.instance,
    fireStore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
    ref: ref,
  ),
);

final currentUserDataProvider = FutureProvider((ref) {
  return ref.watch(firebaseProvider).getCurrentLoggedUserData();
});
final phoneNumberProvider = StateProvider((ref) => "0");

final uploadProgressProvider =
    StateProvider<UploadProgressModel?>((ref) => null);

final internetProvider = StateProvider<bool?>((ref) => null);

class FireBaseAuthStore {
  final ProviderRef ref;
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;
  final FirebaseStorage firebaseStorage;

  FireBaseAuthStore(
      {required this.auth,
      required this.fireStore,
      required this.firebaseStorage,
      required this.ref});

  void toSendOtp({context, required String phoneNumber}) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            toShowPopup(context: context, message: e.toString());
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(
                  sentotp: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      toShowPopup(context: context, message: e.toString());
    }
  }

  void toVerifyOtp({
    context,
    required String verificationId,
    required String userEnteredOtp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userEnteredOtp,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      loading(message: "", isShow: false);
      toShowPopup(context: context, message: e.toString());
    }
  }

  void toSaveLoggedUserData({
    required String name,
    required File? profilePic,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String profilePicDownloadUrl =
          "https://w7.pngwing.com/pngs/312/283/png-transparent-man-s-face-avatar-computer-icons-user-profile-business-user-avatar-blue-face-heroes-thumbnail.png";
      if (profilePic != null) {
        profilePicDownloadUrl = await uploadFilesToFirebaseStorage(
            path: "profilePic/$uid", file: profilePic);
      }
      final user = UserModel(
        name: name,
        uid: uid,
        profilePic: profilePicDownloadUrl,
        isOnline: true,
        phoneNumber: ref.read(phoneNumberProvider),
      );
      await fireStore.collection("users").doc(uid).set(user.toJson());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } catch (e) {
      toShowPopup(context: context, message: e.toString());
    }
  }

  Future<String> uploadFilesToFirebaseStorage({
    required String path,
    File? file,
  }) async {
    UploadTask uploadImage = firebaseStorage.ref().child(path).putFile(file!);
    final progressStream = uploadImage.snapshotEvents;

    progressStream.listen((event) {
      if (event.state == TaskState.running) {
        final bytesTransferred = event.bytesTransferred;
        final totalBytes = event.totalBytes;
        ref
            .read(uploadProgressProvider.notifier)
            .update((state) => UploadProgressModel(
                  totalBytes: totalBytes.toDouble(),
                  uploadedBytes: bytesTransferred.toDouble(),
                ));

        if (bytesTransferred == totalBytes) {
          ref.read(uploadProgressProvider.notifier).update((state) => null);
        }
      }
    });
    TaskSnapshot snapshot = await uploadImage;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<UserModel?> getCurrentLoggedUserData() async {
    UserModel? userData;
    final currentUserData =
        await fireStore.collection("users").doc(auth.currentUser?.uid).get();

    if (currentUserData.data() != null) {
      return UserModel.toMap(currentUserData.data()!);
    }
    return userData;
  }

  void toMoveChatPage(
      {required String phoneNumber, required BuildContext context}) async {
    QuerySnapshot snapshot = await fireStore
        .collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get();
    if (snapshot.docs[0].exists) {
      final receiverData =
          UserModel.toMap(snapshot.docs[0].data() as Map<String, dynamic>);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            name: receiverData.name,
            profilePic: receiverData.profilePic,
            uid: receiverData.uid,
          ),
        ),
      );
    } else {
      toShowPopup(context: context, message: "User not exist");
    }
  }

  Stream<UserModel> getOnlineStatus({required String uid}) {
    return fireStore.collection("users").doc(uid).snapshots().map(
          (singleUserData) => UserModel.toMap(
            singleUserData.data()!,
          ),
        );
  }

  void changeOnlineStatus({required bool isOnline}) async {
    await fireStore.collection("users").doc(auth.currentUser!.uid).update({
      "isOnline": isOnline,
    });
  }
}
