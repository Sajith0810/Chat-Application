import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/pages/app_pages/home_page.dart';
import 'package:chatapp/pages/landing_pages/privacy_page.dart';
import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/widgets/errorScreen.dart';
import 'package:chatapp/utils/widgets/loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // check if everything is connected perfectly between FLUTTER FRAMEWORK and PLATFORM
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(
      child: ChatApp(),
    ),
  );
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorPallete.greenTheme,
        ),
      ),
      home: ref.watch(currentUserDataProvider).when(
            data: (user) {
              if (user != null) {
                return const HomePage();
              }
              return const PrivacyPage();
            },
            error: (error, trace) => ErrorSCreen(
              errorMessage: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
