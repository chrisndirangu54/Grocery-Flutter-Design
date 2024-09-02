import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers for real-time product updates
  final StreamController<List<Product>> _productsStreamController =
      StreamController.broadcast();
  final StreamController<List<Product>> _favoritesStreamController =
      StreamController.broadcast();
  final StreamController<List<Product>> _recentlyBoughtStreamController =
      StreamController.broadcast();

  // Getters for product streams
  Stream<List<Product>> get productsStream => _productsStreamController.stream;
  Stream<List<Product>> get favoritesStream =>
      _favoritesStreamController.stream;
  Stream<List<Product>> get recentlyBoughtStream =>
      _recentlyBoughtStreamController.stream;

  // Generic method to fetch data from Firestore and populate the corresponding stream
  Future<void> _fetchData(String collectionName,
      StreamController<List<Product>> streamController) async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      final products =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      streamController.add(products);
    } on FirebaseException catch (e) {
      // Handle errors appropriately (e.g., show a snackbar or log the error)
      print("Error fetching data from $collectionName: $e");
    }
  }

  // Public methods to fetch products, favorites, and recently bought items
  Future<void> fetchProducts() async =>
      _fetchData('products', _productsStreamController);
  Future<void> fetchFavorites() async =>
      _fetchData('favorites', _favoritesStreamController);
  Future<void> fetchRecentlyBought() async =>
      _fetchData('recently-bought', _recentlyBoughtStreamController);

  // Method to toggle the favorite status of a product
  Future<void> toggleFavoriteStatus(Product product) async {
    final docRef = _firestore.collection('favorites').doc(product.id);
    final isFavorite = await docRef.get().then((doc) => doc.exists);

    if (isFavorite) {
      await docRef.delete();
    } else {
      await docRef.set(product.toMap());
    }

    await fetchFavorites(); // Refresh the favorites stream after toggling
  }

  // Method to add a product to the recently bought list
  Future<void> addRecentlyBought(Product product) async {
    final docRef = _firestore.collection('recently-bought').doc(product.id);
    await docRef.set(product.toMap());

    await fetchRecentlyBought(); // Refresh the recently bought stream after adding
  }

  // Optional method to clear all product lists
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

// Assuming this is in the same file for simplicity
class Product {
  final String id;
  final String name;
  final double price;
  // Add other fields as necessary

  Product({
    required this.id,
    required this.name,
    required this.price,
    // Initialize other fields here
  });

  // Factory method to create a Product object from Firestore data
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'],
      price: data['price'],
      // Initialize other fields from the Firestore data
    );
  }

  // Convert Product object to a map that can be saved to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      // Add other fields here
    };
  }
}
