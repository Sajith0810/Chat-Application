import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String sentotp;
  const OtpPage({super.key, required this.sentotp});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _otpVerifyController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _otpVerifyController.dispose();
  }

  void verifyOtp({required String entererdOTP}) {
    if (_otpVerifyController.text.isNotEmpty) {
      loading(context: context, message: "Verifying OTP");
      ref.read(firebaseProvider).toVerifyOtp(
            context: context,
            userEnteredOtp: entererdOTP,
            verificationId: widget.sentotp,
          );
    } else {
      toShowPopup(context: context, message: "Please enter the OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: 23,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 68, 120, 234),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      color: Colors.grey,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.89,
                      height: 80,
                      child: TextField(
                        controller: _otpVerifyController,
                        maxLength: 6,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        style: const TextStyle(fontSize: 21, letterSpacing: 5),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          hintText: "OTP",
                          hintFadeDuration: Duration(milliseconds: 250),
                          icon: Icon(
                            Icons.security_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () => verifyOtp(
                            entererdOTP: _otpVerifyController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          fixedSize:
                              Size(MediaQuery.of(context).size.width * 0.4, 55),
                          backgroundColor: const Color(0xffd5deef),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.verified_user_rounded),
                            Text(
                              "Verify",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
