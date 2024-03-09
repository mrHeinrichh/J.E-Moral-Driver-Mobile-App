import 'package:driver_app/view/authenticate_customer.page.dart';
import 'package:driver_app/view/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'package:driver_app/view/home.page.dart';
import 'package:driver_app/view/login.page.dart';
import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/view/drop_off.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
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
      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => LoginPage(),
        homeRoute: (context) => HomePage(),
        pickupRoute: (context) => PickUpPage(transactionData: {}),
        dropOffRoute: (context) => DropOffPage(),
        authenticateRoute: (context) => AuthenticatePage(transactionData: {}),
      },
    );
  }
}
