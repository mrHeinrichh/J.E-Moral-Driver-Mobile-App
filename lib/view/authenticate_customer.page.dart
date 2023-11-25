import 'dart:convert';
import 'dart:io';

import 'package:driver_app/widgets/card_button.dart';
import 'package:driver_app/widgets/drop_off_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AuthenticatePage extends StatelessWidget {
  final TextStyle customTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

  final Map<String, dynamic> transactionData;

  AuthenticatePage({required this.transactionData});

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
        String cancelImagepath = decodedResponse['data'][0]['path'];

        return cancelImagepath; // Return the cancelImagepath
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
    String transactionId, String cancelImagepath, String cancelReason) async {
     final String apiUrl =
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';

    Map<String, dynamic> updateData = {
      "cancellationImages": cancelImagepath,
      "cancelReason": cancelReason,
      "completed": false,
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
final TextEditingController cancelReasonController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Authenticate Customer',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            DropOffCard(
              customTextStyle: customTextStyle,
              buttonText: 'Authenticate Customer',
              onPressed: () {
                // Handle the onPressed action in AuthenticatePage
                // You can use the transactionData here
              },
              btncolor: Color(0xFF5E738A),
              transactionData: transactionData,
            ),
            spareButton(
              text: 'AUTHENTICATE CUSTOMER',
              onPressed: () {},
              backgroundColor: Color(0xFFBD2019),
            ),
            spareButton(
              text: 'DROP OFF',
              onPressed: () {},
              backgroundColor: Color(0xFF837E7E),
            ),
            spareButton(
              text: 'CANCEL ORDER',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    File? capturedImage;

                    return AlertDialog(
                      title: Text('Cancel Order'),
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
                            child: Text('Capture Image'),
                          ),
                          TextField(
                            controller: cancelReasonController,
                            decoration:
                                InputDecoration(labelText: 'Enter reason'),
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
                           _updateTransaction(transactionData['_id'], cancelImagepath, cancelReason);

                              Navigator.pop(context);
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: Color(0xFFBD2019),
            ),
          ],
        ),
      ),
    );
  }
}
