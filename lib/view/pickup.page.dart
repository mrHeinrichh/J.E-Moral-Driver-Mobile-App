import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/widgets/pickup_card.dart';
import 'package:flutter/material.dart';

class PickUpPage extends StatelessWidget {
  final TextStyle customTextStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

  final Map<String, dynamic> transactionData; // Add this line to accept data

  PickUpPage({required this.transactionData}); // Add this constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pick Up Deliveries',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Use the back arrow icon
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context)
                .pop(); // Navigate back when the button is pressed
          },
        ),
      ),
      body: Column(
        children: [
          PickedUpCard(
            customTextStyle: customTextStyle,
            buttonText: 'PICKED UP',
            onPressed: () {
              Navigator.pushNamed(
                context,
                authenticateRoute,
                arguments: {'transactionData': transactionData},
              );
            },
            btncolor: const Color(0xFF5E738A),
            transactionData: transactionData, // Pass data to PickedUpCard
          ),
        ],
      ),
    );
  }
}
