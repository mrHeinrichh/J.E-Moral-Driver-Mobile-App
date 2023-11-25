import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:driver_app/widgets/card_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';

class DropOffCard extends StatefulWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color btncolor;
  final Map<String, dynamic> transactionData;

  DropOffCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
    required this.transactionData,
  });

  @override
  _DropOffCardState createState() => _DropOffCardState();
}

class _DropOffCardState extends State<DropOffCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaction id: ${widget.transactionData['_id']}",
                    style: widget.customTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Barangay: ${widget.transactionData['barangay']}",
                        style: widget.customTextStyle,
                      ),
                      SizedBox(width: 50),
                      Text(
                        "Status Approval: ${widget.transactionData['isApproved']}",
                        style: widget.customTextStyle,
                      ),
                    ],
                  ),
                  Text(
                    "House#/Lot/Blk: ${widget.transactionData['houseLotBlk']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Address: ${widget.transactionData['deliveryLocation']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Booker Name: ${widget.transactionData['name']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Booker Contact: ${widget.transactionData['contactNumber']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Receiver Name: ${widget.transactionData['receiverName']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Receiver Contact: ${widget.transactionData['receiverContact']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Payment Method: ${widget.transactionData['paymentMethod']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Needs to be assembled: ${widget.transactionData['assembly']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Delivery Time: ${widget.transactionData['deliveryTime']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Product List: ${widget.transactionData['items']?.toString() ?? 'N/A'}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Total Price: ${widget.transactionData['total']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Pick up Images: ${widget.transactionData['pickupImages']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "CancellationImages: ${widget.transactionData['cancellationImages']}",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Cancel Reason: ${widget.transactionData['cancelReason']?.toString()}",
                    style: widget.customTextStyle,
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
