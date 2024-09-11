import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../services/rider_location_service.dart'; // Add this import
import '../providers/user_provider.dart'; // Add this import
import '../screens/tracking_screen.dart'; // Add this import

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool deliveryConfirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleOrderStatus();
    });
  }

  void _handleOrderStatus() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final order = orderProvider.pendingOrders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    // Start a 24-hour timer if the status is 'Rider has arrived'
    if (order.status == 'Rider has arrived') {
      Future.delayed(const Duration(hours: 24), () {
        if (!deliveryConfirmed) {
          setState(() {
            orderProvider.updateOrderStatus(order.id, 'Delivered');
          });
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delivery Status'),
                content: const Text(
                    'The order has been automatically marked as delivered.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final userProvider = Provider.of<UserProvider>(context); // Get UserProvider
    final riderLocationService = RiderLocationService(); // Create instance

    final order = orderProvider.pendingOrders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description: ${order.description}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Order Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: ${order.status}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (order.status == 'On the way') ...[
              Text('Rider Location: ${order.riderLocation}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to TrackingScreen with necessary parameters
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TrackingScreen(
                      orderId: order.id,
                      userProvider: userProvider,
                      riderLocationService: riderLocationService,
                    ),
                  ));
                },
                child: const Text('Track Rider'),
              ),
            ],
            const SizedBox(height: 16),
            if (order.status == 'Rider has arrived') ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    deliveryConfirmed = true;
                  });
                  orderProvider.updateOrderStatus(order.id, 'Delivered');
                },
                child: const Text('Confirm Delivery'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    deliveryConfirmed = true;
                  });
                  orderProvider.updateOrderStatus(order.id, 'Not Delivered');
                },
                child: const Text('Was Not Delivered'),
              ),
              const SizedBox(height: 8),
              const Text(
                  'If no action is taken within 24 hours, the order will be automatically marked as delivered.',
                  style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
