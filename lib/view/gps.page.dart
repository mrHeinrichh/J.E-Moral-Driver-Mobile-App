import '../widgets/card_button.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class GpsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'GPS Tracking',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                spareButton(
                  text: 'Deliveries',
                  onPressed: () {
                    Navigator.pushNamed(context, scanDropCancelRoute);
                  },
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
