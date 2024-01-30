import 'package:flutter/material.dart';
import 'package:driver_app/widgets/card_button.dart';

class CompletedCard extends StatelessWidget {
  final TextStyle customTextStyle;
  final Map<String, dynamic> transactionData;

  CompletedCard({
    required this.customTextStyle,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Barangay: ${transactionData['barangay']}",
                        style: customTextStyle,
                      ),
                      SizedBox(width: 50),
                      Text(
                        "Status: ${transactionData['isApproved']}",
                        style: customTextStyle,
                      ),
                    ],
                  ),
                  Text(
                    "House#/Lot/Blk: ${transactionData['houseLotBlk']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Address: ${transactionData['deliveryLocation']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Booker Name: ${transactionData['name']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Booker Contact: ${transactionData['contactNumber']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Receiver Name: ${transactionData['receiverName']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Receiver Contact: ${transactionData['receiverContact']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Payment Method: ${transactionData['paymentMethod']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Needs to be assembled: ${transactionData['assembly']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Delivery Time: ${transactionData['deliveryTime']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Product List: ${transactionData['items']?.toString() ?? 'N/A'}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Total Price: ${transactionData['total']}",
                    style: customTextStyle,
                  ),
                  Text(
                    "Completed: ${transactionData['completed']}",
                    style: customTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
