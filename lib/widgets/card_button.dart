import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  CardButton(
      {required this.text, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }
}
