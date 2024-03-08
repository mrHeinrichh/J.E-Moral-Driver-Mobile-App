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
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Transaction ID: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['_id']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Receiver Name: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['name']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Receiver Contact Number: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['contactNumber']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Pin Location: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['deliveryLocation']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "House#/Lot/Blk:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['houseLotBlk']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Barangay: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF050404),
                              ),
                            ),
                            TextSpan(
                              text: '${transactionData['barangay']}',
                              style: TextStyle(color: Color(0xFF050404)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Payment Method: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['paymentMethod']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Assemble Option: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: transactionData['assembly'] != null
                              ? (transactionData['assembly'] ? 'Yes' : 'No')
                              : 'N/A',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Items: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (transactionData['items'] != null)
                          TextSpan(
                            text:
                                (transactionData['items'] as List).map((item) {
                              if (item is Map<String, dynamic> &&
                                  item.containsKey('name') &&
                                  item.containsKey('quantity')) {
                                return '${item['name']} (${item['quantity']})';
                              }
                              return '';
                            }).join(', '),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Total Price: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '₱${transactionData['total']}',
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Status: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF050404),
                        ),
                      ),
                      Text(
                        "${transactionData['status']}",
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Ordered By: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['name']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Ordered By Contact Number: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050404),
                          ),
                        ),
                        TextSpan(
                          text: '${transactionData['contactNumber']}',
                          style: TextStyle(color: Color(0xFF050404)),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Delivery Date/Time: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: transactionData['updatedAt'] != null
                              ? DateFormat('MMM d, y - h:mm a').format(
                                  DateTime.parse(transactionData['updatedAt']),
                                )
                              : 'null',
                        ),
                      ],
                    ),
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
