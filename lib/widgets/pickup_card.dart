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
  File? _image;
  bool _imageCaptured = false;

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageCaptured = true;
      });
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

  Future<void> _updateTransaction(
      String transactionId, String pickupImagePath) async {
    final String apiUrl =
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';

    Map<String, dynamic> updateData = {
      "deliveryLocation": widget.transactionData['deliveryLocation'],
      "name": widget.transactionData['name'],
      "contactNumber": widget.transactionData['contactNumber'],
      "houseLotBlk": widget.transactionData['houseLotBlk'],
      "barangay": widget.transactionData['barangay'],
      "paymentMethod": widget.transactionData['paymentMethod'],
      "assembly": widget.transactionData['assembly'],
      "isApproved": widget.transactionData['isApproved'],
      "deliveryTime": widget.transactionData['deliveryTime'],
      "total": widget.transactionData['total'],
      "items": widget.transactionData['items'],
      "customer": widget.transactionData['customer'],
      "rider": widget.transactionData['rider'],
      "hasFeedback": widget.transactionData['hasFeedback'],
      "feedback": widget.transactionData['feedback'],
      "rating": widget.transactionData['rating'],
      "pickupImages": pickupImagePath,
      "completionImages": widget.transactionData['completionImages'],
      "cancellationImages": widget.transactionData['cancellationImages'],
      "cancelReason": widget.transactionData['cancelReason'],
      "pickedUp": true,
      "cancelled": widget.transactionData['cancelled'],
      "completed": true,
      "type": "Online",
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
                  CardButton(
                    text: widget.buttonText,
                    onPressed: () async {
                      if (_image != null) {
                        // Upload the image and get the pickupImagePath
                        String pickupImagePath = await _uploadImage(_image!);

                        // Call _updateTransaction with both arguments
                        _updateTransaction(
                            widget.transactionData['_id'], pickupImagePath);

                        if (widget.onPressed != null) {
                          widget.onPressed();
                        }
                      } else {
                        print('No image captured.');
                      }
                    },
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
