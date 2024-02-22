import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:driver_app/utils/productFormat.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;
import 'package:intl/intl.dart';

class DropOffCard extends StatefulWidget {
  final TextStyle customTextStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color btncolor;
  final Map<String, dynamic> transactionData;

  DropOffCard({
    required this.customTextStyle,
    required this.buttonText,
    required this.onPressed,
    required this.btncolor,
    required this.transactionData,
  });

  @override
  _DropOffCardState createState() => _DropOffCardState();
}

class _DropOffCardState extends State<DropOffCard> {
  Map<String, dynamic>? _fetchedTransactionData;
  late Timer _timer; // Timer for periodic fetching
  final Geolocator _geolocator = Geolocator();
  late double latitude;
  late double longitude;
  late LocationPermission locationPermission = LocationPermission.denied;

  late StreamSubscription<Position> _positionStream;
  bool _fetchSuccess = false; // Track if the data fetch is successful

  @override
  void initState() {
    super.initState();
    fetchTransactionData();
    // Set up a timer to fetch location every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_fetchSuccess) {
        // Only fetch location if data fetch is successful
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _positionStream.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    try {
      if (!mounted) {
        // Check if the widget is still mounted
        return;
      }
      // No need to check if locationPermission is null here
      // because it's initialized in the initState method

      // If locationPermission is denied, request permission
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          print('User denied permissions to access the device\'s location.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      print('Latitude: $latitude, Longitude: $longitude');
      _updateApi();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> fetchTransactionData() async {
    if (!mounted) {
      return;
    }

    final String transactionId = widget.transactionData['_id'];
    final String apiUrl =
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successful response, parse and set the data
        final responseData = json.decode(response.body);
        setState(() {
          _fetchedTransactionData = responseData['data'];
          _fetchSuccess = true; // Set the success flag to true
        });
      } else {
        // Handle error if the request was not successful
        print(
            'Failed to fetch transaction data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error during transaction data fetching: $error');
    }
  }

  Future<void> _updateApi() async {
    if (_fetchedTransactionData == null) {
      return;
    }

    final String transactionId = _fetchedTransactionData!['_id'];
    final apiUrl =
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        body: {
          'lat': latitude.toString(),
          'long': longitude.toString(),
          "__t": "Delivery"
        },
      );

      if (response.statusCode == 200) {
        fetchTransactionData();
        print(
            'Transaction Updated: Latitude: $latitude, Longitude: $longitude');
      } else {
        print(
            'Failed to update transaction. Status code: ${response.statusCode}');
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
              padding: EdgeInsets.fromLTRB(25, 25, 25, 15),
              child: _fetchedTransactionData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display fetched transaction data here
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Transaction id: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF050404),
                                ),
                              ),
                              TextSpan(
                                text: '${_fetchedTransactionData!['_id']}',
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
                                text: '${_fetchedTransactionData!['name']}',
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
                                text:
                                    '${_fetchedTransactionData!['contactNumber']}',
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
                                    '${_fetchedTransactionData!['deliveryLocation']}',
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
                                text:
                                    '${_fetchedTransactionData!['houseLotBlk']}',
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
                                    text:
                                        '${_fetchedTransactionData!['barangay']}',
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
                                text:
                                    '${_fetchedTransactionData!['paymentMethod']}',
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
                                text:
                                    _fetchedTransactionData!['assembly'] != null
                                        ? (_fetchedTransactionData!['assembly']
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
                              if (_fetchedTransactionData!['items'] != null)
                                TextSpan(
                                  text: (_fetchedTransactionData!['items']
                                          as List)
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
                                text: '₱${_fetchedTransactionData!['total']}',
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
                                text: '${_fetchedTransactionData!['name']}',
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
                                text:
                                    '${_fetchedTransactionData!['contactNumber']}',
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
                                text: _fetchedTransactionData!['updatedAt'] !=
                                        null
                                    ? DateFormat('MMM d, y - h:mm a').format(
                                        DateTime.parse(_fetchedTransactionData![
                                            'updatedAt']),
                                      )
                                    : 'null',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
