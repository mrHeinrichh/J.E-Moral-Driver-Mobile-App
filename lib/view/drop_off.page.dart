import 'dart:convert';
import 'dart:io';
import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/view/user_provider.dart';
import 'package:driver_app/widgets/custom_text.dart';
import 'package:driver_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class DropOffPage extends StatefulWidget {
  final VoidCallback? onPressed;

  DropOffPage({Key? key, this.onPressed}) : super(key: key);

  @override
  _DropOffPageState createState() => _DropOffPageState();
}

class _DropOffPageState extends State<DropOffPage> {
  File? _image;
  bool _imageCaptured = false;
  String? selectedPayment;
  final formKey = GlobalKey<FormState>();
  bool showDriverInformation = false;

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

          String pickupImagePath = decodedResponse['data'][0]['path'];

          return pickupImagePath;
        } else {
          print('Upload failed with status ${response.statusCode}');
          return '';
        }
      } catch (error) {
        print('Error uploading image: $error');
        return '';
      }
    }

    Future<void> _showSuccessDialog() async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text(
                'Success!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: const Text(
              "Have you dropped off the following delivery?",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF050404).withOpacity(0.8),
                ),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, homeRoute);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF050404).withOpacity(0.9),
                ),
                child: const Text(
                  "Yes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        "completionImages": pickupImagePath,
      };

      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        updateData["paymentMethod"] = paymentMethod;
      }

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

    Future<Map<String, dynamic>> fetchRider(String riderId) async {
      final response = await http.get(
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"_id":"$riderId","__t":"Rider"}',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final riderData = data['data'][0] as Map<String, dynamic>;
          return riderData;
        } else {
          throw Exception('Rider not found');
        }
      } else {
        throw Exception('Failed to load data from the API');
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
        elevation: 1,
        title: const Text(
          'Drop Off Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () async {
                  String? userId = userProvider.userId;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: LoadingAnimationWidget.flickr(
                          leftDotColor:
                              const Color(0xFF050404).withOpacity(0.8),
                          rightDotColor:
                              const Color(0xFFd41111).withOpacity(0.8),
                          size: 40,
                        ),
                      );
                    },
                  );
                  await fetchRider(userId!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pickup Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF050404).withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
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
                                    text: transactionData['_id'],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            BodyMediumText(
                              text:
                                  transactionData.containsKey('discountIdImage')
                                      ? 'Ordered by: Customer'
                                      : transactionData['discounted'] == false
                                          ? 'Ordered by: Retailer'
                                          : '',
                            ),
                            if (transactionData.containsKey('discountIdImage'))
                              BodyMediumText(
                                text: transactionData['discountIdImage'] !=
                                            null &&
                                        transactionData['discountIdImage'] != ""
                                    ? 'Discounted: Yes'
                                    : 'Discounted: No',
                              ),
                            const SizedBox(height: 5),
                            BodyMediumText(
                                text:
                                    "Order Status: ${transactionData['status']}"),
                            const Divider(),
                            const Center(
                              child: BodyMedium(text: "Receiver Infomation"),
                            ),
                            const SizedBox(height: 5),
                            BodyMediumText(
                                text: "Name: ${transactionData['name']}"),
                            BodyMediumText(
                                text:
                                    "Mobile Number: ${transactionData['contactNumber']}"),
                            BodyMediumOver(
                                text:
                                    "House Number: ${transactionData['houseLotBlk']}"),
                            BodyMediumText(
                                text:
                                    "Barangay: ${transactionData['barangay']}"),
                            BodyMediumOver(
                                text:
                                    "Delivery Location: ${transactionData['deliveryLocation']}"),
                            const Divider(),
                            BodyMediumText(
                                text:
                                    'Payment Method: ${transactionData['paymentMethod'] == 'COD' ? 'Cash on Delivery' : transactionData['paymentMethod']}'),
                            if (transactionData.containsKey('discountIdImage'))
                              BodyMediumText(
                                text:
                                    'Assemble Option: ${transactionData['assembly'] ? 'Yes' : 'No'}',
                              ),
                            BodyMediumOver(
                              text:
                                  'Delivery Date and Time: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(transactionData['deliveryDate']))}',
                            ),
                            const Divider(),
                            if (transactionData.containsKey('discountIdImage'))
                              BodyMediumOver(
                                text:
                                    'Items: ${transactionData['items']!.map((item) {
                                  if (item is Map<String, dynamic> &&
                                      item.containsKey('name') &&
                                      item.containsKey('quantity') &&
                                      item.containsKey('customerPrice')) {
                                    final itemName = item['name'];
                                    final quantity = item['quantity'];
                                    final price = NumberFormat.decimalPattern()
                                        .format(double.parse(
                                            (item['customerPrice'])
                                                .toStringAsFixed(2)));

                                    return '$itemName ₱$price (x$quantity)';
                                  }
                                }).join(', ')}',
                              ),
                            if (!transactionData
                                    .containsKey('discountIdImage') &&
                                transactionData['discounted'] == false)
                              BodyMediumOver(
                                text:
                                    'Items: ${transactionData['items']!.map((item) {
                                  if (item is Map<String, dynamic> &&
                                      item.containsKey('name') &&
                                      item.containsKey('quantity') &&
                                      item.containsKey('retailerPrice')) {
                                    final itemName = item['name'];
                                    final quantity = item['quantity'];
                                    final price = NumberFormat.decimalPattern()
                                        .format(double.parse(
                                            (item['retailerPrice'])
                                                .toStringAsFixed(2)));

                                    return '$itemName ₱$price (x$quantity)';
                                  }
                                }).join(', ')}',
                              ),
                            BodyMediumText(
                              text:
                                  'Total: ₱${NumberFormat.decimalPattern().format(double.parse((transactionData['total']).toStringAsFixed(2)))}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Card(
                    color: Colors.white,
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
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
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 100,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: const Color(
                                                                0xFF050404)
                                                            .withOpacity(0.6),
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
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gcash Payment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF050404).withOpacity(0.9),
                    ),
                  ),
                  Switch(
                    value: showDriverInformation,
                    onChanged: (value) {
                      setState(() {
                        showDriverInformation = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            if (showDriverInformation)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 5, 28, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Gcash Information",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF050404).withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        String? userId = userProvider.userId;
                        return FutureBuilder<Map<String, dynamic>>(
                          future: fetchRider(userId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.flickr(
                                  leftDotColor:
                                      const Color(0xFF050404).withOpacity(0.8),
                                  rightDotColor:
                                      const Color(0xFFd41111).withOpacity(0.8),
                                  size: 40,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              Map<String, dynamic> riderData = snapshot.data!;
                              return SizedBox(
                                width: 320,
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25, 10, 25, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImageView(
                                                      imageUrl:
                                                          riderData['gcashQr'],
                                                      onClose: () =>
                                                          Navigator.of(context)
                                                              .pop()),
                                            ));
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              width: double.infinity,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    riderData['gcashQr'] ?? '',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        BodyMediumOver(
                                          text:
                                              "Gcash Name: Julina Marie F. Bibangco",
                                        ),
                                        BodyMediumText(
                                          text: "GCash Number: 09193599448",
                                        ),
                                        DropdownButtonFormField(
                                          value: selectedPayment,
                                          decoration: InputDecoration(
                                            labelText: 'Mode of Payment:',
                                            labelStyle: TextStyle(
                                              color: const Color(0xFF050404)
                                                  .withOpacity(0.9),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color(0xFF050404)
                                                    .withOpacity(0.9),
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color(0xFF050404)
                                                    .withOpacity(0.9),
                                              ),
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'COD',
                                              child: Text('Cash on Delivery'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'GCASH',
                                              child: Text('GCASH'),
                                            ),
                                          ],
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedPayment = newValue;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please Select the Mode of Payment";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
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
                        if (formKey.currentState!.validate()) {
                          String pickupImagePath = await _uploadImage(_image!);
                          _updateTransaction(
                            transactionData['_id'],
                            pickupImagePath,
                            selectedPayment ?? '',
                          );

                          _showSuccessDialog();

                          if (widget.onPressed != null) {
                            widget.onPressed!();
                          }
                        }
                      } else {
                        showCustomOverlay(context, 'Please Upload the Payment');
                      }
                    },
                    backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
                    color: Colors.white,
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
