import 'package:chatapp/providers/firebase_provider.dart';
import 'package:chatapp/providers/permission_provider.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:chatapp/utils/popup_message.dart';
import 'package:chatapp/utils/widgets/errorScreen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneNumberPage extends ConsumerStatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  ConsumerState<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends ConsumerState<PhoneNumberPage> {
  String _countryCode = "91";
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(permissionProvider).toCheckPermission(context: context);
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNumberController.dispose();
  }

  void showCountry() {
    showCountryPicker(
      countryListTheme: CountryListThemeData(
        flagSize: 24,
        backgroundColor: ColorPallete.white,
        bottomSheetHeight: 600,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        margin: const EdgeInsets.all(12),
        inputDecoration: const InputDecoration(
          labelText: "Search",
          hintText: "Search",
          border: OutlineInputBorder(),
          hintFadeDuration: Duration(milliseconds: 300),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 25,
          ),
        ),
      ),
      useSafeArea: true,
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() => _countryCode = country.phoneCode);
      },
    );
  }

  void verifyPhoneNumber({required String phoneNumber}) {
    try {
      if (phoneNumber.isNotEmpty && _countryCode.isNotEmpty) {
        String combinedPhoneNumber = "+$_countryCode$phoneNumber";
        ref.read(phoneNumberProvider.notifier).update(
              (state) => combinedPhoneNumber,
            );
        loading(context: context, message: "Sending SMS ...");
        ref
            .read(firebaseProvider)
            .toSendOtp(context: context, phoneNumber: combinedPhoneNumber);
      } else {
        toShowPopup(context: context, message: "Enter all fields");
      }
    } catch (e) {
      ErrorSCreen(errorMessage: e.toString());
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
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 23,
                    letterSpacing: 0.5,
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
                      height: 60,
                      child: TextField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          prefixIcon: TextButton(
                            onPressed: showCountry,
                            child: Text(
                              "+$_countryCode",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Enter phone number",
                          filled: true,
                          hintFadeDuration: const Duration(milliseconds: 250),
                          icon: Icon(
                            Icons.phone_android_rounded,
                            size: 30,
                            color: ColorPallete.white,
                          ),
                          fillColor: ColorPallete.white,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
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
                        onPressed: () {
                          verifyPhoneNumber(
                            phoneNumber: _phoneNumberController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(MediaQuery.of(context).size.width * 0.2, 55),
                          backgroundColor: const Color(0xffd5deef),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
