import 'package:driver_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedCard extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  CompletedCard({
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    String status = transactionData['status'] ?? "Completed";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const BodyMedium(
                          text: "Transaction ID:",
                        ),
                        BodyMedium(
                          text: transactionData['_id'],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  if (!transactionData.containsKey('discountIdImage') &&
                      transactionData['discounted'] == false)
                    const BodyMediumText(text: "Ordered by: Retailer"),
                  if (transactionData['discountIdImage'] != null &&
                      transactionData['discountIdImage'] != "")
                    const Column(
                      children: [
                        BodyMediumText(text: "Ordered by: Customer"),
                        BodyMediumText(text: "Discounted: Yes"),
                      ],
                    ),
                  BodyMediumText(
                      text: "Order Status: ${transactionData['status']}"),
                  const Divider(),
                  const Center(
                    child: BodyMedium(text: "Receiver Infomation"),
                  ),
                  const SizedBox(height: 5),
                  BodyMediumText(text: "Name: ${transactionData['name']}"),
                  BodyMediumText(
                      text:
                          "Mobile Number: ${transactionData['contactNumber']}"),
                  BodyMediumOver(
                      text: "House Number: ${transactionData['houseLotBlk']}"),
                  BodyMediumText(
                      text: "Barangay: ${transactionData['barangay']}"),
                  BodyMediumOver(
                      text:
                          "Delivery Location: ${transactionData['deliveryLocation']}"),
                  const Divider(),
                  BodyMediumText(
                      text:
                          'Payment Method: ${transactionData['paymentMethod'] == 'COD' ? 'Cash on Delivery' : transactionData['paymentMethod']}'),
                  if (transactionData.containsKey('discountIdImage'))
                    BodyMediumText(
                      text:
                          'Assemble Option: ${transactionData['assembly'] ? 'Yes' : 'No'}',
                    ),
                  BodyMediumOver(
                    text:
                        'Delivery Date and Time: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(transactionData['deliveryDate']))}',
                  ),
                  const Divider(),
                  if (transactionData.containsKey('discountIdImage'))
                    BodyMediumOver(
                      text: 'Items: ${transactionData['items']!.map((item) {
                        if (item is Map<String, dynamic> &&
                            item.containsKey('name') &&
                            item.containsKey('quantity') &&
                            item.containsKey('customerPrice')) {
                          final itemName = item['name'];
                          final quantity = item['quantity'];
                          final price = NumberFormat.decimalPattern().format(
                              double.parse(
                                  (item['customerPrice']).toStringAsFixed(2)));

                          return '$itemName (₱$price x $quantity)';
                        }
                      }).join(', ')}',
                    ),
                  if (!transactionData.containsKey('discountIdImage') &&
                      transactionData['discounted'] == false)
                    BodyMediumOver(
                      text: 'Items: ${transactionData['items']!.map((item) {
                        if (item is Map<String, dynamic> &&
                            item.containsKey('name') &&
                            item.containsKey('quantity') &&
                            item.containsKey('retailerPrice')) {
                          final itemName = item['name'];
                          final quantity = item['quantity'];
                          final price = NumberFormat.decimalPattern().format(
                              double.parse(
                                  (item['retailerPrice']).toStringAsFixed(2)));

                          return '$itemName (₱$price x $quantity)';
                        }
                      }).join(', ')}',
                    ),
                  BodyMediumText(
                    text:
                        'Total: ₱${NumberFormat.decimalPattern().format(double.parse((transactionData['total']).toStringAsFixed(2)))}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
