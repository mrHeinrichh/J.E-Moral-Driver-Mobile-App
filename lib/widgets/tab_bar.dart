import 'package:driver_app/widgets/card_button.dart';
import 'package:driver_app/widgets/custom_cards.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
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
                Column(
                  children: [
                    CustomCard(
                      customTextStyle: customTextStyle,
                      buttonText: 'Accept',
                      onPressed: () {},
                      btncolor: Color(0xFFBD2019),
                    ),
                    CustomCard(
                      customTextStyle: customTextStyle,
                      buttonText: 'Accept',
                      onPressed: () {},
                      btncolor: Color(0xFF5E738A),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CompletedCard(
                      customTextStyle: customTextStyle,
                    ),
                    CompletedCard(
                      customTextStyle: customTextStyle,
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
