import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileProvider with ChangeNotifier {
  String _name;
  String _email;
  String _address;
  String _pinLocation;
  String _profilePictureUrl; // New field for profile picture URL
  DateTime? _lastLoginDate;   // Optional: last login date

  ProfileProvider({
    required String name,
    required String email,
    String address = '',
    String pinLocation = '',
    String profilePictureUrl = '',
    DateTime? lastLoginDate,
  })  : _name = name,
        _email = email,
        _address = address,
        _pinLocation = pinLocation,
        _profilePictureUrl = profilePictureUrl,
        _lastLoginDate = lastLoginDate;

  // Getters
  String get name => _name;
  String get email => _email;
  String get address => _address;
  String get pinLocation => _pinLocation;
  String get profilePictureUrl => _profilePictureUrl;
  DateTime? get lastLoginDate => _lastLoginDate;

  // Method to update profile data
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
    notifyListeners();
  }

  // Method to fetch address from an API
  Future<void> fetchAddress(String pinLocation) async {
    final url = Uri.parse('https://api.example.com/getAddress?pin=$pinLocation');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _address = responseData['address'] ?? 'Unknown Address';
        _pinLocation = pinLocation;
        notifyListeners();
      } else {
        throw Exception('Failed to load address');
      }
    } catch (error) {
      throw error;
    }
  }

  // Method to update address manually
  void updateAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
  }

  // Method to update pin location manually
  void updatePinLocation(String newPinLocation) {
    _pinLocation = newPinLocation;
    notifyListeners();
  }

  // Method to update profile picture URL
  void updateProfilePictureUrl(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners();
  }

  // Method to update last login date
  void updateLastLoginDate(DateTime newDate) {
    _lastLoginDate = newDate;
    notifyListeners();
  }
}
