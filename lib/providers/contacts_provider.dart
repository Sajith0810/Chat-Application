import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsProvider = Provider((ref) {
  return SelectContacts(firestore: FirebaseFirestore.instance, ref: ref);
});

final getContactsProvider = FutureProvider((ref) {
  return ref.watch(contactsProvider).getContactsfromPhone();
});

class SelectContacts {
  final FirebaseFirestore firestore;
  final ProviderRef ref;

  SelectContacts({required this.firestore, required this.ref});

  Future<List<Map<String, dynamic>>> getContactsfromPhone() async {
    List<Map<String, dynamic>> appRegisteredContacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);
        QuerySnapshot snapshot = await firestore.collection("users").get();
        if (snapshot.docs.isNotEmpty) {
          for (int i = 0; i < snapshot.docs.length; i++) {
            for (int j = 0; j < contacts.length; j++) {
              if (snapshot.docs[i]['phoneNumber'].toString() ==
                  contacts[j].phones[0].normalizedNumber.toString()) {
                appRegisteredContacts.add(
                  {
                    "profilePic": snapshot.docs[i]['profilePic'],
                    "phoneNumber": contacts[j]
                  },
                );
              }
            }
          }
        }
      }
      return appRegisteredContacts;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return appRegisteredContacts;
  }
}
