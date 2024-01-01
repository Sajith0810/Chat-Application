// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/pages/app_pages/chat/pages/chat_contact_page.dart';
import 'package:chatapp/pages/app_pages/status/status_page.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat/pages/contacts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _ChatPageState();
}

class _ChatPageState extends State<HomePage> {
  int currentPageIndex = 0;

  void navigateToContactPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactPage(),
      ),
    );
  }

  void navigation() async {
    if (await Permission.contacts.status.isGranted) {
      navigateToContactPage();
    } else {
      openSettingsdialog(
        context: context,
        alertMessage: "Turn on contact permission in settings",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ChatMee",
          style: TextStyle(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
        backgroundColor: ColorPallete.greenTheme,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigation,
        backgroundColor: ColorPallete.greenTheme,
        child: Icon(
          Icons.contacts_rounded,
          color: ColorPallete.darkBlack,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: NavigationBar(
          destinations: const [
            NavigationDestination(
              tooltip: "Chats",
              icon: Icon(Icons.chat_outlined),
              label: "Chats",
              selectedIcon: Icon(Icons.chat_rounded),
            ),
            NavigationDestination(
              tooltip: "Status",
              icon: Icon(Icons.article_outlined),
              label: "Status",
              selectedIcon: Icon(Icons.article_rounded),
            ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: ColorPallete.greenTheme,
          indicatorColor: ColorPallete.lightGreenTheme,
          selectedIndex: currentPageIndex,
          shadowColor: ColorPallete.darkBlack,
          elevation: 0,
          onDestinationSelected: (int index) =>
              setState(() => currentPageIndex = index),
        ),
      ),
      body:
          currentPageIndex == 0 ? const ChatContactPage() : const StatusPage(),
    );
  }
}
