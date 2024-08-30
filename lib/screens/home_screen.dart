import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/product_provider.dart';
import '../screens/product_screen.dart';
import '../screens/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to send a message via WhatsApp
  void _sendMessage() async {
    final message = 'Hello, I need help with my order!';
    final phoneNumber = '+1234567890'; // Replace with the recipient's phone number

    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Product> predictProducts(List<Product> recentPurchases, List<Product> allProducts) {
    // Initialize scores for each product
    Map<Product, double> productScores = {};

    // Scoring based on purchase frequency and time since last purchase
    for (var product in allProducts) {
      double score = 0;

      // Frequency: More frequent purchases get higher scores
      int frequency = recentPurchases.where((p) => p == product).length;
      score += frequency * 2;

      // Time since last purchase: Longer time means higher need
      DateTime? lastPurchaseDate = product.lastPurchaseDate; // Assume this is provided
      if (lastPurchaseDate != null) {
        int daysSinceLastPurchase = DateTime.now().difference(lastPurchaseDate).inDays;
        score += daysSinceLastPurchase / 30.0; // Normalize by month
      }

      // Complementary products: Add score if a complementary product was recently bought
      for (var recentProduct in recentPurchases) {
        if (product.isComplementaryTo(recentProduct)) { // Assume this method is implemented
          score += 5;
        }
      }

      // Category preference: Score products in the same category as recent purchases
      if (recentPurchases.any((p) => p.category == product.category)) {
        score += 3;
      }

      // Seasonal products: Higher score if it's the right season for the product
      if (product.isInSeason()) { // Assume this method is implemented
        score += 4;
      }

      // Assign the final score to the product
      productScores[product] = score;
    }

    // Sort products based on their scores in descending order and return the top 10
    List<Product> sortedProducts = productScores.keys.toList()
      ..sort((a, b) => productScores[b]!.compareTo(productScores[a]!));
    
    return sortedProducts.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _sendMessage,
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
          ],
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context, listen: false)
            .fetchProducts(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          } else {
            return Consumer<ProductProvider>(
              builder: (ctx, productProvider, child) {
                List<Product> recentlyBought = productProvider.recentlyBought;
                List<Product> favorites = productProvider.favorites;
                List<Product> predictedProducts = predictProducts(recentlyBought, productProvider.products);

                return ListView(
                  children: [
                    SectionHeader(title: 'Favorites'),
                    ProductList(products: favorites),

                    SectionHeader(title: 'Recently Bought'),
                    ProductList(products: recentlyBought),

                    SectionHeader(title: 'You May Also Need'),
                    ProductList(products: predictedProducts),

                    SectionHeader(title: 'All Products'),
                    ProductList(products: productProvider.products),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 4),
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

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (ctx, i) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          title: Text(products[i].name),
          subtitle: Text('\$${products[i].price}'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProductScreen(product: products[i])));
          },
        ),
      ),
    );
  }
}
