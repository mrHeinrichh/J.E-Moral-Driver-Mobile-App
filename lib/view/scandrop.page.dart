import 'package:flutter/material.dart';
import '../widgets/custom_cards.dart';
import '../widgets/card_button.dart';
import '../routes/app_routes.dart';

class ScanDropPage extends StatelessWidget {
  final TextStyle customTextStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deliveries',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: DeliveryDetailsCard(
              customTextStyle: customTextStyle,
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                spareButton(
                  text: 'AUTHENTICATE CUSTOMER',
                  onPressed: () {},
                  backgroundColor: const Color(0xFF5E738A),
                ),
                spareButton(
                  text: 'DROP OFF',
                  onPressed: () {
                      Navigator.pushNamed(context, paymentRoute);
                  },
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
