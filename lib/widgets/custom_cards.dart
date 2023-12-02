import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:driver_app/widgets/card_button.dart';

class CustomCard extends StatelessWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final btncolor;
  final Map<String, dynamic> transactionData;

  CustomCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    bool isApproved = transactionData['isApproved'];

    bool pickedUp = transactionData['pickedUp'];

    bool isCompleted = transactionData['completed'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Visibility(
            visible: isApproved && !isCompleted && !pickedUp,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transaction id: ${transactionData['_id']}",
                      style: customTextStyle,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Barangay: ${transactionData['barangay']}",
                          style: customTextStyle,
                        ),
                        SizedBox(width: 50),
                        Text(
                          "Status Approval: ${transactionData['isApproved']}",
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
                    CardButton(
                      text: buttonText,
                      onPressed: onPressed,
                      color: btncolor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
