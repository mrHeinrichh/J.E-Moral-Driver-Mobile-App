class ProductUtils {
  static String formatProductList(List<dynamic>? items) {
    if (items != null && items.isNotEmpty) {
      List<String> formattedItems = items.map<String>((item) {
        if (item is Map<String, dynamic>) {
          print('Item: $item'); // Add this line to debug
          // Check if the item has the required keys
          if (item.containsKey('name') &&
              item.containsKey('quantity') &&
              item.containsKey('customerPrice')) {
            String productName = item['name']?.toString() ?? 'N/A';
            int quantity = item['quantity']?.toInt() ?? 0;
            double customerPrice = item['customerPrice']?.toDouble() ?? 0.0;

            return '\n$productName - Quantity: $quantity ';
          } else {
            return 'Invalid Product';
          }
        } else {
          return 'Invalid Product';
        }
      }).toList();

      return formattedItems.join(', ');
    } else {
      return 'N/A';
    }
  }
}
