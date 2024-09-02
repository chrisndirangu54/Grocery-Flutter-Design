import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocerry/providers/profile_provider.dart'; // Adjust import if needed

class TrackingScreen extends StatelessWidget {
  final String orderId;
  final ProfileProvider profileProvider; // Pass the ProfileProvider directly

  const TrackingScreen(
      {super.key, required this.orderId, required this.profileProvider});

  @override
  Widget build(BuildContext context) {
    final order =
        profileProvider.orders.firstWhere((o) => o.orderId == orderId);

    LatLng riderLocation = const LatLng(0, 0);
    final locationParts = order.riderLocation.split(',');
    if (locationParts.length == 2) {
      riderLocation = LatLng(
        double.parse(locationParts[0].trim()),
        double.parse(locationParts[1].trim()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Rider'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: riderLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(orderId),
            position: riderLocation,
            infoWindow: const InfoWindow(title: 'Rider Location'),
          ),
        },
      ),
    );
  }
}
