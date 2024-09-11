import 'dart:async'; // Import the async package
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final _cartStreamController =
      StreamController<Map<String, CartItem>>.broadcast();

  Map<String, CartItem> get items => _items;

  Stream<Map<String, CartItem>> get cartStream => _cartStreamController.stream;

  void addItem(Product product, String title, double discountedPrice) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    _cartStreamController.add(_items); // Notify listeners about the cart update
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _cartStreamController.add(_items); // Notify listeners about the cart update
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void clearCart() {
    _items = {};
    _cartStreamController.add(_items); // Notify listeners about the cart update
    notifyListeners();
  }

  @override
  void dispose() {
    _cartStreamController
        .close(); // Close the StreamController when the provider is disposed
    super.dispose();
  }
}
