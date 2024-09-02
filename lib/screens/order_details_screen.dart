import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../screens/tracking_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final order =
        profileProvider.orders.firstWhere((o) => o.orderId == orderId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Name: ${order.productName}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Price: \$${order.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Status: ${order.status}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (order.status == 'On the way') ...[
              Text('Rider Location: ${order.riderLocation}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TrackingScreen(
                      orderId: order.orderId,
                      profileProvider:
                          profileProvider, // Pass the actual ProfileProvider instance
                    ),
                  ));
                },
                child: const Text('Track Rider'),
              ),
            ],
            const SizedBox(height: 8),
            const Text('Estimated Delivery Time: 30-40 minutes',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Rider Contact: +1234567890',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
