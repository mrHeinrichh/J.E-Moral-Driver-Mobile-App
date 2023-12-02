import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:driver_app/widgets/completed_cards.dart';
import 'package:driver_app/widgets/custom_cards.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomTabBar extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  CustomTabBar({required this.transactions});

  final TextStyle customTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );
  Future<void> updateTransactionStatus(String transactionId) async {
    final Uri url = Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId');
    final Map<String, dynamic> requestBody = {
      'pickedUp': true,
      "rider": '$transactionId'
    };

    final response = await http.patch(
      url,
      body: json.encode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Transaction status updated successfully');
      print(response.body);
      print(response.statusCode);
    } else {
      print('Failed to update transaction status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFCB8686),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TabBar(
                isScrollable: false,
                tabs: [
                  Container(
                    height: 30,
                    width: 90.0,
                    child: const Tab(
                      child: Text(
                        'Pending',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 90.0,
                    child: const Tab(
                      child: Text(
                        'Completed',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 90.0,
                    child: const Tab(
                      child: Text(
                        'Failed',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
                indicator: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: const Color(0xFFBD2019),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var transaction in transactions)
                        CustomCard(
                          customTextStyle: customTextStyle,
                          buttonText: 'Accept',
                          onPressed: () async {
                            // Retrieve the transaction ID
                            String? transactionId = transaction['_id'];

                            if (transactionId != null) {
                              // Call the function to update the transaction status
                              await updateTransactionStatus(transactionId);

                              // Optionally, you can update the local state
                              // to reflect the change (set "pickedUp" to true)

                              // Navigate to the PickUpPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickUpPage(
                                    transactionData: transaction,
                                  ),
                                ),
                              );
                            }
                          },
                          btncolor: Color(0xFFBD2019),
                          transactionData: transaction,
                        ),
                    ],
                  ),
                ),
                ListView(
                  children: [
                    for (var transaction in transactions.where(
                        (transaction) => transaction['completed'] == true))
                      CompletedCard(
                        customTextStyle: customTextStyle,
                        transactionData: transaction,
                      ),
                  ],
                ),
                Center(child: Text('Failed Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
