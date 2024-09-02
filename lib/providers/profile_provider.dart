import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProfileProvider with ChangeNotifier {
  String _name;
  String _email;
  String _address;
  String _pinLocation;
  String _profilePictureUrl;
  DateTime? _lastLoginDate;

  final Map<String, String> _addressCache = {};
  final Dio _dio = Dio();

  dynamic orders;

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

  // Fetch address with caching
  Future<void> fetchAddress(String pinLocation) async {
    if (_addressCache.containsKey(pinLocation)) {
      _address = _addressCache[pinLocation]!;
      _pinLocation = pinLocation;
      notifyListeners();
      return;
    }

    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$pinLocation&key=$apiKey';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'];
        _address = results.isNotEmpty
            ? results[0]['formatted_address'] ?? 'Unknown Address'
            : 'Unknown Address';
        _addressCache[pinLocation] = _address;
        _pinLocation = pinLocation;
        notifyListeners();
      } else {
        _handleError('Failed to load address. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError('Dio error: ${e.message}');
    } catch (error) {
      _handleError('Unexpected error: $error');
    }
  }

  // Handle errors
  void _handleError(String error) {
    print('Error: $error');
    _address = 'Unknown Address';
    notifyListeners();
  }

  // Update methods
  void updateAddress(String newAddress) {
    _address = newAddress;
    _addressCache[_pinLocation] = newAddress;
    notifyListeners();
  }

  void updatePinLocation(String newPinLocation) {
    _pinLocation = newPinLocation;
    notifyListeners();
  }

  void updateProfilePictureUrl(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners();
  }

  void updateLastLoginDate(DateTime newDate) {
    _lastLoginDate = newDate;
    notifyListeners();
  }
}
