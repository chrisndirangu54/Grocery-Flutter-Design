import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String variety;
  final String pictureUrl;
  final DateTime? lastPurchaseDate;
  final bool iscomplementary;
  final List<String> complementaryProductIds;
  final bool isSeasonal;
  final DateTime? seasonStart;
  final DateTime? seasonEnd;

  int purchaseCount;
  int recentPurchaseCount;
  int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.variety,
    required this.pictureUrl,
    this.lastPurchaseDate,
    this.iscomplementary = false,
    this.complementaryProductIds = const [],
    this.isSeasonal = false,
    this.seasonStart,
    this.seasonEnd,
    this.purchaseCount = 0,
    this.recentPurchaseCount = 0,
    this.reviewCount = 0,
  });

  // Factory constructor to create a Product instance from Firestore data
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely parsing price in case it is not a double
    final price = data['price'] is int
        ? (data['price'] as int).toDouble()
        : data['price'];

    return Product(
      id: doc.id,
      name: data['name'],
      price: price,
      description: data['description'],
      category: data['category'],
      variety: data['variety'],
      pictureUrl: data['pictureUrl'],
      lastPurchaseDate: data['lastPurchaseDate'] != null
          ? (data['lastPurchaseDate'] as Timestamp).toDate()
          : null,
      complementaryProductIds:
          List<String>.from(data['complementaryProductIds'] ?? []),
      isSeasonal: data['isSeasonal'] ?? false,
      seasonStart: data['seasonStart'] != null
          ? (data['seasonStart'] as Timestamp).toDate()
          : null,
      seasonEnd: data['seasonEnd'] != null
          ? (data['seasonEnd'] as Timestamp).toDate()
          : null,
      purchaseCount: data['purchaseCount'] ?? 0,
      recentPurchaseCount: data['recentPurchaseCount'] ?? 0,
      reviewCount:
          data['reviewCount'] ?? 0, // Parse review count from Firestore
    );
  }

  // Convert Product instance to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'variety': variety,
      'pictureUrl': pictureUrl,
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'complementaryProductIds': complementaryProductIds,
      'isSeasonal': isSeasonal,
      'seasonStart': seasonStart?.toIso8601String(),
      'seasonEnd': seasonEnd?.toIso8601String(),
      'purchaseCount': purchaseCount,
      'recentPurchaseCount': recentPurchaseCount,
      'reviewCount': reviewCount, // Include review count in Firestore map
    };
  }

  // Method to check if the product is in season
  bool isInSeason() {
    if (!isSeasonal) return true;
    final now = DateTime.now();
    return (seasonStart?.isBefore(now) ?? false) &&
        (seasonEnd?.isAfter(now) ?? false);
  }

  // Method to check if this product is complementary to another product
  bool isComplementaryTo(Product p) {
    return complementaryProductIds.contains(p.id);
  }

  // Method to check if the product is trending
  bool get isTrending {
    // Example static threshold for trending products
    const int trendingThreshold = 100; // Define your threshold value
    return purchaseCount >= trendingThreshold;
  }

  get isComplementary => null;

  static Product empty() {
    return Product(
      id: '',
      name: '',
      price: 0.0,
      description: '',
      category: '',
      variety: '',
      pictureUrl: '',
      purchaseCount: 0,
      recentPurchaseCount: 0,
      reviewCount: 0,
    );
  }
}
