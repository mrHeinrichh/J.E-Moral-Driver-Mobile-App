import 'dart:async';
import 'dart:convert';
import 'package:driver_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DropOffCard extends StatefulWidget {
  final Map<String, dynamic> transactionData;

  DropOffCard({
    required this.transactionData,
  });

  @override
  _DropOffCardState createState() => _DropOffCardState();
}

class _DropOffCardState extends State<DropOffCard> {
  Map<String, dynamic>? _fetchedTransactionData;
  late Timer _timer;
  final Geolocator _geolocator = Geolocator();
  late double latitude;
  late double longitude;
  late LocationPermission locationPermission = LocationPermission.denied;

  late StreamSubscription<Position> _positionStream;
  bool _fetchSuccess = false;

  @override
  void initState() {
    super.initState();
    fetchTransactionData();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_fetchSuccess) {
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
        return;
      }

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
        final responseData = json.decode(response.body);
        setState(() {
          _fetchedTransactionData = responseData['data'];
          _fetchSuccess = true;
        });
      } else {
        print(
            'Failed to fetch transaction data. Status code: ${response.statusCode}');
      }
    } catch (error) {
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
                child: _fetchedTransactionData == null
                    ? Center(
                        child: LoadingAnimationWidget.flickr(
                          leftDotColor:
                              const Color(0xFF050404).withOpacity(0.8),
                          rightDotColor:
                              const Color(0xFFd41111).withOpacity(0.8),
                          size: 40,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const BodyMedium(
                                  text: "Transaction ID:",
                                ),
                                BodyMedium(
                                  text: _fetchedTransactionData!['_id'],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          BodyMediumText(
                            text: _fetchedTransactionData!
                                    .containsKey('discountIdImage')
                                ? 'Ordered by: Customer'
                                : _fetchedTransactionData!['discounted'] ==
                                        false
                                    ? 'Ordered by: Retailer'
                                    : '',
                          ),
                          if (widget.transactionData
                              .containsKey('discountIdImage'))
                            BodyMediumText(
                              text:
                                  _fetchedTransactionData!['discountIdImage'] !=
                                              null &&
                                          _fetchedTransactionData![
                                                  'discountIdImage'] !=
                                              ""
                                      ? 'Discounted: Yes'
                                      : 'Discounted: No',
                            ),
                          const SizedBox(height: 5),
                          BodyMediumText(
                              text:
                                  "Order Status: ${_fetchedTransactionData!['status']}"),
                          const Divider(),
                          const Center(
                            child: BodyMedium(text: "Receiver Infomation"),
                          ),
                          const SizedBox(height: 5),
                          BodyMediumText(
                              text:
                                  "Name: ${_fetchedTransactionData!['name']}"),
                          BodyMediumText(
                              text:
                                  "Mobile Number: ${_fetchedTransactionData!['contactNumber']}"),
                          BodyMediumOver(
                              text:
                                  "House Number: ${_fetchedTransactionData!['houseLotBlk']}"),
                          BodyMediumText(
                              text:
                                  "Barangay: ${_fetchedTransactionData!['barangay']}"),
                          BodyMediumOver(
                              text:
                                  "Delivery Location: ${_fetchedTransactionData!['deliveryLocation']}"),
                          const Divider(),
                          BodyMediumText(
                              text:
                                  'Payment Method: ${_fetchedTransactionData!['paymentMethod'] == 'COD' ? 'Cash on Delivery' : _fetchedTransactionData!['paymentMethod']}'),
                          if (_fetchedTransactionData!
                              .containsKey('discountIdImage'))
                            BodyMediumText(
                              text:
                                  'Assemble Option: ${_fetchedTransactionData!['assembly'] ? 'Yes' : 'No'}',
                            ),
                          BodyMediumOver(
                            text:
                                'Delivery Date and Time: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(_fetchedTransactionData!['deliveryDate']))}',
                          ),
                          const Divider(),
                          if (_fetchedTransactionData!
                              .containsKey('discountIdImage'))
                            BodyMediumOver(
                              text:
                                  'Items: ${_fetchedTransactionData!['items']!.map((item) {
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
                          if (!_fetchedTransactionData!
                                  .containsKey('discountIdImage') &&
                              _fetchedTransactionData!['discounted'] == false)
                            BodyMediumOver(
                              text:
                                  'Items: ${_fetchedTransactionData!['items']!.map((item) {
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
                                'Total: ₱${NumberFormat.decimalPattern().format(double.parse((_fetchedTransactionData!['total']).toStringAsFixed(2)))}',
                          ),
                        ],
                      )),
          ),
        ],
      ),
    );
  }
}
