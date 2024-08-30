class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;    // Category of the product (e.g., fruits, vegetables)
  final String variety;     // Specific variety or type within the category
  final String pictureUrl;  // URL of the picture representing the variety
  final DateTime? lastPurchaseDate; // Date of the last purchase
  final List<String> complementaryProductIds; // List of product IDs that complement this product
  final bool isSeasonal; // Indicates if the product is seasonal
  final DateTime? seasonStart; // Optional: start of the season for seasonal products
  final DateTime? seasonEnd;   // Optional: end of the season for seasonal products

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.variety,
    required this.pictureUrl,
    this.lastPurchaseDate,  // Optional field for last purchase date
    this.complementaryProductIds = const [], // Default to empty list
    this.isSeasonal = false,  // Default to non-seasonal
    this.seasonStart, // Optional field for season start date
    this.seasonEnd,   // Optional field for season end date
  });

  // Factory constructor to create a Product instance from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      category: json['category'],
      variety: json['variety'],
      pictureUrl: json['pictureUrl'],
      lastPurchaseDate: json['lastPurchaseDate'] != null 
          ? DateTime.parse(json['lastPurchaseDate']) 
          : null,
      complementaryProductIds: List<String>.from(json['complementaryProductIds'] ?? []),
      isSeasonal: json['isSeasonal'] ?? false,
      seasonStart: json['seasonStart'] != null 
          ? DateTime.parse(json['seasonStart']) 
          : null,
      seasonEnd: json['seasonEnd'] != null 
          ? DateTime.parse(json['seasonEnd']) 
          : null,
    );
  }

  // Method to convert Product instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }

  // Method to check if this product is complementary to another product
  bool isComplementaryTo(Product other) {
    return complementaryProductIds.contains(other.id);
  }

  // Method to check if the product is currently in season
  bool isInSeason() {
    if (!isSeasonal || seasonStart == null || seasonEnd == null) return false;
    DateTime now = DateTime.now();
    return now.isAfter(seasonStart!) && now.isBefore(seasonEnd!);
  }
}
