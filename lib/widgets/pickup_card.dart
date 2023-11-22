import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/card_button.dart';

class PickedUpCard extends StatefulWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color btncolor;
  final Map<String, dynamic> transactionData;

  PickedUpCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
    required this.transactionData,
  });

  @override
  _PickedUpCardState createState() => _PickedUpCardState();
}

class _PickedUpCardState extends State<PickedUpCard> {
  File? _image; // Variable to store the picked image
  bool _imageCaptured = false; // Flag to check if an image is captured

  // Function to get an image from the camera
  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageCaptured = true; // Set the flag to true when an image is captured
      });
    }
  }

  // Function to delete the captured image
  void _deleteImage() {
    setState(() {
      _image = null;
      _imageCaptured = false; // Set the flag to false when the image is deleted
    });
  }

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
                  GestureDetector(
                    onTap: () {
                      // Toggle between capturing image and deleting image
                      if (_imageCaptured) {
                        _deleteImage();
                      } else {
                        _getImageFromCamera();
                      }
                    },
                    child: Stack(
                      children: [
                        _imageCaptured
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.file(
                                    _image!,
                                    width: double.infinity,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 100,
                                      child: Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFF5E738A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: _imageCaptured
                              ? IconButton(
                                  onPressed: _deleteImage,
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  CardButton(
                    text: widget.buttonText,
                    onPressed: widget.onPressed,
                    color: _imageCaptured ? Color(0xFFBD2019) : widget.btncolor,
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
