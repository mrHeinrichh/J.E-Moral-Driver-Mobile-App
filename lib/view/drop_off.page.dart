import 'package:flutter/material.dart';
import '../widgets/payment_details.dart';

import 'package:driver_app/widgets/card_button.dart';

class DropOffPage extends StatelessWidget {
  final TextStyle customTextStyle = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Map<String, dynamic> transactionData = args['transactionData'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop Off Payment'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DriverInformation(
              customTextStyle: customTextStyle,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pickup Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E738A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction ID.: ${transactionData['_id']}",
                              style: customTextStyle,
                            ),
                            Text(
                              "Product List ${transactionData['items']}",
                              style: customTextStyle,
                            ),
                            Text(
                              "Name ${transactionData['name']}",
                              style: customTextStyle,
                            ),
                            Text(
                              "Contact Number ${transactionData['contactNumber']}",
                              style: customTextStyle,
                            ),
                            Text(
                              "House/Lot/Blk ${transactionData['houseLotBlk']}",
                              style: customTextStyle,
                            ),
                            Text(
                              "Pin Location ${transactionData['deliveryLocation']}",
                              style: customTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DropDownPayment(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SpareButton(
                    text: 'CONFIRM PAYMENT',
                    onPressed: () {
                      // Navigator.pushNamed(context, deliveryRoute);
                    },
                    backgroundColor: Colors.red,
                  ),
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
