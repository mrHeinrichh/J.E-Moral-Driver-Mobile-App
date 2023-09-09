import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final btncolor;

  CustomCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
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
                    children: [
                      Text(
                        "Barangay:",
                        style: customTextStyle,
                      ),
                      SizedBox(width: 150),
                      Text(
                        "Status:",
                        style: customTextStyle,
                      ),
                    ],
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
                  CardButton(
                    text: buttonText, // Customize the button text
                    onPressed: onPressed,
                    color: btncolor,
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

class CompletedCard extends StatelessWidget {
  final TextStyle customTextStyle;

  CompletedCard({
    required this.customTextStyle,
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
                    children: [
                      Text(
                        "Barangay:",
                        style: customTextStyle,
                      ),
                      SizedBox(width: 150),
                      Text(
                        "Status:",
                        style: customTextStyle,
                      ),
                    ],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickedUpCard extends StatefulWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color btncolor;

  PickedUpCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
  });

  @override
  _PickedUpCardState createState() => _PickedUpCardState();
}

class _PickedUpCardState extends State<PickedUpCard> {
  File? _image;
  bool _imageCaptured = false;

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageCaptured = true; // Image has been captured
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      _imageCaptured = false;
    });
  }

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
                    children: [
                      Text(
                        "Barangay:",
                        style: widget.customTextStyle,
                      ),
                      SizedBox(width: 150),
                      Text(
                        "Status:",
                        style: widget.customTextStyle,
                      ),
                    ],
                  ),
                  Text(
                    "House#/Lot/Blk:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Address:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Booker Name:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Booker Contact:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Receiver Name:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Receiver Contact:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Payment Method:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Needs to be assembled:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Delivery Time:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Delivery Charge:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Product List:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Barangay:",
                    style: widget.customTextStyle,
                  ),
                  Text(
                    "Total Price:",
                    style: widget.customTextStyle,
                  ),

                  GestureDetector(
                    onTap: () {
                      if (_imageCaptured) {
                        _deleteImage(); // Handle image deletion
                      } else {
                        _getImageFromCamera(); // Handle the click action
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // Set the border color
                          width: 2.0, // Set the border width
                        ),
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.camera_alt,
                              color:
                                  Color(0xFF5E738A), // Set icon color to 5E738A
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
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              color: Colors.black54,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _imageCaptured
                                      ? _image != null
                                          ? _image!.path.split('/').last
                                          : 'No Image'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 150.0, // Adjust the height as needed
                    ),
                  ),

                  // Display the captured image
                  // if (_image != null)
                  //   Image.file(
                  //     _image!,
                  //     width: 100,
                  //     height: 100,
                  //   ),

                  CardButton(
                    text: widget.buttonText,
                    onPressed: widget.onPressed,
                    color: _imageCaptured
                        ? const Color(0xFFBD2019) // Change to BD2019 color
                        : widget.btncolor, // Use original color
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
