import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:driver_app/utils/productFormat.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;

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
              padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: _fetchedTransactionData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display fetched transaction data here
                        Text(
                          "Transaction id: ${_fetchedTransactionData!['_id']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Barangay: ${_fetchedTransactionData!['barangay']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Houst#/Lot/Blk: ${_fetchedTransactionData!['houseLotBlk']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Address: ${_fetchedTransactionData!['deliveryLocation']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Booker Name: ${_fetchedTransactionData!['name']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Booker Contact: ${_fetchedTransactionData!['contactNumber']}",
                          style: widget.customTextStyle,
                        ),

                        Text(
                          "Payment Method: ${_fetchedTransactionData!['paymentMethod']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Needs to be Assmbled?: ${_fetchedTransactionData!['assembly']}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Product List: ${ProductUtils.formatProductList(widget.transactionData['items'])}",
                          style: widget.customTextStyle,
                        ),
                        Text(
                          "Total Price: ${_fetchedTransactionData!['total']}",
                          style: widget.customTextStyle,
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
