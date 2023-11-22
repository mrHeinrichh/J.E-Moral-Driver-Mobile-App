import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatelessWidget {
  final TextStyle customTextStyle;

  DeliveryDetailsCard({
    required this.customTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Center(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Barangay:",
                      style: customTextStyle,
                    ),
                    Text(
                      "House#/Lot/Blk:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Address:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Booker Name:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Booker Contact:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Receiver Name:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Receiver Contact:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Payment Method:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Needs to be assembled:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Delivery Time:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Delivery Charge:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Product List:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Barangay:",
                      style: customTextStyle,
                    ),
                    Text(
                      "Total Price:",
                      style: customTextStyle,
                    ),
                    SizedBox(width: 300),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
