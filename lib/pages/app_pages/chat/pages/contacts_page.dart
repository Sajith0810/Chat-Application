import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/providers/contacts_provider.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/widgets/errorScreen.dart';
import 'package:chatapp/utils/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<ContactPage> {
  List<Map<String, dynamic>> contacts = [];

  Future<void> refresh() async {
    ref.refresh(getContactsProvider).whenData(
          (value) => setState(() => contacts = value),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contacts"),
        backgroundColor: const Color(0xffcfe1b9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: ref.watch(getContactsProvider).when(
        data: (contacts) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final profilePic = contacts[index]['profilePic'];
                Contact contact = contacts[index]['phoneNumber'];
                return InkWell(
                  onTap: () {
                    ref.read(firebaseProvider).toMoveChatPage(
                          context: context,
                          phoneNumber: contact.phones[0].normalizedNumber,
                        );
                  },
                  child: ListTile(
                    subtitle: Text(
                      contact.phones[0].normalizedNumber ==
                              ref.read(phoneNumberProvider)
                          ? "${contact.phones[0].number} (You)"
                          : contact.phones[0].number,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorPallete.labelGrey,
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(profilePic),
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (error, trace) {
          return ErrorSCreen(errorMessage: error.toString());
        },
        loading: () {
          return const Loader();
        },
      ),
    );
  }
}
