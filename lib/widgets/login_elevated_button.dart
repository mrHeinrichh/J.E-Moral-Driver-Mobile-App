import 'package:flutter/material.dart';

class LoginElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LoginElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBD2019),
        minimumSize: const Size(double.infinity, 48.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}
