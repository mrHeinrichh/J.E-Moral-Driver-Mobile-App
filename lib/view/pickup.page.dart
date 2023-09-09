import 'package:driver_app/widgets/custom_cards.dart';
import 'package:flutter/material.dart';

class PickUpPage extends StatelessWidget {
  final TextStyle customTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8D9DAE),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pick Up Deliveries',
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
      body: Container(
        child: Column(
          children: [
            PickedUpCard(
              customTextStyle: customTextStyle,
              buttonText: 'PICKED UP',
              onPressed: () {},
              btncolor: Color(0xFF5E738A),
            ),
          ],
        ),
      ),
    );
  }
}
