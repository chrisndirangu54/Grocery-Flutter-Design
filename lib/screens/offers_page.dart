import 'package:flutter/material.dart';
import 'package:grocerry/models/product.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../providers/cart_provider.dart'; // Import the cart provider

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context,
        listen: false); // Access cart provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Offers'),
      ),
      body: FutureBuilder(
        future: offerProvider.fetchOffers(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          } else {
            return Consumer<OfferProvider>(
              builder: (ctx, offerData, _) => ListView.builder(
                itemCount: offerData.offers.length,
                itemBuilder: (ctx, i) {
                  final offer = offerData.offers[i];
                  return ListTile(
                    title: Text(offer.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.description),
                        const SizedBox(height: 4),
                        Text(
                          'Original Price: \$${offer.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Discounted Price: \$${offer.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    leading: Image.network(offer.imageUrl),
                    trailing: ElevatedButton(
                      onPressed: () {
                        cartProvider.addItem(
                          offer.id as Product,
                          offer.title,
                          offer.discountedPrice,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${offer.title} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                          'Add to Cart (\$${offer.discountedPrice.toStringAsFixed(2)})'),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
