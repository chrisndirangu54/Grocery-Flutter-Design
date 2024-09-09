import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/offer.dart';

class OfferProvider with ChangeNotifier {
  List<Offer> _offers = [];

  List<Offer> get offers => [..._offers];

  Future<void> fetchOffers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('offers').get();
    _offers = snapshot.docs
        .map((doc) => Offer.fromFirestore(doc.data(), doc.id))
        .toList();
    notifyListeners();
  }

  Future<void> addOffer(Offer offer) async {
    final docRef = await FirebaseFirestore.instance
        .collection('offers')
        .add(offer.toMap());
    final newOffer = Offer(
      id: docRef.id,
      title: offer.title,
      description: offer.description,
      imageUrl: offer.imageUrl,
      startDate: offer.startDate,
      endDate: offer.endDate,
      price: offer.price,
      productId: '', // Ensure price is added here
      discountedPrice: offer.discountedPrice,
    );
    _offers.add(newOffer);
    notifyListeners();
  }

  Future<List<Offer>> getTopThreeOffers() async {
    final QuerySnapshot offersSnapshot = await FirebaseFirestore.instance
        .collection('offers')
        .orderBy('discount',
            descending: true) // Assuming you have a 'discount' field
        .limit(3)
        .get();

    return offersSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Offer.fromFirestore(data, doc.id);
    }).toList();
  }

  Future<void> deleteOffer(String id) async {
    await FirebaseFirestore.instance.collection('offers').doc(id).delete();
    _offers.removeWhere((offer) => offer.id == id);
    notifyListeners();
  }

  Future<void> updateOffer(Offer offer) async {
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offer.id)
        .update(offer.toMap());
    final offerIndex = _offers.indexWhere((element) => element.id == offer.id);
    if (offerIndex >= 0) {
      _offers[offerIndex] = offer;
      notifyListeners();
    }
  }
}
