import 'package:driver_app/view/login.page.dart';
import 'package:flutter/material.dart';
// Import your login page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // Theme configuration...
          ),
      home: LoginPage(), // Start with the LoginPage directly.
    );
  }
}
