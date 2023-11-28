import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PickupDetails extends StatelessWidget {
  final TextStyle customTextStyle;

  PickupDetails({
    required this.customTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery No.:",
                    style: customTextStyle,
                  ),
                  Text(
                    "Product List:",
                    style: customTextStyle,
                  ),
                  Row(
                    children: [
                      Text(
                        "Regasco",
                        style: customTextStyle,
                      ),
                      const SizedBox(width: 60),
                      Text(
                        "Quantity:",
                        style: customTextStyle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Solane",
                        style: customTextStyle,
                      ),
                      const SizedBox(width: 60),
                      Text(
                        "Quantity:",
                        style: customTextStyle,
                      ),
                    ],
                  ),
                  Text(
                    "Delivery Charge:",
                    style: customTextStyle,
                  ),
                  const SizedBox(height: 5),
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

class DriverInformation extends StatelessWidget {
  final TextStyle customTextStyle;

  DriverInformation({
    required this.customTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 5, 28, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "E-Wallet Driver Information",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5E738A),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/gcash-example.png',
                        width: 90,
                        height: 90,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gcash Name: John Heinrich Fabros",
                            style: customTextStyle,
                          ),
                          Text(
                            "Gcash Number: 0956 974 9935",
                            style: customTextStyle,
                          ),
                        ],
                      ),
                    ],
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

class DropDownPayment extends StatefulWidget {
  @override
  _DropDownPaymentState createState() => _DropDownPaymentState();
}

class _DropDownPaymentState extends State<DropDownPayment> {
  String? selectedPayment; // Default value is null

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Mode of Payment",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E738A),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedPayment,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPayment = newValue;
                });
              },
              items: <String?>['Cash on Delivery', 'GCash']
                  .map<DropdownMenuItem<String>>((String? value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value ?? ''),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Select a Mode of Payment:', // Default text
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentImage extends StatefulWidget {
  PaymentImage({Key? key}) : super(key: key);

  @override
  _PaymentImageState createState() => _PaymentImageState();
}

class _PaymentImageState extends State<PaymentImage> {
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: GestureDetector(
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
            borderRadius: BorderRadius.circular(8.0), // Set border radius
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.camera_alt,
                  color: Color(0xFF5E738A), // Set icon color to 5E738A
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
          height: 60.0,
        ),
      ),
    );
  }
}
