class User {
  final String email;
  final String token;
  final String name;
  final String address;
  final String profilePictureUrl;
  final List<String> favoriteProductIds; // List of IDs for favorite products
  final List<String> recentlyBoughtProductIds; // List of IDs for recently bought products
  final DateTime? lastLoginDate; // Optional: date of the last login

  // Admin-specific fields
  final bool isAdmin; // Determines if the user has admin privileges
  final bool canManageUsers; // Permission to manage users (for admin)
  final bool canManageProducts; // Permission to manage products (for admin)
  final bool canViewReports; // Permission to view reports (for admin)
  final bool canEditSettings; // Permission to edit system settings (for admin)

  User({
    required this.email,
    required this.token,
    required this.name,
    required this.address,
    required this.profilePictureUrl,
    this.favoriteProductIds = const [], // Initialize to an empty list
    this.recentlyBoughtProductIds = const [], // Initialize to an empty list
    this.lastLoginDate, // Optional field for last login date
    this.isAdmin = false, // Default to non-admin
    this.canManageUsers = false,
    this.canManageProducts = false,
    this.canViewReports = false,
    this.canEditSettings = false,
  });

  // Factory constructor to create a User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      token: json['token'],
      name: json['name'],
      address: json['address'],
      profilePictureUrl: json['profilePictureUrl'],
      favoriteProductIds: List<String>.from(json['favoriteProductIds'] ?? []),
      recentlyBoughtProductIds: List<String>.from(json['recentlyBoughtProductIds'] ?? []),
      lastLoginDate: json['lastLoginDate'] != null 
          ? DateTime.parse(json['lastLoginDate']) 
          : null,
      isAdmin: json['isAdmin'] ?? false,
      canManageUsers: json['canManageUsers'] ?? false,
      canManageProducts: json['canManageProducts'] ?? false,
      canViewReports: json['canViewReports'] ?? false,
      canEditSettings: json['canEditSettings'] ?? false,
    );
  }

  // Method to convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'name': name,
      'address': address,
      'profilePictureUrl': profilePictureUrl,
      'favoriteProductIds': favoriteProductIds,
      'recentlyBoughtProductIds': recentlyBoughtProductIds,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'isAdmin': isAdmin,
      'canManageUsers': canManageUsers,
      'canManageProducts': canManageProducts,
      'canViewReports': canViewReports,
      'canEditSettings': canEditSettings,
    };
  }
}
