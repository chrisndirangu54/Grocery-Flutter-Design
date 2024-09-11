import 'dart:async'; // Import the async package
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore dependency
import 'package:grocerry/models/cart_item.dart';
import 'package:grocerry/models/product.dart'; // Assuming you have a Product model
import 'package:grocerry/models/user.dart';
import 'package:grocerry/providers/cart_provider.dart'; // Import CartProvider

class UserProvider with ChangeNotifier {
  // Profile-related fields
  String _name;
  String _email;
  String _address;
  String _pinLocation;
  String _profilePictureUrl;
  DateTime? _lastLoginDate;

  final Map<String, String> _addressCache = {};
  final Dio _dio = Dio();

  // User-related fields
  User _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cart provider
  late CartProvider _cartProvider;

  // Streams
  final _userStreamController = StreamController<User>.broadcast();
  final _cartStreamController =
      StreamController<Map<String, CartItem>>.broadcast();

  // Constructors
  UserProvider({
    required String name,
    required String email,
    String address = '',
    String pinLocation = '',
    String profilePictureUrl = '',
    DateTime? lastLoginDate,
    required User user,
  })  : _name = name,
        _email = email,
        _address = address,
        _pinLocation = pinLocation,
        _profilePictureUrl = profilePictureUrl,
        _lastLoginDate = lastLoginDate,
        _user = user;

  // Getters
  String get name => _name;
  String get email => _email;
  String get address => _address;
  String get pinLocation => _pinLocation;
  String get profilePictureUrl => _profilePictureUrl;
  DateTime? get lastLoginDate => _lastLoginDate;
  User get user => _user;

  Stream<User> get userStream => _userStreamController.stream;
  Stream<Map<String, CartItem>> get cartStream => _cartStreamController.stream;

  // Methods to update profile data
  void updateProfile({
    required String name,
    required String email,
    String? profilePictureUrl,
    DateTime? lastLoginDate,
  }) {
    _name = name;
    _email = email;
    if (profilePictureUrl != null) _profilePictureUrl = profilePictureUrl;
    if (lastLoginDate != null) _lastLoginDate = lastLoginDate;
    _user = _user.copyWith(
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
      lastLoginDate: lastLoginDate,
    );
    _userStreamController.add(_user);
    notifyListeners();
  }

  void updateAddress(String newAddress) {
    _address = newAddress;
    _addressCache[_pinLocation] = newAddress;
    _user = _user.copyWith(address: newAddress);
    _userStreamController.add(_user);
    notifyListeners();
  }

  void updatePinLocation(String newPinLocation) {
    _pinLocation = newPinLocation;
    _user = _user.copyWith(address: _addressCache[newPinLocation] ?? _address);
    _userStreamController.add(_user);
    notifyListeners();
  }

  void updateProfilePictureUrl(String newUrl) {
    _profilePictureUrl = newUrl;
    _user = _user.copyWith(profilePictureUrl: newUrl);
    _userStreamController.add(_user);
    notifyListeners();
  }

  void updateLastLoginDate(DateTime? newDate) {
    if (newDate != null) {
      _lastLoginDate = newDate;
      _user = _user.copyWith(lastLoginDate: newDate);
      _userStreamController.add(_user);
      notifyListeners();
    }
  }

  // Methods to manage user data
  void updateUser(User newUser) {
    _user = newUser;
    _userStreamController.add(_user);
    notifyListeners();
  }

  void updateUserField({
    String? email,
    String? token,
    String? name,
    String? address,
    String? profilePictureUrl,
    List<String>? favoriteProductIds,
    List<String>? recentlyBoughtProductIds,
    DateTime? lastLoginDate,
    bool? isAdmin,
    bool? canManageUsers,
    bool? canManageProducts,
    bool? canViewReports,
    bool? canEditSettings,
    bool? isRider,
    bool? isAvailableForDelivery,
    LatLng? liveLocation,
    bool? isAttendant,
    bool? canConfirmPreparing,
    bool? canConfirmReadyForDelivery,
  }) {
    _user = _user.copyWith(
      email: email,
      token: token,
      name: name,
      address: address,
      profilePictureUrl: profilePictureUrl,
      favoriteProductIds: favoriteProductIds,
      recentlyBoughtProductIds: recentlyBoughtProductIds,
      lastLoginDate: lastLoginDate,
      isAdmin: isAdmin,
      canManageUsers: canManageUsers,
      canManageProducts: canManageProducts,
      canViewReports: canViewReports,
      canEditSettings: canEditSettings,
      isRider: isRider,
      isAvailableForDelivery: isAvailableForDelivery,
      liveLocation: liveLocation,
      isAttendant: isAttendant,
      canConfirmPreparing: canConfirmPreparing,
      canConfirmReadyForDelivery: canConfirmReadyForDelivery,
    );
    _userStreamController.add(_user);
    notifyListeners();
  }

  void clearFavorites() {
    _user = _user.copyWith(favoriteProductIds: []);
    _userStreamController.add(_user);
    notifyListeners();
  }

  void clearRecentlyBoughtProducts() {
    _user = _user.copyWith(recentlyBoughtProductIds: []);
    _userStreamController.add(_user);
    notifyListeners();
  }

  void addFavoriteProduct(String productId) {
    if (!_user.favoriteProductIds.contains(productId)) {
      _user = _user.copyWith(
          favoriteProductIds: [..._user.favoriteProductIds, productId]);
      _userStreamController.add(_user);
      notifyListeners();
    }
  }

  void removeFavoriteProduct(String productId) {
    _user = _user.copyWith(
        favoriteProductIds:
            _user.favoriteProductIds.where((id) => id != productId).toList());
    _userStreamController.add(_user);
    notifyListeners();
  }

  void addRecentlyBoughtProduct(String productId) {
    if (!_user.recentlyBoughtProductIds.contains(productId)) {
      _user = _user.copyWith(recentlyBoughtProductIds: [
        ..._user.recentlyBoughtProductIds,
        productId
      ]);
      _userStreamController.add(_user);
      notifyListeners();
    }
  }

  // Function to fetch the address
  Future<void> fetchAddress(String pinLocation) async {
    // Check if the address is already cached
    if (_addressCache.containsKey(pinLocation)) {
      _address = _addressCache[pinLocation]!;
      _pinLocation = pinLocation;
      _notifyAddressChange();
      return;
    }

    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

    // Handle missing API key
    if (apiKey.isEmpty) {
      _handleError('API key is missing');
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$pinLocation&key=$apiKey';

    try {
      final response = await _dio.get(url);

      // Handle successful response
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'];
        if (results.isNotEmpty && results[0]['formatted_address'] != null) {
          _address = results[0]['formatted_address'];
        } else {
          _address = 'Unknown Address'; // Handle case when no address is found
        }

        // Cache the result to avoid future API calls for the same location
        _addressCache[pinLocation] = _address;
        _pinLocation = pinLocation;
        _notifyAddressChange();
      } else {
        _handleError(
            'Failed to load address. Status: ${response.data['status']}');
      }
    } on DioException catch (e) {
      _handleError('Dio error: ${e.message}'); // Catch Dio-specific errors
    } catch (error) {
      _handleError(
          'Unexpected error: $error'); // Catch any other unexpected errors
    }
  }

  // Helper function to notify address changes (you can replace this with actual UI update logic)
  void _notifyAddressChange() {
    print('Address updated: $_address');
  }

  // Private function to handle errors
  void _handleError(String error) {
    print('Error: $error');
    _address = 'Unknown Address'; // Set fallback address in case of errors
    _notifyAddressChange();
  }

  // Fetch methods
  Future<List<Product>> fetchFavorites() async {
    if (_user.favoriteProductIds.isEmpty) return [];

    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: _user.favoriteProductIds)
          .get();

      final favorites =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      return favorites;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<List<Product>> fetchRecentlyBought() async {
    if (_user.recentlyBoughtProductIds.isEmpty) return [];

    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: _user.recentlyBoughtProductIds)
          .get();

      final recentlyBought =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      return recentlyBought;
    } catch (e) {
      print('Error fetching recently bought products: $e');
      return [];
    }
  }

  // Logout method
  void logout() {
    _user = User(
      email: '',
      token: '',
      name: '',
      address: '',
      profilePictureUrl: '',
      favoriteProductIds: [],
      recentlyBoughtProductIds: [],
      lastLoginDate: null,
      isAdmin: false,
      canManageUsers: false,
      canManageProducts: false,
      canViewReports: false,
      canEditSettings: false,
      isRider: false,
      isAvailableForDelivery: false,
      liveLocation: null,
      isAttendant: false,
      canConfirmPreparing: false,
      canConfirmReadyForDelivery: false,
    );
    _userStreamController.add(_user);
    notifyListeners();
  }

  // Token update and login status check
  void updateToken(String newToken) {
    _user = _user.copyWith(token: newToken);
    _userStreamController.add(_user);
    notifyListeners();
  }

  bool isLoggedIn() {
    return _user.token.isNotEmpty && _user.email.isNotEmpty;
  }

  // Stream to listen to user's favorite products in real-time
  Stream<List<Product>> favoritesStream() {
    if (_user.favoriteProductIds.isEmpty) {
      return Stream.value([]); // Return an empty stream if no favorites
    }

    return _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: _user.favoriteProductIds)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(
              doc)) // Assuming a fromFirestore method in Product
          .toList();
    });
  }

  // Stream to listen to user's recently bought products in real-time
  Stream<List<Product>> recentlyBoughtStream() {
    if (_user.recentlyBoughtProductIds.isEmpty) {
      return Stream.value(
          []); // Return an empty stream if no recently bought products
    }

    return _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: _user.recentlyBoughtProductIds)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(
              doc)) // Assuming a fromFirestore method in Product
          .toList();
    });
  }

  // Set CartProvider
  void setCartProvider(CartProvider cartProvider) {
    _cartProvider = cartProvider;
    _cartProvider.cartStream.listen((cartItems) {
      // Handle cart item changes
      print('Cart items updated: $cartItems');
      _cartStreamController.add(cartItems); // Add cart items to the stream
      // You can update user-related logic here based on cart changes
    });
  }

  @override
  void dispose() {
    _userStreamController
        .close(); // Close the StreamController when the provider is disposed
    _cartStreamController
        .close(); // Close the StreamController when the provider is disposed
    super.dispose();
  }
}
