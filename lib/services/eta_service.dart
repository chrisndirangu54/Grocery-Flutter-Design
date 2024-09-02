import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ETAService {
  final String apiKey;

  ETAService(this.apiKey);

  Future<Duration> calculateETA(LatLng origin, LatLng destination) async {
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric'
      '&origins=${origin.latitude},${origin.longitude}'
      '&destinations=${destination.latitude},${destination.longitude}'
      '&key=$apiKey',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final durationInSeconds =
          data['rows'][0]['elements'][0]['duration']['value'];
      return Duration(seconds: durationInSeconds);
    } else {
      throw Exception('Failed to calculate ETA');
    }
  }
}
