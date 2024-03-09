import 'dart:convert';
import 'dart:io';
import 'package:driver_app/widgets/custom_button.dart';
import 'package:driver_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:intl/intl.dart';

class PickedUpCard extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color btncolor;
  final Map<String, dynamic> transactionData;

  PickedUpCard({
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
  bool isImageSelected = false;
  bool _googleMapsLaunched = false;
  final _imageStreamController = StreamController<File?>.broadcast();

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _imageStreamController.sink.add(imageFile);

      setState(() {
        _image = imageFile;
        isImageSelected = true;
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _imageStreamController.sink.add(imageFile);

      setState(() {
        _image = imageFile;
        isImageSelected = true;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      isImageSelected = false;
    });
  }

  Future<Map<String, dynamic>?> _uploadImage(File imageFile) async {
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
        final responseBody = await response.stream.bytesToString();
        print("Image uploaded successfully: $responseBody");

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          if (data.isNotEmpty && data[0].containsKey('path')) {
            final ImageUrl = data[0]['path'];
            print("Image URL: $ImageUrl");
            return {'url': ImageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print("Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> _updateTransaction(String transactionId) async {
    try {
      String deliveryLocation = widget.transactionData['deliveryLocation'];
      List<double> coordinates = await _geocodeAddress(deliveryLocation);

      if (coordinates.isNotEmpty) {
        double deliveryLocationLatitude = coordinates[0];
        double deliveryLocationLongitude = coordinates[1];

        String pickupImagePath = "";

        if (_image != null) {
          var uploadResponse = await _uploadImage(_image!);
          if (uploadResponse != null) {
            pickupImagePath = uploadResponse["url"];
          }
        }

        Map<String, dynamic> updateData = {
          "pickupImages": pickupImagePath,
          "pickedUp": true,
          "__t": "Delivery",
          "status": "On Going",
        };

        final String apiUrl =
            'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';
        final http.Response response = await http.patch(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updateData),
        );
        if (response.statusCode == 200) {
          print(response.body);
          print(response.body);

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
    const apiKey = '397b2724db1f4de58cf440e681d855bc';
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

  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    try {
      if (!_googleMapsLaunched) {
        _googleMapsLaunched = true;
        await Future.delayed(const Duration(seconds: 5));
        await MapsLauncher.launchCoordinates(latitude, longitude);

        await _updateTransaction(widget.transactionData['_id']);

        if (widget.onPressed != null) {
          widget.onPressed();
        }
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const BodyMedium(
                            text: "Transaction ID:",
                          ),
                          BodyMedium(
                            text: widget.transactionData['_id'],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    BodyMediumText(
                      text:
                          widget.transactionData.containsKey('discountIdImage')
                              ? 'Ordered by: Customer'
                              : widget.transactionData['discounted'] == false
                                  ? 'Ordered by: Retailer'
                                  : '',
                    ),
                    if (widget.transactionData.containsKey('discountIdImage'))
                      BodyMediumText(
                        text: widget.transactionData['discountIdImage'] !=
                                    null &&
                                widget.transactionData['discountIdImage'] != ""
                            ? 'Discounted: Yes'
                            : 'Discounted: No',
                      ),
                    const SizedBox(height: 5),
                    BodyMediumText(
                        text:
                            "Order Status: ${widget.transactionData['status']}"),
                    const Divider(),
                    const Center(
                      child: BodyMedium(text: "Receiver Infomation"),
                    ),
                    const SizedBox(height: 5),
                    BodyMediumText(
                        text: "Name: ${widget.transactionData['name']}"),
                    BodyMediumText(
                        text:
                            "Mobile Number: ${widget.transactionData['contactNumber']}"),
                    BodyMediumOver(
                        text:
                            "House Number: ${widget.transactionData['houseLotBlk']}"),
                    BodyMediumText(
                        text:
                            "Barangay: ${widget.transactionData['barangay']}"),
                    BodyMediumOver(
                        text:
                            "Delivery Location: ${widget.transactionData['deliveryLocation']}"),
                    const Divider(),
                    BodyMediumText(
                        text:
                            'Payment Method: ${widget.transactionData['paymentMethod'] == 'COD' ? 'Cash on Delivery' : widget.transactionData['paymentMethod']}'),
                    if (widget.transactionData.containsKey('discountIdImage'))
                      BodyMediumText(
                        text:
                            'Assemble Option: ${widget.transactionData['assembly'] ? 'Yes' : 'No'}',
                      ),
                    BodyMediumOver(
                      text:
                          'Delivery Date and Time: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(widget.transactionData['deliveryDate']))}',
                    ),
                    const Divider(),
                    if (widget.transactionData.containsKey('discountIdImage'))
                      BodyMediumOver(
                        text:
                            'Items: ${widget.transactionData['items']!.map((item) {
                          if (item is Map<String, dynamic> &&
                              item.containsKey('name') &&
                              item.containsKey('quantity') &&
                              item.containsKey('customerPrice')) {
                            final itemName = item['name'];
                            final quantity = item['quantity'];
                            final price = NumberFormat.decimalPattern().format(
                                double.parse((item['customerPrice'])
                                    .toStringAsFixed(2)));

                            return '$itemName (₱$price x $quantity)';
                          }
                        }).join(', ')}',
                      ),
                    if (!widget.transactionData
                            .containsKey('discountIdImage') &&
                        widget.transactionData['discounted'] == false)
                      BodyMediumOver(
                        text:
                            'Items: ${widget.transactionData['items']!.map((item) {
                          if (item is Map<String, dynamic> &&
                              item.containsKey('name') &&
                              item.containsKey('quantity') &&
                              item.containsKey('retailerPrice')) {
                            final itemName = item['name'];
                            final quantity = item['quantity'];
                            final price = NumberFormat.decimalPattern().format(
                                double.parse((item['retailerPrice'])
                                    .toStringAsFixed(2)));

                            return '$itemName (₱$price x $quantity)';
                          }
                        }).join(', ')}',
                      ),
                    BodyMediumText(
                      text:
                          'Total: ₱${NumberFormat.decimalPattern().format(double.parse((widget.transactionData['total']).toStringAsFixed(2)))}',
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<File?>(
                      stream: _imageStreamController.stream,
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.camera),
                                      title: const Text('Take a Photo'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _getImageFromCamera();
                                        isImageSelected = true;
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _getImageFromGallery();
                                        isImageSelected = true;
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF050404).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: snapshot.data != null
                                      ? Image.file(
                                          snapshot.data!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          color: const Color(0xFF050404)
                                              .withOpacity(0.6),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    CardButton(
                      text: widget.buttonText,
                      onPressed: () async {
                        if (!isImageSelected) {
                          showCustomOverlay(
                              context, 'Please Upload a Pick-up Image');
                        } else {
                          _updateTransaction(widget.transactionData['_id']);

                          if (widget.onPressed != null) {
                            widget.onPressed();
                          }
                        }
                      },
                      color: isImageSelected
                          ? const Color(0xFFA81616).withOpacity(0.9)
                          : widget.btncolor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomOverlay(BuildContext context, String message) {
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.5,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFd41111).withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  Overlay.of(context)!.insert(overlay);

  Future.delayed(const Duration(seconds: 2), () {
    overlay.remove();
  });
}
