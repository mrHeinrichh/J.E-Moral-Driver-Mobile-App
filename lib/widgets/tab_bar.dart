import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/view/user_provider.dart';
import 'package:driver_app/widgets/completed_card.dart';
import 'package:driver_app/widgets/pending_order_card.dart';
import 'package:driver_app/widgets/on_going_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CustomTabBar extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  CustomTabBar({required this.transactions});

  Future<void> updateTransactionStatus(
      String transactionId, String userId) async {
    final Uri url = Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId/accept');
    final Map<String, dynamic> requestBody = {
      'rider': userId,
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
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      String? userId = userProvider.userId;
      print('User ID: $userId');
      return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFA81616).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TabBar(
                  isScrollable: false,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                          'On Going',
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
                  ],
                  indicator: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFFA81616).withOpacity(0.8),
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
                          PendingOrderCard(
                            buttonText: 'Accept',
                            onPressed: () async {
                              String? transactionId = transaction['_id'];

                              if (transactionId != null) {
                                await updateTransactionStatus(
                                    transactionId, userId!);

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
                            btncolor: const Color(0xFFA81616).withOpacity(0.8),
                            transactionData: transaction,
                          ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var transaction in transactions)
                          OnGoingCard(
                            buttonText: 'Retry',
                            onPressed: () async {
                              String? transactionId = transaction['_id'];

                              if (transactionId != null) {
                                await updateTransactionStatus(
                                    transactionId, userId!);

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
                            btncolor: const Color(0xFFA81616).withOpacity(0.8),
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
                          transactionData: transaction,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
