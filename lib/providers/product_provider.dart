import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<Product> _favorites = [];
  final List<Product> _recentlyBought = [];

  // Getter to retrieve the list of products
  List<Product> get products => _products;

  // Getter to retrieve the list of favorite products
  List<Product> get favorites => _favorites;

  // Getter to retrieve the list of recently bought products
  List<Product> get recentlyBought => _recentlyBought;
  Future<void> _fetchData(String endpoint, List<Product> listToUpdate) async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/$endpoint'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      listToUpdate.clear(); // Clear the list before updating
      listToUpdate.addAll(data.map((item) => Product.fromJson(item)).toList());
      notifyListeners();
    } else {
      throw Exception('Failed to load $endpoint');
    }
  }

  // Method to fetch data
  Future<void> fetchProducts() async {
    await _fetchData('products', _products);
  }

  Future<void> fetchFavorites() async {
    await _fetchData('favorites', _favorites);
  }

  Future<void> fetchRecentlyBought() async {
    await _fetchData('recently-bought', _recentlyBought);
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
    _favorites.clear();
    _recentlyBought.clear();
    notifyListeners();
  }
}
