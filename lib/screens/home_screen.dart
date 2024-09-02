// ignore_for_file: unused_import, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User user = User(isAdmin: false); // Assuming you have a User class
  List<Product> products = []; // Your products list
  List<Product> recentlyBought = [];
  List<Product> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    // Replace with actual product fetching logic
    // This is a placeholder
    List<Product> fetchedProducts = await fetchProductsFromApi();
    setState(() {
      products = fetchedProducts;
      recentlyBought =
          fetchedProducts.where((p) => p.isRecentlyBought).toList();
      favorites = fetchedProducts.where((p) => p.isFavorite).toList();
    });
  }

  List<Product> predictProducts(
      List<Product> recentlyBought, List<Product> allProducts) {
    // Implement your prediction logic
    return allProducts
        .where((p) => !recentlyBought.contains(p))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> predictedProducts = predictProducts(recentlyBought, products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sokoni\'s Grocery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          if (user.isAdmin) // Only show this button if the user is an admin
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen()));
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                // Navigate to Profile Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to Notifications Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                // Navigate to Categories Screen
              },
            ),
            if (user
                .isAdmin) // Only show this option in the drawer if the user is an admin
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Dashboard'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen()));
                },
              ),
          ],
        ),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SectionHeader(title: 'Favorites'),
                ProductList(products: favorites),
                const SectionHeader(title: 'Recently Bought'),
                ProductList(products: recentlyBought),
                const SectionHeader(title: 'You May Also Need'),
                ProductList(products: predictedProducts),
                const SectionHeader(title: 'All Products'),
                ProductList(products: products),
              ],
            ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CartScreen()));
          },
          child: const Icon(Icons.shopping_cart),
        ),
      ),
    );
  }
}

// Placeholder function for fetching products from an API
Future<List<Product>> fetchProductsFromApi() async {
  // Replace with your API fetching logic
  return [
    // Example products
    Product(id: '1', name: 'Apple', isRecentlyBought: true, isFavorite: true),
    Product(id: '2', name: 'Banana', isRecentlyBought: true),
    Product(id: '3', name: 'Carrot', isFavorite: true),
  ];
}

// Example Product class
class Product {
  final String id;
  final String name;
  final bool isRecentlyBought;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.isRecentlyBought = false,
    this.isFavorite = false,
  });
}

// Example User class
class User {
  final bool isAdmin;

  User({required this.isAdmin});
}

// Placeholder SectionHeader widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Placeholder ProductList widget
class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products
          .map((product) => ListTile(
                title: Text(product.name),
              ))
          .toList(),
    );
  }
}
