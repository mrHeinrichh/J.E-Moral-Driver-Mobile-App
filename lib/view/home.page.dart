import 'package:driver_app/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>>? transactions;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
      'https://lpg-api-06n8.onrender.com/api/v1/transactions?filter={"__t":"Delivery"}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('data')) {
        final List<dynamic> transactionsData = jsonResponse['data'];
        setState(() {
          transactions = transactionsData.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Invalid response format: Missing "data" key');
      }
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
        elevation: 1,
        title: const Text(
          'Deliveries',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              fetchData();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.power_settings_new_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Center(
                    child: Text(
                      'Logout Confirmation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF050404).withOpacity(0.8),
                      ),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _logout(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFFd41111).withOpacity(0.8),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: transactions == null
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            )
          : CustomTabBar(transactions: transactions!),
    );
  }
}

void _logout(BuildContext context) {
  Navigator.pushNamed(context, '/login');
}
