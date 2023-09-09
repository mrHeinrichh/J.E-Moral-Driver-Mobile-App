import 'package:driver_app/view/home.page.dart';
import 'package:driver_app/view/login.page.dart';
import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      initialRoute: loginRoute, // Set the initial route
      routes: {
        loginRoute: (context) => LoginPage(), // Use the imported route
        homeRoute: (context) => HomePage(),
      },
    );
  }
}
