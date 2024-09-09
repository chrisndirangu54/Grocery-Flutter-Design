import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';
import '../screens/rider_screen.dart';
import '../screens/add_review_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final ProfileProvider profileProvider;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.profileProvider,
  });

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool deliveryConfirmed = false;

  @override
  void initState() {
    super.initState();
    final order = widget.profileProvider.orders.firstWhere(
      (o) => o.orderId == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    // Start a 24-hour timer if the status is 'Rider has arrived'
    if (order.status == 'Rider has arrived') {
      Future.delayed(const Duration(hours: 24), () {
        if (!deliveryConfirmed) {
          setState(() {
            widget.profileProvider
                .updateOrderStatus(order.orderId, 'Delivered');
          });
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.profileProvider.orders.firstWhere(
      (o) => o.orderId == widget.orderId,
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
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name: ${item.productName}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Price: \$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: item.isReviewed
                            ? null
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddReviewScreen(
                                    productId: item.productId,
                                  ),
                                ));
                              },
                        child:
                            Text(item.isReviewed ? 'Reviewed' : 'Add Review'),
                      ),
                    ],
                  ),
                )),
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
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RiderScreen(
                      orderId: order.orderId,
                      profileProvider: widget.profileProvider,
                    ),
                  ));
                },
                child: const Text('Track Rider'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
                'Estimated Delivery Time: ${order.estimatedDeliveryTime ?? '30-40 minutes'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Rider Contact: ${order.riderContact ?? '+1234567890'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Show buttons when the rider has arrived
            if (order.status == 'Rider has arrived') ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    deliveryConfirmed = true;
                  });
                  widget.profileProvider
                      .updateOrderStatus(order.orderId, 'Delivered');
                },
                child: const Text('Confirm Delivery'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    deliveryConfirmed = true;
                  });
                  widget.profileProvider
                      .updateOrderStatus(order.orderId, 'Not Delivered');
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
