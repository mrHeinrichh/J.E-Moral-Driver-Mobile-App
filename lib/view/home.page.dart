import 'package:driver_app/widgets/drawer.dart';
import 'package:driver_app/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('data')) {
        // Assuming transactions are stored under the 'data' key
        final List<dynamic> transactionsData = jsonResponse['data'];
        transactions = transactionsData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Invalid response format: Missing "data" key');
      }
    } else {
      throw Exception('Failed to load transactions');
    }

    setState(() {}); // Update the UI with the fetched data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe7e0e0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Deliveries',
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
              // Call the fetchData method to refresh data
              fetchData();
            },
          ),
        ],
        // backgroundColor: Colors.white,
        backgroundColor: const Color(0xFFd41111),

        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: CustomDrawer(),
      body: transactions == null
          ? Center(child: CircularProgressIndicator())
          : CustomTabBar(transactions: transactions!),
    );
  }
}
