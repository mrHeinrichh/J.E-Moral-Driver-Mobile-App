import 'package:driver_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ConfirmPickupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CONFIRM PICKUP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Have you picked up the following orders?'),
            const SizedBox(height: 10),
            const Text(
              'Order Number:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Background color of button
                    onPrimary: Color(0xFF5E738A), // Text color of button
                    side: BorderSide(
                        color: Color(0xFF5E738A),
                        width: 2), // Outer line color and width
                  ),
                  child: Text('No, I haven\'t.'),
                ),
                const SizedBox(width: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     Navigator.pushNamed(context, gpsRoute);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     primary: Colors.red, // Background color of button
                //     onPrimary: Colors.white, // Text color of button
                //     side: BorderSide(
                //         color: Colors.red,
                //         width: 2), // Outer line color and width
                //   ),
                //   child: Text('Yes, I have.'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CancelOrderDialog extends StatefulWidget {
  final TextField textField;

  CancelOrderDialog({
    required this.textField,
  });

  @override
  _CancelOrderDialogState createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reason for Cancelling Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: null,
              // decoration: InputDecoration(
              //   labelStyle: const TextStyle(fontSize: 15.0),
              //   hintText: 'State the reason\'s here...',
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(10.0),
              //   ),
              // ),
              decoration: InputDecoration(
                hintText: 'State the reason here...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Color(0xFF5E738A),
                    side: BorderSide(color: Color(0xFF5E738A), width: 2),
                  ),
                  child: Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.pushNamed(context, gpsRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _imageCaptured ? Colors.red : Color(0xFF5E738A),
                    onPrimary: Colors.white,
                    side: BorderSide(
                      color: _imageCaptured ? Colors.red : Color(0xFF5E738A),
                      width: 2,
                    ),
                  ),
                  child: Text('CONFIRM'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
