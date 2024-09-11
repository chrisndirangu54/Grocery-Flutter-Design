import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart'; // Import the Product class

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers for real-time product updates
  final StreamController<List<Product>> _productsStreamController =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _seasonallyAvailableStreamController =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _nearbyUsersBoughtStreamController =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _predictedProductsStreamController =
      StreamController<List<Product>>.broadcast();

  // Local cache for products
  List<Product> _allProducts = [];

  // Fetch trending products based on purchase count
  Future<List<Product>> fetchTrendingProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('purchaseCount', descending: true)
          .limit(10) // Adjust the limit as needed
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) => product.isTrending)
          .toList();
    } catch (e) {
      print('Error fetching trending products: $e');
      return [];
    }
  }

  // Fetch complementary products for a given product
  List<Product> getComplementaryProducts(Product product) {
    if (_allProducts.isEmpty) return [];
    return _allProducts.where((p) => product.isComplementaryTo(p)).toList();
  }

  // Getters for product streams
  Stream<List<Product>> get productsStream => _productsStreamController.stream;
  Stream<List<Product>> get seasonallyAvailableStream =>
      _seasonallyAvailableStreamController.stream;
  Stream<List<Product>> get nearbyUsersBoughtStream =>
      _nearbyUsersBoughtStreamController.stream;
  Stream<List<Product>> get predictedProductsStream =>
      _predictedProductsStreamController.stream;

  // Fetch data from Firestore and populate the corresponding stream
  Future<void> _fetchData(String collectionName,
      StreamController<List<Product>> streamController) async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      final products =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      streamController.add(products);

      // Cache products if fetching from the products collection
      if (collectionName == 'products') {
        _allProducts = products;
        _updateSeasonallyAvailableProducts(products);
      }
    } on FirebaseException catch (e) {
      print("Error fetching data from $collectionName: $e");
      streamController.add([]);
    }
  }

  // Fetch products, seasonally available items, nearby users bought items, and predicted products
  Future<void> fetchProducts() async =>
      _fetchData('products', _productsStreamController);
  Future<void> fetchSeasonallyAvailable() async =>
      _fetchData('products', _seasonallyAvailableStreamController);
  Future<void> fetchNearbyUsersBought() async =>
      _fetchData('nearby-users-bought', _nearbyUsersBoughtStreamController);
  Future<void> fetchPredictedProducts() async =>
      _fetchData('predicted-products', _predictedProductsStreamController);

  // Calculate and update seasonally available products
  void _updateSeasonallyAvailableProducts(List<Product> allProducts) {
    final currentDate = DateTime.now();
    final seasonallyAvailable = allProducts.where((product) {
      if (!product.isSeasonal) return true; // Always available if not seasonal
      if (product.seasonStart != null && product.seasonEnd != null) {
        return currentDate.isAfter(product.seasonStart!) &&
            currentDate.isBefore(product.seasonEnd!);
      }
      return false; // Unavailable if missing seasonStart or seasonEnd
    }).toList();
    _seasonallyAvailableStreamController.add(seasonallyAvailable);
  }

  // Get a single product by its ID from the cached products list
  Product? getProductById(String id) {
    if (_allProducts.isNotEmpty) {
      return _allProducts.firstWhere(
        (product) => product.id == id,
        orElse: () => Product.empty(), // Handle non-existent product
      );
    }
    return null;
  }

  @override
  void dispose() {
    _productsStreamController.close();
    _seasonallyAvailableStreamController.close();
    _nearbyUsersBoughtStreamController.close();
    _predictedProductsStreamController.close();
    super.dispose();
  }
}
