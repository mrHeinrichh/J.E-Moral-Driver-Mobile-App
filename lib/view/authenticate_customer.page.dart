import 'package:driver_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:driver_app/widgets/drop_off_card.dart';

class AuthenticatePage extends StatefulWidget {
  final Map<String, dynamic> transactionData;

  AuthenticatePage({required this.transactionData});

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

const TextStyle customTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Color(0xFF8D9DAE),
);

class _AuthenticatePageState extends State<AuthenticatePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isScanningSuccessful = false;

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
          title: const Text('Success!'),
          content: const Text('QR Code matches transaction ID.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
      backgroundColor: Color(0xFFe7e0e0),
      appBar: AppBar(
        title: const Text(
          'Authenticate Customer',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          // Add a refresh icon button
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
        backgroundColor: const Color(0xFFd41111),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        // Wrap your body with SingleChildScrollView
        child: Column(
          children: [
            DropOffCard(
              customTextStyle: customTextStyle,
              buttonText: 'Disregard this',
              onPressed: () {},
              btncolor: const Color(0xFF5E738A),
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
                  ? const Color(0xFF837E7E)
                  : const Color(0xFFBD2019),
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
                  ? const Color(0xFFBD2019)
                  : const Color(0xFF837E7E),
            ),
            SpareButton(
              text: 'CANCEL ORDER',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    File? capturedImage;

                    return AlertDialog(
                      title: const Text('Cancel Order'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);

                              if (pickedFile != null) {
                                capturedImage = File(pickedFile.path);
                              }
                            },
                            child: const Text('Capture Image'),
                          ),
                          TextField(
                            controller: cancelReasonController,
                            decoration: const InputDecoration(
                                labelText: 'Enter reason'),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            if (capturedImage != null) {
                              String cancelImagepath =
                                  await _uploadImage(capturedImage!);
                              String cancelReason = cancelReasonController.text;
                              _updateTransaction(transactionData['_id'],
                                  cancelImagepath, cancelReason);

                              Navigator.pop(context);
                              Navigator.pushNamed(context, homeRoute);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: const Color(0xFFBD2019),
            ),
          ],
        ),
      ),
    );
  }
}
