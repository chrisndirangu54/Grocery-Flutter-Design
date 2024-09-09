import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocerry/models/offer.dart';
import '../providers/offer_provider.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  List<Offer> topOffers = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTopOffers();
  }

  Future<void> _loadTopOffers() async {
    try {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      await offerProvider.fetchOffers();
      final offers = await offerProvider.getTopThreeOffers();

      if (mounted) {
        setState(() {
          topOffers = offers;
          isLoading = false;
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load offers';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  )
                : topOffers.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Animation here
                          Image.asset(
                            'assets/logo_animation.gif', // Replace with your logo animation asset path
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No offers available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: topOffers.length,
                        itemBuilder: (context, index) {
                          final offer = topOffers[index];
                          return Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl: offer.imageUrl,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                height: 150.0,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                offer.title,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(offer.description),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
      ),
    );
  }
}
