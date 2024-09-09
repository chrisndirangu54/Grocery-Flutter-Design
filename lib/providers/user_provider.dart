import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocerry/models/user.dart';

class UserProvider with ChangeNotifier {
  User _user;

  UserProvider({
    required User user,
  }) : _user = user;

  // Getter for accessing the current user
  User get user => _user;

  // Method to update user details
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to update specific fields of the user
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
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to logout the user
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
    notifyListeners(); // Notify listeners that the user has been logged out
  }

  // Method to reset user to a specific state or default values
  void resetUser(User newUser) {
    _user = newUser;
    notifyListeners(); // Notify listeners that the user has been reset
  }

  // Method to update user token
  void updateToken(String newToken) {
    _user = _user.copyWith(token: newToken);
    notifyListeners(); // Notify listeners that the token has been updated
  }

  // Method to check if the user is logged in
  bool isLoggedIn() {
    return _user.token.isNotEmpty && _user.email.isNotEmpty;
  }

  // Method to clear the user's favorite product list
  void clearFavorites() {
    _user = _user.copyWith(favoriteProductIds: []);
    notifyListeners(); // Notify listeners that the favorites have been cleared
  }

  // Method to clear the user's recently bought product list
  void clearRecentlyBoughtProducts() {
    _user = _user.copyWith(recentlyBoughtProductIds: []);
    notifyListeners(); // Notify listeners that the recently bought products have been cleared
  }
}
