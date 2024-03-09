import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/widgets/pickup_card.dart';
import 'package:flutter/material.dart';

class PickUpPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;
  PickUpPage({required this.transactionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe7e0e0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Pick Up Deliveries',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFd41111),
        centerTitle: true,
      ),
      body: Column(
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
            btncolor: const Color(0xFF5E738A),
            transactionData: transactionData,
          ),
        ],
      ),
    );
  }
}
