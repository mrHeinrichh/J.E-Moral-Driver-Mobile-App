import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:driver_app/utils/productFormat.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:driver_app/utils/DateTime.dart' as myUtils;
import 'package:intl/intl.dart';

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
  bool _googleMapsLaunched = false; // Add this flag

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

  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    try {
      if (!_googleMapsLaunched) {
        // Check the flag
        _googleMapsLaunched = true; // Set the flag to true
        await Future.delayed(Duration(seconds: 5));
        await MapsLauncher.launchCoordinates(latitude, longitude);

        // Launch was successful, call _updateTransaction
        await _updateTransaction(
          widget.transactionData['_id'],
          widget.transactionData['pickupImages'],
        );

        if (widget.onPressed != null) {
          widget.onPressed();
        }
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
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
        String pickupImagePaths = decodedResponse['data'][0]['path'];

        return pickupImagePaths; // Return the pickupImagePaths
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
      String transactionId, String pickupImagePaths) async {
    try {
      // Geocode the delivery location to get latitude and longitude
      String deliveryLocation = widget.transactionData['deliveryLocation'];
      List<double> coordinates = await _geocodeAddress(deliveryLocation);

      if (coordinates.isNotEmpty) {
        double deliveryLocationLatitude = coordinates[0];
        double deliveryLocationLongitude = coordinates[1];

        // Update the transaction data
        Map<String, dynamic> updateData = {
          "pickupImages": pickupImagePaths,
          "pickedUp": true,
          "__t": "Delivery",
          "status": "On Going",
        };

        // Patch request to update the transaction
        final String apiUrl =
            'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';
        final http.Response response = await http.patch(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updateData),
        );
        if (response.statusCode == 200) {
          print(pickupImagePaths);
          print('Transaction updated successfully');
          print('Response: ${response.body}');
          print(response.statusCode);

          // Launch Google Maps with the obtained coordinates
          await _launchGoogleMaps(
              deliveryLocationLatitude, deliveryLocationLongitude);

          if (widget.onPressed != null) {
            widget.onPressed();
          }
        } else {
          print(
              'Failed to update transaction. Status code: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      } else {
        print('Failed to geocode address.');
      }
    } catch (error) {
      print('Error updating transaction: $error');
    }
  }

  Future<List<double>> _geocodeAddress(String address) async {
    final apiKey = '397b2724db1f4de58cf440e681d855bc';
    final apiUrl = Uri.parse('https://api.geoapify.com/v1/geocode/search');
    final text = Uri.encodeComponent(address);

    final url = Uri(
      scheme: apiUrl.scheme,
      host: apiUrl.host,
      path: apiUrl.path,
      query: 'text=$text&apiKey=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['features'] != null && data['features'].isNotEmpty) {
        final location = data['features'][0]['geometry']['coordinates'];
        double latitude = location[1];
        double longitude = location[0];
        return [latitude, longitude];
      } else {
        print('Geocoding failed. No coordinates found.');
        return [];
      }
    } catch (error) {
      print('Error during geocoding: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Transaction Data: ${widget.transactionData['rider']}');

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
                          text: '${widget.transactionData['_id']}',
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
                          text: '${widget.transactionData['name']}',
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
                          text: '${widget.transactionData['contactNumber']}',
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
                          text: '${widget.transactionData['deliveryLocation']}',
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
                          text: '${widget.transactionData['houseLotBlk']}',
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
                              text: '${widget.transactionData['barangay']}',
                              style: TextStyle(color: Color(0xFF050404)),
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
                          text: '${widget.transactionData['paymentMethod']}',
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
                          text: widget.transactionData['assembly'] != null
                              ? (widget.transactionData['assembly']
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
                        if (widget.transactionData['items'] != null)
                          TextSpan(
                            text: (widget.transactionData['items'] as List)
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
                          text: '₱${widget.transactionData['total']}',
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
                          text: '${widget.transactionData['name']}',
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
                          text: '${widget.transactionData['contactNumber']}',
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
                          text: widget.transactionData['updatedAt'] != null
                              ? DateFormat('MMM d, y - h:mm a').format(
                                  DateTime.parse(
                                      widget.transactionData['updatedAt']),
                                )
                              : 'null',
                        ),
                      ],
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
                  CardButton(
                    text: widget.buttonText,
                    onPressed: () async {
                      if (_image != null) {
                        // Upload the image and get the pickupImagePaths
                        String pickupImagePaths = await _uploadImage(_image!);

                        // Call _updateTransaction with both arguments
                        _updateTransaction(
                            widget.transactionData['_id'], pickupImagePaths);

                        if (widget.onPressed != null) {
                          widget.onPressed();
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
