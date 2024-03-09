import 'package:driver_app/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        'https://lpg-api-06n8.onrender.com/api/v1/transactions?filter={"__t":"Delivery"}');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Deliveries',
          style: TextStyle(
            color: Colors.white,
          ),
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
        backgroundColor: const Color(0xFFA81616).withOpacity(0.9),
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
      body: transactions == null
          ? Center(child: CircularProgressIndicator())
          : CustomTabBar(transactions: transactions!),
    );
  }
}
