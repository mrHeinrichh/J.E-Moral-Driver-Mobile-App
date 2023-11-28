// Import necessary packages
import 'package:driver_app/view/authenticate_customer.page.dart';
import 'package:driver_app/view/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';

// Import your view pages
import 'package:driver_app/view/scandropcancel.page.dart';
import 'package:driver_app/view/payment.page.dart';
import 'package:driver_app/view/scandrop.page.dart';
import 'package:driver_app/view/home.page.dart';
import 'package:driver_app/view/login.page.dart';
import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/view/drop_off.page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Other providers if any
      ],
      child: MyApp(),
    ),
  );
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
        pickupRoute: (context) => PickUpPage(transactionData: {}),

        scanDropCancelRoute: (context) => ScanDropCancelPage(),
        dropOffRoute: (context) => DropOffPage(),
        scanDropRoute: (context) => ScanDropPage(),
        paymentRoute: (context) => PaymentPage(),
        authenticateRoute: (context) => AuthenticatePage(transactionData: {}),
      },
    );
  }
}
