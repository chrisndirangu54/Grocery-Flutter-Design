import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'package:grocerry/services/notification_service.dart';

class Order {
  final String id;
  final String description;
  final double totalAmount; // Added price field
  final String? riderLocation; // Added riderLocation field, nullable
  String status;

  String date; // Status can be modified after order creation

  Order({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.date,
    this.riderLocation,
    required this.status,
    required List<String> productIds,
  });
}

class OrderProvider with ChangeNotifier {
  final List<Order> _allOrders = [];
  final List<Order> _pendingOrders = [];
  final NotificationService _notificationService = NotificationService();

  // Expose the list of all orders but prevent external modifications
  List<Order> get allOrders => List.unmodifiable(_allOrders);

  // Expose the list of pending orders but prevent external modifications
  List<Order> get pendingOrders => List.unmodifiable(_pendingOrders);

  OrderProvider() {
    // Fetch orders when the provider is initialized
    _fetchOrdersFromFirebase();
  }

  // Method to update the status of an order by its ID
  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);

    if (orderIndex != -1) {
      // Update the status if the order is found
      _allOrders[orderIndex].status = newStatus;

      // Update the pending orders list
      _updatePendingOrders();

      notifyListeners();

      // Notify backend
      _notifyBackend(orderId, newStatus);
    } else {
      // Log error or handle the case where the order is not found
      debugPrint('Order with ID $orderId not found.');
    }
  }

  // Method to add a new order
  void addOrder(Order newOrder) {
    _allOrders.add(newOrder);
    _updatePendingOrders(); // Update the pending orders list

    // Notify the attendant about the new order
    _notificationService.showOrderNotification(
      'New Order',
      'You have a new order: ${newOrder.description}',
    );

    notifyListeners();
  }

  // Optional: Method to remove an order by ID
  void removeOrder(String orderId) {
    final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _allOrders.removeAt(orderIndex);
      _updatePendingOrders(); // Update the pending orders list
      notifyListeners();
    } else {
      debugPrint('Order with ID $orderId not found.');
    }
  }

  // Method to fetch orders from Firebase Firestore
  Future<void> _fetchOrdersFromFirebase() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      _allOrders.clear();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final order = Order(
          id: doc.id,
          description: data['description'],
          totalAmount: data['totalAmount'].toDouble(),
          riderLocation: data['riderLocation'],
          status: data['status'],
          productIds: ['productId'],
          date: data['date'],
        );
        _allOrders.add(order);
      }
      _updatePendingOrders(); // Update the pending orders list
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  // Method to update the list of pending orders
  void _updatePendingOrders() {
    _pendingOrders.clear();
    _pendingOrders.addAll(
      _allOrders.where((order) => order.status == 'Pending'),
    );
  }

  // Private method for notifying backend services or systems
  Future<void> _notifyBackend(String orderId, String newStatus) async {
    // Simulate network call or Firebase function to update order status
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      debugPrint(
          'Notifying backend: Order $orderId status updated to $newStatus');
    } catch (e) {
      debugPrint('Error notifying backend: $e');
    }
  }

  // Method to calculate daily, weekly, monthly, and yearly order summations
  Map<String, double> getOrderSummations() {
    final now = DateTime.now();
    double dailyTotal = 0;
    double weeklyTotal = 0;
    double monthlyTotal = 0;
    double yearlyTotal = 0;

    for (var order in _allOrders) {
      final orderDate = order.date; // Ensure order date is available
      final orderAmount = order.totalAmount;

      final daysDifference = now.difference(orderDate as DateTime).inDays;
      if (daysDifference < 1) dailyTotal += orderAmount;
      if (daysDifference < 7) weeklyTotal += orderAmount;
      if (daysDifference < 30) monthlyTotal += orderAmount;
      if (daysDifference < 365) yearlyTotal += orderAmount;
    }

    return {
      'Daily': dailyTotal,
      'Weekly': weeklyTotal,
      'Monthly': monthlyTotal,
      'Yearly': yearlyTotal,
    };
  }
}
