import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _favorites = [];
  List<Product> _recentlyBought = [];

  // Getter to retrieve the list of products
  List<Product> get products => _products;

  // Getter to retrieve the list of favorite products
  List<Product> get favorites => _favorites;

  // Getter to retrieve the list of recently bought products
  List<Product> get recentlyBought => _recentlyBought;

  // Method to fetch products from the API and update the list
  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:5000/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // Map the JSON data to the Product model, including category, variety, and pictureUrl
      _products = data.map((item) => Product.fromJson(item)).toList();
      
      // Notify listeners to rebuild UI with updated product list
      notifyListeners();
    } else {
      // Throw an exception if the request fails
      throw Exception('Failed to load products');
    }
  }

  // Method to fetch favorite products from the API
  Future<void> fetchFavorites() async {
    final response = await http.get(Uri.parse('http://localhost:5000/favorites'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // Map the JSON data to the Product model
      _favorites = data.map((item) => Product.fromJson(item)).toList();
      
      // Notify listeners to rebuild UI with updated favorite list
      notifyListeners();
    } else {
      // Throw an exception if the request fails
      throw Exception('Failed to load favorites');
    }
  }

  // Method to fetch recently bought products from the API
  Future<void> fetchRecentlyBought() async {
    final response = await http.get(Uri.parse('http://localhost:5000/recently-bought'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // Map the JSON data to the Product model
      _recentlyBought = data.map((item) => Product.fromJson(item)).toList();
      
      // Notify listeners to rebuild UI with updated recently bought list
      notifyListeners();
    } else {
      // Throw an exception if the request fails
      throw Exception('Failed to load recently bought products');
    }
  }

  // Method to update a product as a favorite
  void toggleFavoriteStatus(Product product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  // Method to add a product to recently bought list
  void addRecentlyBought(Product product) {
    _recentlyBought.add(product);
    // Optionally, you could limit the size of recently bought products list
    if (_recentlyBought.length > 10) {
      _recentlyBought.removeAt(0); // Remove the oldest entry
    }
    notifyListeners();
  }

  // Method to clear all product lists (optional)
  void clearData() {
    _products.clear();
    _favorites.clear();
    _recentlyBought.clear();
    notifyListeners();
  }
}
