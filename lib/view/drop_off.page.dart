import 'dart:convert';
import 'dart:io';
import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/widgets/payment_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId/complete';

      Map<String, dynamic> updateData = {
        "paymentMethod": paymentMethod,
        "completionImages": pickupImagePath,
      };
      print(paymentMethod);
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
      backgroundColor: Color(0xFFe7e0e0),
      appBar: AppBar(
        title: const Text(
          'Drop Off Payment',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFd41111),
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
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Transaction ID: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['_id']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Receiver Name: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['name']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Receiver Contact Number: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['contactNumber']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Pin Location: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${transactionData['deliveryLocation']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "House#/Lot/Blk:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['houseLotBlk']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Barangay: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF050404),
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${transactionData['barangay']}',
                                        style:
                                            TextStyle(color: Color(0xFF050404)),
                                      ),
                                    ],
                                  ),
                                ),

                                Spacer(), // Adjustable space
                              ],
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Payment Method: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['paymentMethod']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Assemble Option: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: transactionData['assembly'] != null
                                        ? (transactionData['assembly']
                                            ? 'Yes'
                                            : 'No')
                                        : 'N/A',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Items: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (transactionData['items'] != null)
                                    TextSpan(
                                      text: (transactionData['items'] as List)
                                          .map((item) {
                                        if (item is Map<String, dynamic> &&
                                            item.containsKey('name') &&
                                            item.containsKey('quantity')) {
                                          return '${item['name']} (${item['quantity']})';
                                        }
                                        return '';
                                      }).join(', '),
                                    ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Total Price: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '₱${transactionData['total']}',
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Ordered By: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['name']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Ordered By Contact Number: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF050404),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${transactionData['contactNumber']}',
                                    style: TextStyle(color: Color(0xFF050404)),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Delivery Date/Time: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: transactionData['updatedAt'] != null
                                        ? DateFormat('MMM d, y - h:mm a')
                                            .format(
                                            DateTime.parse(
                                                transactionData['updatedAt']),
                                          )
                                        : 'null',
                                  ),
                                ],
                              ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No image captured.'),
                            duration: Duration(
                                seconds:
                                    2), // Set the duration for the snackbar
                            backgroundColor: Colors.red,
                          ),
                        );
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
