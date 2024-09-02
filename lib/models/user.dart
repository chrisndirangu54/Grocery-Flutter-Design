import 'package:google_maps_flutter/google_maps_flutter.dart';

class User {
  final String email;
  final String token;
  final String name;
  final String address;
  final String profilePictureUrl;
  final List<String> favoriteProductIds;
  final List<String> recentlyBoughtProductIds;
  final DateTime? lastLoginDate;

  // Admin-specific fields
  final bool isAdmin;
  final bool canManageUsers;
  final bool canManageProducts;
  final bool canViewReports;
  final bool canEditSettings;

  // Rider-specific fields
  final bool isRider; // Determines if the user is a rider
  final bool isAvailableForDelivery; // Indicates if the rider is available
  final LatLng?
      liveLocation; // Rider's live location (using Google Maps LatLng type)

  User({
    required this.email,
    required this.token,
    required this.name,
    required this.address,
    required this.profilePictureUrl,
    this.favoriteProductIds = const [],
    this.recentlyBoughtProductIds = const [],
    this.lastLoginDate,
    this.isAdmin = false,
    this.canManageUsers = false,
    this.canManageProducts = false,
    this.canViewReports = false,
    this.canEditSettings = false,
    this.isRider = false, // Default to non-rider
    this.isAvailableForDelivery = false, // Default to not available
    this.liveLocation, // Optional live location
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
      recentlyBoughtProductIds:
          List<String>.from(json['recentlyBoughtProductIds'] ?? []),
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'])
          : null,
      isAdmin: json['isAdmin'] ?? false,
      canManageUsers: json['canManageUsers'] ?? false,
      canManageProducts: json['canManageProducts'] ?? false,
      canViewReports: json['canViewReports'] ?? false,
      canEditSettings: json['canEditSettings'] ?? false,
      isRider: json['isRider'] ?? false,
      isAvailableForDelivery: json['isAvailableForDelivery'] ?? false,
      liveLocation: json['liveLocation'] != null
          ? LatLng(json['liveLocation']['lat'], json['liveLocation']['lng'])
          : null,
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
      'isRider': isRider,
      'isAvailableForDelivery': isAvailableForDelivery,
      'liveLocation': liveLocation != null
          ? {'lat': liveLocation!.latitude, 'lng': liveLocation!.longitude}
          : null,
    };
  }
}
