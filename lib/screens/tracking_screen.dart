import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Ensure this import is present
import 'package:grocerry/providers/user_provider.dart';
import '../services/rider_location_service.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final RiderLocationService riderLocationService;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.riderLocationService,
    required UserProvider userProvider,
  });

  @override
  TrackingScreenState createState() => TrackingScreenState();
}

class TrackingScreenState extends State<TrackingScreen> {
  Stream<LatLng> getRiderLocationStream() {
    // Transform the Stream<Position> to Stream<LatLng>
    return widget.riderLocationService
        .getRiderLocationStream(widget.orderId as LocationAccuracy)
        .map((Position position) {
      return LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Rider'),
      ),
      body: StreamBuilder<LatLng>(
        stream: getRiderLocationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching rider location'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No rider location data'));
          }

          final LatLng riderLocation = snapshot.data!;

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: riderLocation,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(widget.orderId),
                position: riderLocation,
                infoWindow: const InfoWindow(title: 'Rider Location'),
              ),
            },
          );
        },
      ),
    );
  }
}
