import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String productId; // Add productId field
  final double discountedPrice;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.productId, // Initialize productId
    required this.discountedPrice,
  });

  factory Offer.fromFirestore(Map<String, dynamic> data, String id) {
    return Offer(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      price: data['price'] ?? 0.0,
      productId: data['productId'] ?? '', // Fetch productId
      discountedPrice: data['discountedPrice'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'price': price,
      'productId': productId, // Save productId
      'discountedPrice': discountedPrice
    };
  }
}
