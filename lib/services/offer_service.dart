import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/offer.dart'; // For uploading the image

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  OfferService() {
    // Initialize notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> createOffers() async {
    final DateTime now = DateTime.now();
    final bool isPublicHoliday = _checkIfPublicHoliday(now);
    final bool isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (isPublicHoliday || isWeekend) {
      double discount = isPublicHoliday ? 0.10 : 0.05;
      String offerTitle = isPublicHoliday
          ? "Public Holiday Special - 35% Off!"
          : "Weekend Deal - 5% Off!";

      // Adjust prices for public holidays to appear as 35% off
      final QuerySnapshot productsSnapshot =
          await _firestore.collection('products').get();
      for (QueryDocumentSnapshot productDoc in productsSnapshot.docs) {
        final productData = productDoc.data() as Map<String, dynamic>;
        double originalPrice = productData['price'];
        double offer = isPublicHoliday
            ? _calculateAdjustedPrice(originalPrice, 0.35)
            : originalPrice * (1 - discount);

        String newImageUrl = await _embedDiscountOnImage(
          productData['imageUrl'],
          isPublicHoliday ? 35 : 5,
          productData['name'],
        );

        // Create and save offer
        Offer currentOffer = Offer(
          id: productDoc.id,
          title: offerTitle,
          description:
              'Get ${isPublicHoliday ? 35 : 5}% off on ${productData['name']}!',
          imageUrl: newImageUrl,
          startDate: now,
          endDate: now.add(const Duration(days: 1)), // 1-day offer
          price: originalPrice, // Use adjustedPrice here if needed
          productId: '',
          discountedPrice: offer,
        );

        await _firestore
            .collection('offers')
            .doc(currentOffer.id)
            .set(currentOffer.toMap());
      }

      _notifyUsers(offerTitle);
    }
  }

  double _calculateAdjustedPrice(double price, double displayDiscount) {
    double adjustedDiscount = 0.1; // 10% discount but display as 35%
    return price * (1 - adjustedDiscount);
  }

  Future<img.BitmapFont> loadFont() async {
    // Load the .fnt file as a string
    final String fontData =
        await rootBundle.loadString('assets/fonts/arial_24.fnt');

    // Load the .png file associated with the .fnt
    final ByteData fontImageData =
        await rootBundle.load('assets/fonts/arial_24.png');
    final Uint8List fontImageBytes = fontImageData.buffer.asUint8List();

    // Decode the image
    final img.Image fontImage = img.decodeImage(fontImageBytes)!;

    // Create the BitmapFont using the .fnt and associated image
    final img.BitmapFont font = img.BitmapFont.fromFnt(fontData, fontImage);

    return font;
  }

  Future<String> _embedDiscountOnImage(
      String imageUrl, int discount, String productName) async {
    try {
      // Load the font
      img.BitmapFont font = await loadFont();

      // Step 1: Download the image from the given URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load image');
      }

      // Step 2: Decode the image into an Image object
      Uint8List imageData = response.bodyBytes;
      img.Image image = img.decodeImage(imageData)!;

      // Step 3: Add the discount percentage text
      image = img.drawString(
        image, // The image object
        font, // The BitmapFont loaded earlier
        10, // X position (positional argument, not named)
        10, // Y position (positional argument, not named)
        '$discount% OFF', // Text to draw
        color: img.getColor(
            255, 0, 0), // Color for the text (optional named parameter)
      );

      // Step 4: Add the product name text
      image = img.drawString(
        image, // The image object
        font, // The BitmapFont loaded earlier
        10, // X position (positional argument, not named)
        image.height - 30, // Y position (positional argument, not named)
        productName, // Text to draw
        color: img.getColor(
            255, 255, 255), // Color for the text (optional named parameter)
      );
      // Step 5: Encode the image back to PNG
      Uint8List pngBytes = Uint8List.fromList(img.encodePng(image));

      // Step 6: Upload the image to Firebase Storage (or any other storage)
      FirebaseStorage storage = FirebaseStorage.instance;
      String filePath = 'offers/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(pngBytes);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      // Step 7: Get the download URL of the uploaded image
      String newImageUrl = await snapshot.ref.getDownloadURL();

      return newImageUrl;
    } catch (e) {
      print('Error embedding discount on image: $e');
      rethrow;
    }
  }

  Future<void> _notifyUsers(String offerTitle) async {
    final QuerySnapshot usersSnapshot =
        await _firestore.collection('users').get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      // For example, use user ID to personalize the message or to target specific users
      String userName = userData['name'];

      // Generate a personalized notification message
      String notificationMessage = await _generateNotificationMessage(userName);

      // Send notification
      await _notificationsPlugin.show(
        0, // ID for the notification
        offerTitle, // Title of the notification
        notificationMessage, // Body of the notification
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'offer_channel', // Channel ID
            'Offers', // Channel name
            channelDescription:
                'Channel for offer notifications', // Channel description
          ),
        ),
      );
    }
  }

  Future<String> _generateNotificationMessage(String userName) async {
    try {
      // Define the prompt with the user's name for a personalized message
      String prompt =
          "Generate a creative offer notification message for a user named $userName.";

      // Call ChatGPT API to generate the message
      final response = await http.post(
        Uri.parse(
            'https://api.openai.com/v1/engines/davinci-codex/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
        },
        body: json.encode({
          'prompt': prompt,
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['choices'][0]['text'].trim();
      } else {
        // Log the error and use a fallback message
        print(
            'Failed to generate message. Status code: ${response.statusCode}');
        return _getFallbackMessage(userName);
      }
    } catch (e) {
      // Handle API errors and use fallback message
      print('Error generating message: $e');
      return _getFallbackMessage(userName);
    }
  }

  String _getFallbackMessage(String userName) {
    List<String> messages = [
      "Hey $userName, don't miss out on our exclusive offer!",
      "Special deal just for you, $userName!",
      "Hurry, $userName, limited time offer available now!",
    ];
    messages.shuffle();
    return messages.first;
  }

  bool _checkIfPublicHoliday(DateTime date) {
    List<DateTime> publicHolidays = [
      DateTime(date.year, 1, 1), // New Year's Day
      DateTime(date.year, 4,
          1), // Good Friday (movable, usually first Friday of April)
      DateTime(date.year, 4,
          4), // Easter Monday (movable, usually the first Monday after Good Friday)
      DateTime(date.year, 5, 1), // Labour Day
      DateTime(date.year, 6, 1), // Madaraka Day
      DateTime(date.year, 10, 20), // Mashujaa Day (Heroes' Day)
      DateTime(date.year, 12, 12), // Jamhuri Day (Independence Day)
      DateTime(date.year, 12, 25), // Christmas Day
      DateTime(date.year, 12, 26), // Boxing Day
    ];

    return publicHolidays.contains(DateTime(date.year, date.month, date.day));
  }
}
