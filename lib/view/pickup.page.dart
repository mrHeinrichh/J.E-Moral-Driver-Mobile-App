import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/widgets/pickup_card.dart';
import 'package:flutter/material.dart';

class PickUpPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;
  PickUpPage({required this.transactionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
        elevation: 1,
        title: const Text(
          'Pick Up Deliveries',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            PickedUpCard(
              buttonText: 'PICKED UP',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  authenticateRoute,
                  arguments: {'transactionData': transactionData},
                );
              },
              btncolor: const Color(0xFFA81616).withOpacity(0.4),
              transactionData: transactionData,
            ),
          ],
        ),
      ),
    );
  }
}
