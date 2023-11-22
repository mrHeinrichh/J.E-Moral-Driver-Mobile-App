import 'package:driver_app/view/pickup.page.dart';
import 'package:driver_app/widgets/card_button.dart';
import 'package:driver_app/widgets/completed_cards.dart';
import 'package:driver_app/widgets/custom_cards.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  CustomTabBar({required this.transactions});

  final TextStyle customTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

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
                isScrollable: true,
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PickUpPage(
                                  transactionData:
                                      transaction, // Pass transaction data to PickUpPage
                                ),
                              ),
                            );
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
