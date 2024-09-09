import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart'; // Import the Product class

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers for real-time product updates
  final StreamController<List<Product>> _productsStreamController =
      StreamController.broadcast();
  final StreamController<List<Product>> _favoritesStreamController =
      StreamController.broadcast();
  final StreamController<List<Product>> _recentlyBoughtStreamController =
      StreamController.broadcast();

  var user = [];

  // Getters for product streams
  Stream<List<Product>> get productsStream => _productsStreamController.stream;
  Stream<List<Product>> get favoritesStream =>
      _favoritesStreamController.stream;
  Stream<List<Product>> get recentlyBoughtStream =>
      _recentlyBoughtStreamController.stream;

  // Fetch data from Firestore and populate the corresponding stream
  Future<void> _fetchData(String collectionName,
      StreamController<List<Product>> streamController) async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      final products =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      streamController.add(products);
    } on FirebaseException catch (e) {
      print("Error fetching data from $collectionName: $e");
    }
  }

  // Fetch products, favorites, and recently bought items
  Future<void> fetchProducts() async =>
      _fetchData('products', _productsStreamController);
  Future<void> fetchFavorites() async =>
      _fetchData('favorites', _favoritesStreamController);
  Future<void> fetchRecentlyBought() async =>
      _fetchData('recently-bought', _recentlyBoughtStreamController);

  // Get a single product by its ID
  Product? getProductById(String id) {
    final allProducts = _productsStreamController.stream.valueOrNull;
    if (allProducts != null) {
      return allProducts.firstWhere((product) => product.id == id,
          orElse: () => null);
    }
    return null;
  }

  // Toggle the favorite status of a product
  Future<void> toggleFavoriteStatus(Product product) async {
    final docRef = _firestore.collection('favorites').doc(product.id);
    final isFavorite = await docRef.get().then((doc) => doc.exists);

    if (isFavorite) {
      await docRef.delete();
    } else {
      await docRef.set(product.toMap());
    }

    await fetchFavorites(); // Refresh the favorites stream
  }

  // Add a product to the recently bought list
  Future<void> addRecentlyBought(Product product) async {
    final docRef = _firestore.collection('recently-bought').doc(product.id);
    await docRef.set(product.toMap());
    await fetchRecentlyBought(); // Refresh the recently bought stream
  }

  // Clear all product lists
  void clearData() {
    _productsStreamController.add([]);
    _favoritesStreamController.add([]);
    _recentlyBoughtStreamController.add([]);
  }

  @override
  void dispose() {
    _productsStreamController.close();
    _favoritesStreamController.close();
    _recentlyBoughtStreamController.close();
    super.dispose();
  }
}

extension on Stream<List<Product>> {
  get valueOrNull => null;
}
