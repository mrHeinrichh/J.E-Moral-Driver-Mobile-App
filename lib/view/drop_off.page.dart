import 'dart:convert';
import 'dart:io';

import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/utils/productFormat.dart';
import 'package:driver_app/widgets/payment_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';

class DropOffPage extends StatefulWidget {
  final VoidCallback? onPressed;

  DropOffPage({Key? key, this.onPressed}) : super(key: key);

  @override
  _DropOffPageState createState() => _DropOffPageState();
}

class _DropOffPageState extends State<DropOffPage> {
  final TextStyle customTextStyle = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );
  File? _image;
  bool _imageCaptured = false;
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Map<String, dynamic> transactionData = args['transactionData'];

    Future<void> _getImageFromCamera() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        print('Picked file path: ${pickedFile.path}');

        setState(() {
          _image = File(pickedFile.path);
          _imageCaptured = true;
        });

        print('Image exists: ${_image?.existsSync()}');
      }
    }

    void _deleteImage() {
      setState(() {
        _image = null;
        _imageCaptured = false;
      });
    }

    Future<String> _uploadImage(File imageFile) async {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
        );

        var fileStream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        var length = await imageFile.length();

        String fileExtension = imageFile.path.split('.').last.toLowerCase();
        var contentType = MediaType('image', 'png');

        Map<String, String> imageExtensions = {
          'png': 'png',
          'jpg': 'jpeg',
          'jpeg': 'jpeg',
          'gif': 'gif',
        };

        if (imageExtensions.containsKey(fileExtension)) {
          contentType = MediaType('image', imageExtensions[fileExtension]!);
        }

        var multipartFile = http.MultipartFile(
          'image',
          fileStream,
          length,
          filename: 'image.$fileExtension',
          contentType: contentType,
        );

        request.files.add(multipartFile);

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var decodedResponse = json.decode(responseBody);
          print('Upload success: $decodedResponse');

          // Extract the path from the response
          String pickupImagePath = decodedResponse['data'][0]['path'];

          return pickupImagePath; // Return the pickupImagePath
        } else {
          print('Upload failed with status ${response.statusCode}');
          return ''; // Handle failure appropriately
        }
      } catch (error) {
        print('Error uploading image: $error');
        return ''; // Handle error appropriately
      }
    }

    Future<void> _showSuccessDialog() async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Have you dropped off the following delivery?"),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, homeRoute);
                },
                child: Text("Okay"),
              ),
            ],
          );
        },
      );
    }

    Future<void> _updateTransaction(String transactionId,
        String pickupImagePath, String paymentMethod) async {
      final String apiUrl =
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';

      Map<String, dynamic> updateData = {
        "deliveryLocation": transactionData['deliveryLocation'],
        "name": transactionData['name'],
        "contactNumber": transactionData['contactNumber'],
        "houseLotBlk": transactionData['houseLotBlk'],
        "barangay": transactionData['barangay'],
        "paymentMethod": paymentMethod,
        "assembly": transactionData['assembly'],
        "isApproved": transactionData['isApproved'],
        "deliveryTime": transactionData['deliveryTime'],
        "total": transactionData['total'],
        "items": transactionData['items'],
        "customer": transactionData['customer'],
        "rider": transactionData['rider'],
        "hasFeedback": transactionData['hasFeedback'],
        "feedback": transactionData['feedback'],
        "rating": transactionData['rating'],
        "completionImages": pickupImagePath,
        "pickedUp": true,
        "cancelled": transactionData['cancelled'],
        "completed": true,
        "status": "Completed",
        "__t": "Delivery"
      };

      try {
        final http.Response response = await http.patch(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(updateData),
        );

        if (response.statusCode == 200) {
          print('Transaction updated successfully');
          print('Response: ${response.body}');
          print(response.statusCode);
        } else {
          print(
              'Failed to update transaction. Status code: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      } catch (error) {
        print('Error updating transaction: $error');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop Off Payment'),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                              "Product List: ${ProductUtils.formatProductList(transactionData['items'])}",
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
                  GestureDetector(
                    onTap: () {
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
                ],
              ),
            ),
            Padding(
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
                      items: <String?>['COD', 'GCASH']
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
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SpareButton(
                    text: 'CONFIRM PAYMENT',
                    onPressed: () async {
                      if (_image != null) {
                        String pickupImagePath = await _uploadImage(_image!);
                        _updateTransaction(
                          transactionData['_id'],
                          pickupImagePath,
                          selectedPayment ?? '',
                        );

                        // Show the success dialog
                        _showSuccessDialog();

                        if (widget.onPressed != null) {
                          widget.onPressed!();
                        }
                      } else {
                        print('No image captured.');
                      }
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
