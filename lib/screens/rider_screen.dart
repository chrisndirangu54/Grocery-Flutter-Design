import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import '../providers/profile_provider.dart';

class RiderScreen extends StatefulWidget {
  final String orderId;
  final ProfileProvider profileProvider;

  const RiderScreen({
    super.key,
    required this.orderId,
    required this.profileProvider,
  });

  @override
  RiderScreenState createState() => RiderScreenState();
}

class RiderScreenState extends State<RiderScreen> {
  late GoogleMapController mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  late DatabaseReference riderLocationRef;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _listenToRiderLocationUpdates();
  }

  void _initializeMap() {
    final order = widget.profileProvider.orders
        .firstWhere((o) => o.orderId == widget.orderId);

    final LatLng deliveryAddress =
        LatLng(order.deliveryLatitude, order.deliveryLongitude);

    _markers.add(Marker(
      markerId: const MarkerId('deliveryAddress'),
      position: deliveryAddress,
      infoWindow: const InfoWindow(title: 'Delivery Address'),
    ));

    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(order.riderLatitude, order.riderLongitude),
        deliveryAddress
      ],
      color: Colors.blue,
      width: 5,
    ));
  }

  void _listenToRiderLocationUpdates() {
    final order = widget.profileProvider.orders
        .firstWhere((o) => o.orderId == widget.orderId);

    riderLocationRef = FirebaseDatabase.instance
        .reference()
        .child('rider_locations')
        .child(order.orderId);

    riderLocationRef.onValue.listen((event) {
      final data = event.snapshot.value as Map;
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];

      setState(() {
        _updateRiderLocationOnMap(LatLng(latitude, longitude));
      });
    });
  }

  void _updateRiderLocationOnMap(LatLng newLocation) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'riderLocation');
      _markers.add(Marker(
        markerId: const MarkerId('riderLocation'),
        position: newLocation,
        infoWindow: const InfoWindow(title: 'Rider Location'),
      ));

      final order = widget.profileProvider.orders
          .firstWhere((o) => o.orderId == widget.orderId);

      _polylines.removeWhere((p) => p.polylineId.value == 'route');
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [
          newLocation,
          LatLng(order.deliveryLatitude, order.deliveryLongitude)
        ],
        color: Colors.blue,
        width: 5,
      ));

      mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
    });
  }

  @override
  void dispose() {
    riderLocationRef
        .onDisconnect(); // Stop listening to location updates when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              widget.profileProvider.orders
                  .firstWhere((o) => o.orderId == widget.orderId)
                  .riderLatitude,
              widget.profileProvider.orders
                  .firstWhere((o) => o.orderId == widget.orderId)
                  .riderLongitude),
          zoom: 14.0,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}

extension on FirebaseDatabase {
  reference() {}
}
