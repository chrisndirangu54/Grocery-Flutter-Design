class Order {
  final String orderId;
  final List<OrderItem> items; // Updated to handle multiple items
  final String status;
  final String riderLocation;

  Order({
    required this.orderId,
    required this.items,
    required this.status,
    required this.riderLocation,
  });
}

class OrderItem {
  final String productId; // Unique identifier for the product
  final String productName;
  final double price;
  final bool isReviewed; // To track if the item has been reviewed

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.isReviewed = false,
  });
}
