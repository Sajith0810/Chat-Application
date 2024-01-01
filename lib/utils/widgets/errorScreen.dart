import 'package:flutter/material.dart';

class ErrorSCreen extends StatelessWidget {
  final String errorMessage;
  const ErrorSCreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(errorMessage),
      ),
    );
  }
}
