import 'package:flutter/material.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/cart_screen.dart';

// Define the User class with the necessary properties
class User {
  final bool isAdmin;

  User({required this.isAdmin});
}

// Define the Product class with the necessary properties
class Product {
  final String name;
  final bool isRecentlyBought;
  final bool isFavorite;

  Product({
    required this.name,
    this.isRecentlyBought = false,
    this.isFavorite = false,
  });
}

// Define the ProductList widget for displaying lists of products
class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User user = User(isAdmin: false); // Initialize User with isAdmin property
  List<Product> products = []; // Initialize products list
  List<Product> recentlyBought = [];
  List<Product> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fetch products from an API (or a mock function for now)
  Future<List<Product>> fetchProductsFromApi() async {
    // Replace this with your actual API call to fetch products
    return [
      Product(name: 'Apple', isRecentlyBought: true, isFavorite: true),
      Product(name: 'Banana', isRecentlyBought: false, isFavorite: true),
      Product(name: 'Orange', isRecentlyBought: true, isFavorite: false),
      Product(name: 'Milk', isRecentlyBought: false, isFavorite: false),
      Product(name: 'Bread', isRecentlyBought: false, isFavorite: false),
    ]; // Return a list of sample products
  }

  // Fetch products and categorize them into recently bought and favorites
  void fetchProducts() async {
    List<Product> fetchedProducts = await fetchProductsFromApi();
    setState(() {
      products = fetchedProducts;
      recentlyBought =
          fetchedProducts.where((p) => p.isRecentlyBought).toList();
      favorites = fetchedProducts.where((p) => p.isFavorite).toList();
    });
  }

  // Predict products that the user may need based on recently bought products
  List<Product> predictProducts(
      List<Product> recentlyBought, List<Product> allProducts) {
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
          if (user.isAdmin)
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
            if (user.isAdmin)
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Favorites',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ProductList(products: favorites),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Recently Bought',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ProductList(products: recentlyBought),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'You May Also Need',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ProductList(products: predictedProducts),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'All Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
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
