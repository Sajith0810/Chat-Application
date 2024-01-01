import 'package:chatapp/models/chat_contact_model.dart';
import 'package:chatapp/pages/app_pages/chat/pages/chat_page.dart';
import 'package:chatapp/pages/app_pages/chat/widgets/chat_contact_page_box.dart';
import 'package:chatapp/providers/chat_firebase_provider.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/widgets/errorScreen.dart';
import 'package:chatapp/utils/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatContactPage extends ConsumerStatefulWidget {
  const ChatContactPage({super.key});

  @override
  ConsumerState<ChatContactPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatContactPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ref.watch(firebaseProvider).changeOnlineStatus(isOnline: true);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.watch(firebaseProvider).changeOnlineStatus(isOnline: true);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        ref.watch(firebaseProvider).changeOnlineStatus(isOnline: false);
        break;
      default:
        ref.watch(firebaseProvider).changeOnlineStatus(isOnline: true);
    }
  }

  void navigation({
    required String name,
    required String receiverID,
    required String profilePic,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          name: name,
          uid: receiverID,
          profilePic: profilePic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.watch(chatFirebaseProvider).getChatContactData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return ErrorSCreen(errorMessage: snapshot.error.toString());
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ChatContactModel chatContactData = snapshot.data![index];
              return InkWell(
                onTap: () {
                  navigation(
                    name: chatContactData.name,
                    receiverID: chatContactData.receiverID,
                    profilePic: chatContactData.profilePic,
                  );
                },
                child: ChatContactBox(
                  profilePic: chatContactData.profilePic,
                  name: chatContactData.name,
                  lastMessage: chatContactData.lastMessage,
                  time: chatContactData.dateTime,
                ),
              );
            },
          );
        }
      },
    );
  }
}
