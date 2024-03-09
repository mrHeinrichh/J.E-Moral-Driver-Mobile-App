import 'dart:async';
import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/custom_button.dart';
import 'package:driver_app/widgets/drop_off_card.dart';

class AuthenticatePage extends StatefulWidget {
  final Map<String, dynamic> transactionData;

  AuthenticatePage({required this.transactionData});

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isScanningSuccessful = false;
  File? _image;
  bool isImageSelected = false;
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

  Future<void> _startQRScanner(
      BuildContext context, Map<String, dynamic> transactionData) async {
    print('Transaction ID: ${transactionData['_id']}');
    print('Transaction ID: ${transactionData['pickupImages']}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan QR Code'),
          content: SizedBox(
            width: double.infinity,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  if (scanData != null && scanData.code != null) {
                    String scannedCode = scanData.code ?? '';
                    scannedCode = scannedCode.trim();
                    print('Scanned QR Code: $scannedCode');

                    String transactionId = transactionData['_id']?.trim() ?? '';
                    print('Transaction ID: $transactionId');

                    if (scannedCode == transactionId) {
                      Navigator.pop(context);
                      _showSuccessDialog(context);
                      setState(() {
                        isScanningSuccessful = true;
                      });
                    } else {
                      print('QR Code does not match transaction ID.');
                      setState(() {
                        isScanningSuccessful = false;
                      });
                    }
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
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
            'QR Code matches transaction ID.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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

        String cancelImagepath = decodedResponse['data'][0]['path'];

        return cancelImagepath;
      } else {
        print('Upload failed with status ${response.statusCode}');
        return '';
      }
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> _updateTransaction(
      String transactionId, String cancelImagepath, String cancelReason) async {
    final String apiUrl =
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId/cancel';

    Map<String, dynamic> updateData = {
      "cancellationImages": cancelImagepath,
      "cancelReason": cancelReason,
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
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Map<String, dynamic> transactionData = args['transactionData'];
    final TextEditingController cancelReasonController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
        elevation: 1,
        title: const Text(
          'Authenticate Customer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropOffCard(
              transactionData: transactionData,
            ),
            SpareButton(
              text: 'AUTHENTICATE CUSTOMER',
              onPressed: isScanningSuccessful
                  ? null
                  : () {
                      _startQRScanner(context, transactionData);
                    } as VoidCallback?,
              backgroundColor: isScanningSuccessful
                  ? const Color(0xFF050404).withOpacity(0.2)
                  : const Color(0xFFA81616).withOpacity(0.9),
              color: isScanningSuccessful
                  ? const Color(0xFF050404).withOpacity(0.5)
                  : Colors.white,
            ),
            SpareButton(
              text: 'DROP OFF',
              onPressed: isScanningSuccessful
                  ? () {
                      Navigator.pushNamed(
                        context,
                        dropOffRoute,
                        arguments: {'transactionData': transactionData},
                      );
                    }
                  : null,
              backgroundColor: isScanningSuccessful
                  ? const Color(0xFFA81616).withOpacity(0.9)
                  : const Color(0xFFA81616).withOpacity(0.9),
              color: isScanningSuccessful
                  ? Colors.white
                  : const Color(0xFF050404).withOpacity(0.5),
            ),
            SpareButton(
              text: 'CANCEL ORDER',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final formKey = GlobalKey<FormState>();

                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Cancel Order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                                leading:
                                                    const Icon(Icons.camera),
                                                title:
                                                    const Text('Take a Photo'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _getImageFromCamera();
                                                  isImageSelected = true;
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.photo_library),
                                                title: const Text(
                                                    'Choose from Gallery'),
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
                                          width: 300,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF050404)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: snapshot.data != null
                                                ? Image.file(
                                                    snapshot.data!,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(
                                                    Icons.camera_alt,
                                                    color:
                                                        const Color(0xFF050404)
                                                            .withOpacity(0.6),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              EditTextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: cancelReasonController,
                                labelText: "Reason",
                                hintText: 'Enter the Reason',
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Enter the Reason';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF050404).withOpacity(0.7),
                          ),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (!isImageSelected) {
                              showCustomOverlay(context,
                                  'Please Upload a Cancellation Image');
                            } else {
                              if (formKey.currentState!.validate()) {
                                String cancelImagepath = "";

                                if (_image != null) {
                                  var uploadResponse =
                                      await _uploadImage(_image!);
                                  if (uploadResponse != null) {
                                    cancelImagepath = uploadResponse;
                                  }
                                }

                                String cancelReason =
                                    cancelReasonController.text;

                                _updateTransaction(
                                  transactionData['_id'],
                                  cancelImagepath,
                                  cancelReason,
                                );

                                Navigator.pop(context);
                                Navigator.pushNamed(context, homeRoute);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF050404).withOpacity(0.9),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
              color: Colors.white,
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
