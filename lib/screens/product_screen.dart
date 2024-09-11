import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocerry/models/product.dart';
import 'package:grocerry/utils.dart';
import 'package:provider/provider.dart';
import 'package:grocerry/providers/product_provider.dart';
import 'package:grocerry/providers/user_provider.dart'; // For adding/removing favorites
import 'package:grocerry/providers/cart_provider.dart'; // For cart functionality
import 'review_screen.dart'; // Import the review screen

class ProductScreen extends StatelessWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final product = productProvider.getProductById(productId);

    // Define the threshold for "Highly Rated"
    const int highlyRatedThreshold = 100;

    // Create a dynamic list of icons, toggling "Highly Rated" based on review count
    List<IconDetail> dynamicIconsList = [
      IconDetail(
          image: 'assets/icons/LikeOutline.svg', head: 'Quality\nAssurance'),
      IconDetail(
          image: 'assets/icons/SpoonOutline.svg', head: 'Best In\nTaste'),
    ];

    // Add "Highly Rated" icon if the review count exceeds the threshold
    if (product != null && product.reviewCount > highlyRatedThreshold) {
      dynamicIconsList.add(
        IconDetail(
            image: 'assets/icons/StartOutline.svg', head: 'Highly\nRated'),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 60,
        backgroundColor: primaryColor,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context, '/cart'); // Navigate to Cart screen
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 90, 90, 90),
                child: SvgPicture.asset(
                  'assets/icons/cartIcon.svg',
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: product == null
              ? const Center(child: Text("Product not found"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(product.category,
                        style: TextStyle(
                            fontSize: 20, color: mainColor, letterSpacing: 10)),
                    const SizedBox(height: 10),
                    Text(product.name,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      "⭐ (${product.reviewCount} reviews)",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewScreen(productId: product.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("View Reviews"),
                    ),
                    const SizedBox(height: 150),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: textColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                MediaQuery.of(context).size.width / 2.7),
                            topRight: Radius.circular(
                                MediaQuery.of(context).size.width / 2.7),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 55),
                          child: Column(
                            children: [
                              Transform.translate(
                                offset: const Offset(10, -40),
                                child: Transform.scale(
                                  scale: 2.6,
                                  child: Image.asset(
                                    product.pictureUrl,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$ ${product.price}',
                                        style: TextStyle(
                                            color: mainColor.withOpacity(0.6),
                                            fontSize: 35),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "PER KG",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 174, 173, 173),
                                            letterSpacing: 5),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (userProvider.user.favoriteProductIds
                                          .contains(product.id)) {
                                        userProvider
                                            .removeFavoriteProduct(product.id);
                                      } else {
                                        userProvider
                                            .addFavoriteProduct(product.id);
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: iconBackgroundColor,
                                      radius: 30,
                                      child: SvgPicture.asset(
                                        'assets/icons/heartIcon.svg',
                                        height: 24,
                                        width: 24,
                                        colorFilter: ColorFilter.mode(
                                          userProvider.user.favoriteProductIds
                                                  .contains(product.id)
                                              ? Colors
                                                  .red // Show red heart if it's a favorite
                                              : Colors
                                                  .grey, // Show grey heart otherwise
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Display dynamicIconList based on product review count
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: dynamicIconsList.map((iconDetail) {
                                  return Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.grey[300],
                                        child: SvgPicture.asset(
                                          iconDetail.image,
                                          height: 24,
                                          width: 24,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.grey,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        iconDetail.head,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 60),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQuantityManager(
                                      context, cartProvider, product),
                                  GestureDetector(
                                    onTap: () {
                                      cartProvider.addItem(
                                        product,
                                        product.name,
                                        product.price,
                                      );
                                      Navigator.pushNamed(
                                          context, '/cart'); // Navigate to Cart
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      height: 45,
                                      decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(13))),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Go To Cart',
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 6, 2, 67),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          SvgPicture.asset(
                                            'assets/icons/arrowRight.svg',
                                            width: 20,
                                            height: 20,
                                            colorFilter: const ColorFilter.mode(
                                                Color.fromARGB(255, 6, 2, 67),
                                                BlendMode.srcIn),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Widget to manage quantity in cart
  Widget _buildQuantityManager(
      BuildContext context, CartProvider cartProvider, Product product) {
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/minus-solid.svg',
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 157, 157, 157), BlendMode.srcIn),
          ),
          onPressed: () {
            cartProvider.removeItem(product.id);
          },
        ),
        Selector<CartProvider, int>(
          selector: (context, cart) => cart.items[product.id]?.quantity ?? 0,
          builder: (context, quantity, _) {
            return Text(
              quantity.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            );
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/plus-solid.svg',
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 157, 157, 157), BlendMode.srcIn),
          ),
          onPressed: () {
            cartProvider.addItem(product, product.name, product.price);
          },
        ),
      ],
    );
  }
}
