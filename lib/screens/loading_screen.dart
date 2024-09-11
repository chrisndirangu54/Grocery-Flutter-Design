import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocerry/models/offer.dart';
import 'package:grocerry/providers/offer_provider.dart';
import 'package:provider/provider.dart';
import '../services/loading_screen_service.dart';
import 'dart:io';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  List<Offer> topOffers = [];
  bool isLoading = true;
  File? gifFile; // To hold the GIF file generated from LoadingScreenService

  @override
  void initState() {
    super.initState();
    // Start LoadingScreenService and wait for the GIF to be generated
    _startLoadingScreenService();
  }

  Future<void> _startLoadingScreenService() async {
    // Call the LoadingScreenService and handle the generated GIF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreenService(
          onComplete: (File? generatedGif) {
            setState(() {
              gifFile = generatedGif; // Store the generated GIF file
            });
            _loadTopOffers(); // Start loading offers once GIF is ready
          },
        ),
      ),
    );
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

        // Navigate to home screen after 3 seconds, regardless of whether offers or GIF exist
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    } catch (error) {
      // In case of any errors, still navigate to home screen after 3 seconds
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show loading indicator when fetching data
            : topOffers.isEmpty && gifFile == null
                ? const CircularProgressIndicator() // No offers and no GIF, only show the loading spinner
                : topOffers.isEmpty && gifFile != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // If no offers but GIF exists, show GIF
                          Image.file(
                            gifFile!,
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 20),
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
