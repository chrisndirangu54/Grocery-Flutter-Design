import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String userId;
  final String status;
  final List<OrderItem> items;
  final String riderLocation;
  final String riderContact;
  final String? estimatedDeliveryTime;
  final double totalAmount; // Add price field
  final DateTime? date; // Add date field

  Order({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.items,
    required this.riderLocation,
    required this.riderContact,
    this.estimatedDeliveryTime,
    required this.totalAmount,
    this.date,
  });

  // Factory method to create Order from Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      orderId: doc.id,
      userId: data['userId'],
      status: data['status'],
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      riderLocation: data['riderLocation'],
      riderContact: data['riderContact'],
      estimatedDeliveryTime: data['estimatedDeliveryTime'],
      totalAmount: data['totalAmount'].toDouble(),
      date: (data['date'] as Timestamp?)
          ?.toDate(), // Convert Firestore timestamp to DateTime
    );
  }

  Order copyWith({
    String? status,
    String? riderLocation,
    String? riderContact,
    String? estimatedDeliveryTime,
    DateTime? date,
  }) {
    return Order(
      orderId: orderId,
      userId: userId,
      status: status ?? this.status,
      items: items,
      riderLocation: riderLocation ?? this.riderLocation,
      riderContact: riderContact ?? this.riderContact,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      totalAmount: totalAmount,
      date: date ?? this.date,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final bool isReviewed;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.isReviewed,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'],
      productName: data['productName'],
      price: data['price'].toDouble(),
      isReviewed: data['isReviewed'],
    );
  }
}
