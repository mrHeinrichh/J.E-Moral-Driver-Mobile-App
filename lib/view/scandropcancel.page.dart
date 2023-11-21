import 'package:driver_app/widgets/alert_dialog.dart';
import 'package:driver_app/widgets/completed_cards.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_cards.dart';
import '../widgets/card_button.dart';
import '../routes/app_routes.dart';

class ScanDropCancelPage extends StatelessWidget {
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
      body: Container(
        child: Column(
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
                    onPressed: () {
                      Navigator.pushNamed(context, scanDropRoute);
                    },
                    backgroundColor: Colors.red,
                  ),
                  spareButton(
                    text: 'DROP OFF',
                    onPressed: () {
                      // Navigator.pushNamed(context, deliveryRoute);
                    },
                    backgroundColor: Color(0xFF5E738A),
                  ),
                  spareButton(
                    text: 'CANCEL ORDER',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CancelOrderDialog(
                            textField: const TextField(),
                          );
                        },
                      );
                    },
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
