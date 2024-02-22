import 'package:flutter/material.dart';
import '../widgets/payment_details.dart';
import '../widgets/card_button.dart';
// import '../routes/app_routes.dart';

class PaymentPage extends StatelessWidget {
  final TextStyle customTextStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe7e0e0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Deliveries',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DriverInformation(
              customTextStyle: customTextStyle,
            ),
            PaymentImage(),
            PickupDetails(
              customTextStyle: customTextStyle,
            ),
            DropDownPayment(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  // spareButton(
                  //   text: 'CONFIRM PAYMENT',
                  //   onPressed: () {
                  //     // Navigator.pushNamed(context, deliveryRoute);
                  //   },
                  //   backgroundColor: Colors.red,
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
