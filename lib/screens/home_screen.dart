import 'package:flutter/material.dart';
import 'package:grocerry/models/product.dart';
import 'package:grocerry/providers/user_provider.dart';
import 'package:grocerry/screens/admin_add_product_screen.dart';
import 'package:grocerry/screens/admin_dashboard_screen.dart';
import 'package:grocerry/screens/admin_offers_screen.dart';
import 'package:grocerry/screens/cart_screen.dart';
import 'package:grocerry/screens/pending_deliveries_screen.dart';
import 'package:grocerry/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

import '../providers/product_provider.dart'; // Assuming this is the correct path
import '../providers/offer_provider.dart';
import '../utils.dart'; // Fallback utility for fetching data

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  late OfferProvider _offerProvider;
  late UserProvider _userProvider;
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Product> recentlyBought = [];
  List<Product> favorites = [];
  List<Product> seasonallyAvailableProducts = [];
  List<Product> nearbyUsersBought = [];
  List<Product> predictedProducts = [];
  List<String> searchSuggestions = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Flag to toggle search bar visibility

  get offers => null;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    searchController.addListener(_filterProducts); // Adding search listener
  }

  @override
  void dispose() {
    searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  Future<void> _initializeProducts() async {
    try {
      _productProvider = Provider.of<ProductProvider>(context, listen: false);
      _offerProvider = Provider.of<OfferProvider>(context, listen: false);
      _userProvider = Provider.of<UserProvider>(context,
          listen: false); // Make sure this is initialized as well

      await Future.wait([
        _productProvider.fetchProducts(),
        _userProvider.fetchFavorites(),
        _userProvider.fetchRecentlyBought(),
        _offerProvider.fetchOffers(),
      ]);

      // Listen to streams properly
      _productProvider.productsStream.listen((fetchedProducts) {
        _updateProductState(fetchedProducts);
      });

      _userProvider.favoritesStream.listen((fetchedFavorites) {
        _updateFavoriteState(fetchedFavorites);
      });

      _userProvider.recentlyBoughtStream.listen((fetchedRecentlyBought) {
        _updateRecentlyBoughtState(fetchedRecentlyBought);
      });
    } catch (e) {
      print("Error initializing providers, falling back to utils.dart: $e");
      await _fetchFallbackProducts();
    }
  }

  void _updateProductState(List<Product> fetchedProducts) {
    setState(() {
      products = fetchedProducts;
      filteredProducts = products; // Initially set filtered to all products
    });
  }

  void _updateFavoriteState(List<Product> fetchedFavorites) {
    setState(() {
      favorites = fetchedFavorites;
    });
  }

  void _updateRecentlyBoughtState(List<Product> fetchedRecentlyBought) {
    setState(() {
      recentlyBought = fetchedRecentlyBought;
    });
  }

  Future<void> _fetchFallbackProducts() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        products = itemList.cast<Product>();
        recentlyBought = itemList
            .where((item) => item.reviewCount > 40)
            .cast<Product>()
            .toList();
        favorites =
            itemList.where((item) => item.price < 1.0).cast<Product>().toList();
        filteredProducts = products;
      });
    } catch (e) {
      print("Error fetching fallback products: $e");
    }
  }

  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      setState(() {
        // Filter products based on basic substring match and fuzzy matching
        filteredProducts = products.where((product) {
          String productName = product.name.toLowerCase();
          return productName.contains(query) ||
              productName.similarityTo(query) > 0.5;
        }).toList();

        // Generate search suggestions using both basic and fuzzy matching
        searchSuggestions =
            products.map((product) => product.name).where((name) {
          String lowerCaseName = name.toLowerCase();
          return lowerCaseName.contains(query) ||
              lowerCaseName.similarityTo(query) > 0.5;
        }).toList();
      });
    } else {
      setState(() {
        filteredProducts = products;
        searchSuggestions = [];
      });
    }
  }

  // Function to get AI-based search suggestions
  List<String> _getSearchSuggestions() {
    return searchSuggestions.isNotEmpty
        ? searchSuggestions
        : ['Apple', 'Banana', 'Snacks']; // Example static suggestions
  }

  List<Product> predictProducts(
      List<Product> recentlyBought,
      List<Product> allProducts,
      List<Product> nearbyUsersBought,
      List<Product> seasonallyAvailableProducts) {
    List<Product> combinedProducts = allProducts;

    List<Product> seasonalProducts =
        combinedProducts.where((p) => p.isInSeason()).toList();

    List<Product> complementaryProducts = [];
    for (Product recent in recentlyBought) {
      complementaryProducts
          .addAll(combinedProducts.where((p) => recent.isComplementaryTo(p)));
    }

    List<Product> nearbyTrendingProducts = nearbyUsersBought;

    List<Product> combinedPrediction = <Product>{
      ...seasonalProducts,
      ...complementaryProducts,
      ...nearbyTrendingProducts,
      ...recentlyBought,
    }.toList();

    return combinedPrediction.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> predictedProducts = predictProducts(
      recentlyBought,
      products,
      nearbyUsersBought,
      seasonallyAvailableProducts,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sokoni\'s Grocery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle search bar visibility
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to Profile Screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_rounded),
            onPressed: _openWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
        ],
        bottom: isSearching
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      // Display AI-based search suggestions
                      if (_getSearchSuggestions().isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children: _getSearchSuggestions().map((suggestion) {
                            return ActionChip(
                              label: Text(suggestion),
                              onPressed: () {
                                setState(() {
                                  searchController.text = suggestion;
                                  _filterProducts();
                                });
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offers.isNotEmpty) ...[
              _buildSectionTitle('Offers'),
              CarouselSlider(
                options: CarouselOptions(height: 200.0, autoPlay: true),
                items: offers.map((offerProduct) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: const BoxDecoration(color: Colors.blue),
                        child: Column(
                          children: [
                            Image.network(
                              offerProduct.imageUrl,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              offerProduct.name,
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                            Text(
                              '\$${offerProduct.price}',
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
            _buildSectionTitle('Recently Bought'),
            _buildHorizontalProductList(recentlyBought),
            _buildSectionTitle('Favorites'),
            _buildHorizontalProductList(favorites),
            _buildSectionTitle('Predicted Products'),
            _buildHorizontalProductList(predictedProducts),
            _buildSectionTitle('All Products'),
            _buildHorizontalProductList(filteredProducts),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHorizontalProductList(List<Product> products) {
    return SizedBox(
      height: 200.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          Product product = products[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(product.pictureUrl,
                    height: 120, fit: BoxFit.cover),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (_userProvider.user.isAdmin && !_userProvider.user.isRider) {
          // Admin action button
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen()));
            },
          );
        } else if (_userProvider.user.isRider ||
            _userProvider.user.isAttendant) {
          // Rider or Attendant action button
          IconButton(
            icon: const Icon(Icons.delivery_dining),
            onPressed: () {
              if (_userProvider.user.isRider) {
                // Navigate to Pending Deliveries Screen for Rider
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PendingDeliveriesScreen()));
              } else if (_userProvider.user.isAttendant) {
                // Show Bottom Sheet with options for Attendant
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add_box),
                          title: const Text('Add Products'),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AdminAddProductScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.local_offer),
                          title: const Text('Create Offers'),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AdminOffersScreen()));
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        }
      },
      child: const Icon(Icons.add),
    );
  }

  void _openWhatsApp() async {
    String phoneNumber = "+254700000000"; // Replace with the actual number
    Uri url = Uri.parse("https://wa.me/$phoneNumber");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

extension on Stream<List<Product>> Function() {
  void listen(Null Function(dynamic fetchedFavorites) param0) {}
}
