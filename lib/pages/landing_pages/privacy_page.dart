import 'package:chatapp/pages/landing_pages/phonenumber.dart';
import 'package:chatapp/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  void navigation({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneNumberPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ColorPallete.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FadeInImage(
              fadeInCurve: Curves.linear,
              height: 400,
              width: 400,
              placeholder: AssetImage("assets/images/privacy.jpg"),
              image: AssetImage("assets/images/privacy.jpg"),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                "Take privacy with you.\nBe yourself in every message",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: TextButton(
                onPressed: () {},
                child: const Text("Terms & Privacy policy"),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: ElevatedButton(
                onPressed: () => navigation(context: context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.6, 55),
                  backgroundColor: ColorPallete.lightPurple,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
