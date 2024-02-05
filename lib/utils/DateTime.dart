// utils.dart

import 'package:intl/intl.dart';

class DateUtils {
  static String formatDeliveryDate(String? deliveryDate) {
    if (deliveryDate != null) {
      // Parse the deliveryDate string to DateTime
      DateTime deliveryDateTime = DateTime.parse(deliveryDate);

      // Format the DateTime to a readable string in 12-hour format
      String formattedDate =
          DateFormat('yyyy-MM-dd hh:mm:ss a').format(deliveryDateTime);

      return formattedDate;
    } else {
      return 'N/A'; // or any default value you prefer
    }
  }
}
