import 'package:flutter/material.dart';

class Order {
  final String id;
  final String description;
  String status;

  Order({
    required this.id,
    required this.description,
    required this.status,
  });
}

class OrderProvider with ChangeNotifier {
  final List<Order> _pendingOrders = [
    Order(id: '123', description: 'Order #123 - Apple', status: 'Pending'),
    Order(id: '124', description: 'Order #124 - Banana', status: 'Pending'),
    Order(id: '125', description: 'Order #125 - Orange', status: 'Pending'),
  ];

  List<Order> get pendingOrders => List.unmodifiable(_pendingOrders);

  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex =
        _pendingOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _pendingOrders[orderIndex].status = newStatus;
      notifyListeners();
      // Additional logic to notify riders and admin
      // This could involve calling a backend service or Firebase function
    } else {
      // Log error or throw an exception if the order ID is not found
      debugPrint('Order with ID $orderId not found.');
    }
  }

  void addOrder(Order order) {
    _pendingOrders.add(order);
    notifyListeners();
  }
}
