// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatapp/models/chat_contact_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/replied_message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatFirebaseProvider = Provider(
  (ref) => ChatFirebase(
    auth: FirebaseAuth.instance,
    fireStore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
    ref: ref,
  ),
);

final chatReplyProvider = StateProvider<RepliedMessageModel?>((ref) => null);

class ChatFirebase {
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;
  final FirebaseStorage firebaseStorage;
  final ProviderRef ref;

  ChatFirebase({
    required this.auth,
    required this.fireStore,
    required this.firebaseStorage,
    required this.ref,
  });

  void storeLastMessageToBothParticipant({
    required UserModel senderData,
    required UserModel receiverData,
    required String message,
    required String dateTime,
  }) async {
    // Sender DOC
    await fireStore
        .collection("users")
        .doc(senderData.uid)
        .collection("chatContacts")
        .doc(receiverData.uid)
        .set(
          ChatContactModel(
            name: receiverData.name,
            receiverID: receiverData.uid,
            lastMessage: message,
            dateTime: dateTime,
            profilePic: receiverData.profilePic,
          ).toJson(),
        );

// Receiver DOC
    await fireStore
        .collection("users")
        .doc(receiverData.uid)
        .collection("chatContacts")
        .doc(senderData.uid)
        .set(
          ChatContactModel(
            name: senderData.name,
            receiverID: senderData.uid,
            lastMessage: message,
            dateTime: dateTime,
            profilePic: senderData.profilePic,
          ).toJson(),
        );
  }

  void storeMessageToBothParticipant(
      {required UserModel senderData,
      required UserModel receiverData,
      required String dateTime,
      required String message,
      required String type,
      required String uniqueMessageID,
      required String repliedMessage,
      required String repliedMessageType,
      required bool isBelongToCurrentUser}) async {
    final data = MessageModel(
        type: type,
        message: message,
        dateTime: dateTime,
        receiverID: receiverData.uid,
        senderID: senderData.uid,
        isSeen: false,
        messageID: uniqueMessageID,
        repliedMessage: repliedMessage,
        repliedMessageType: repliedMessageType,
        isMessageBelongsCurrentUser: isBelongToCurrentUser);

    await fireStore
        .collection("users")
        .doc(senderData.uid)
        .collection("chatContacts")
        .doc(receiverData.uid)
        .collection("chatMessages")
        .doc(uniqueMessageID)
        .set(
          data.toJson(),
        );

    await fireStore
        .collection('users')
        .doc(receiverData.uid)
        .collection("chatContacts")
        .doc(senderData.uid)
        .collection("chatMessages")
        .doc(uniqueMessageID)
        .set(
          data.toJson(),
        );
  }

  void storeChatDataToFireBase(
      {required String receiverID,
      required String message,
      required String dateTime,
      required String type,
      required String repliedMessage,
      required String repliedMessageType,
      required bool isBelongToCurrentUser}) async {
    final senderData =
        await ref.read(firebaseProvider).getCurrentLoggedUserData();

    final dataOfReceiver =
        await fireStore.collection("users").doc(receiverID).get();

    final receiverData = UserModel.toMap(dataOfReceiver.data()!);

    final uniqueMessageID = const Uuid().v1();

// Last Messaage
    storeLastMessageToBothParticipant(
      senderData: senderData!,
      receiverData: receiverData,
      message: message,
      dateTime: dateTime,
    );

// Chat Message
    storeMessageToBothParticipant(
        senderData: senderData,
        receiverData: receiverData,
        dateTime: dateTime,
        message: message,
        type: type,
        uniqueMessageID: uniqueMessageID,
        repliedMessage: repliedMessage,
        repliedMessageType: repliedMessageType,
        isBelongToCurrentUser: isBelongToCurrentUser);
  }

  Stream<List<ChatContactModel>> getChatContactData() {
    return fireStore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("chatContacts")
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContactModel> contacts = [];
        for (var doc in event.docs) {
          var singleUserData = ChatContactModel.toMap(doc.data());
          contacts.add(singleUserData);
        }
        return contacts;
      },
    );
  }


  Stream<List<MessageModel>> getChatMessageData({required String receiverID}) {
    return fireStore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("chatContacts")
        .doc(receiverID)
        .collection("chatMessages")
        .orderBy("dateTime")
        .snapshots()
        .map(
      (event) {
        List<MessageModel> messages = [];
        for (var doc in event.docs) {
          messages.add(
            MessageModel.toMap(doc.data()),
          );
        }
        return messages;
      },
    );
  }


  void storeFileDataToFirebase(
      {required File file,
      required String type,
      required BuildContext context,
      required String receiverID,
      required String repliedMessage,
      required String repliedMessageType,
      required bool isBelongToCurrentUser}) async {
    final dateTime = DateTime.now().millisecondsSinceEpoch.toString();
    final dataOfReceiver =
        await fireStore.collection("users").doc(receiverID).get();
    final UserModel receiverData = UserModel.toMap(dataOfReceiver.data()!);
    final UserModel? senderData =
        await ref.read(firebaseProvider).getCurrentLoggedUserData();
    final String uniqueMessageID = const Uuid().v1();

    String lastMessage = "";
    String fileURL = await ref
        .read(firebaseProvider)
        .uploadFilesToFirebaseStorage(
          path: "chat/$type/${senderData!.uid}/$receiverID/$uniqueMessageID/",
          file: file,
        );

    switch (type) {
      case "image":
        lastMessage = "📷 Image";
        break;
      case "video":
        lastMessage = "📹 Video";
        break;
      case "audio":
        lastMessage = "🔉 Audio";
        break;
    }

    storeLastMessageToBothParticipant(
      senderData: senderData,
      receiverData: receiverData,
      message: lastMessage,
      dateTime: dateTime,
    );

    storeMessageToBothParticipant(
        senderData: senderData,
        receiverData: receiverData,
        dateTime: dateTime,
        message: fileURL,
        type: type,
        uniqueMessageID: uniqueMessageID,
        repliedMessage: repliedMessage,
        repliedMessageType: repliedMessageType,
        isBelongToCurrentUser: isBelongToCurrentUser);
  }

  void updatingIsSeenStatus(
      {required BuildContext context,
      required String messageID,
      required String receiverID}) async {
    await fireStore
        .collection("users")
        .doc(receiverID)
        .collection("chatContacts")
        .doc(auth.currentUser!.uid)
        .collection("chatMessages")
        .doc(messageID)
        .update({"isSeen": true});
  }

  void deleteMessageForEveryone(
      {required String messageID,
      required String receiverID,
      required bool isEveryone,
      required BuildContext context}) async {
    if (isEveryone) {
      await fireStore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chatContacts")
          .doc(receiverID)
          .collection("chatMessages")
          .doc(messageID)
          .update({
        "message": "Message deleted for everyone",
        "repliedMessage": "",
        "repliedMessageType": "",
        "type": "text"
      });

      await fireStore
          .collection("users")
          .doc(receiverID)
          .collection("chatContacts")
          .doc(auth.currentUser!.uid)
          .collection("chatMessages")
          .doc(messageID)
          .update({
        "message": "Message deleted for everyone",
        "repliedMessage": "",
        "repliedMessageType": "",
        "type": "text"
      });
      Navigator.pop(context);
    } else {
      await fireStore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chatContacts")
          .doc(receiverID)
          .collection("chatMessages")
          .doc(messageID)
          .delete();
      Navigator.pop(context);
    }
  }
}
