import 'package:driver_app/view/scandropcancel.page.dart';
import 'package:driver_app/view/payment.page.dart';
import 'package:driver_app/view/scandrop.page.dart';
import 'package:driver_app/view/home.page.dart';
import 'package:driver_app/view/login.page.dart';
import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/view/gps.page.dart';
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
        pickupRoute: (context) => PickUpPage(),
        gpsRoute: (context) => GpsPage(),
        scanDropCancelRoute: (context) => ScanDropCancelPage(),
        scanDropRoute: (context) => ScanDropPage(),
        paymentRoute: (context) => PaymentPage(),
      },
    );
  }
}
