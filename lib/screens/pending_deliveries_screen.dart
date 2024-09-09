import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/order_details_screen.dart';

class PendingDeliveriesScreen extends StatelessWidget {
  const PendingDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user =
        profileProvider.currentUser; // Assume currentUser is of type User

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Deliveries'),
      ),
      body: orderProvider.pendingOrders.isEmpty
          ? const Center(child: Text('No pending deliveries'))
          : ListView.builder(
              itemCount: orderProvider.pendingOrders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.pendingOrders[index];
                return ListTile(
                  title: Text(order.description),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${order.status}'),
                      Row(
                        children: [
                          if (user.isRider) ...[
                            if (order.status == 'Ready for Delivery') ...[
                              ElevatedButton(
                                onPressed: () {
                                  orderProvider.updateOrderStatus(
                                      order.id, 'On the way');
                                },
                                child: const Text('Start Delivery'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  orderProvider.updateOrderStatus(
                                      order.id, 'Rider has arrived');
                                },
                                child: const Text('Confirm Arrival'),
                              ),
                            ],
                            if (order.status == 'Rider has arrived') ...[
                              ElevatedButton(
                                onPressed: () {
                                  // Handle confirm delivery logic
                                  orderProvider.updateOrderStatus(
                                      order.id, 'Delivered');
                                },
                                child: const Text('Confirm Delivery'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle was not delivered logic
                                  orderProvider.updateOrderStatus(
                                      order.id, 'Not Delivered');
                                },
                                child: const Text('Was Not Delivered'),
                              ),
                            ],
                          ] else if (!user.isRider) ...[
                            if (order.status == 'Pending') ...[
                              ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text(
                                          'Are you sure you want to mark this order as preparing?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    orderProvider.updateOrderStatus(
                                        order.id, 'Preparing');
                                  }
                                },
                                child: const Text('Confirm Preparing'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text(
                                          'Are you sure you want to mark this order as ready for delivery?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    orderProvider.updateOrderStatus(
                                        order.id, 'Ready for Delivery');
                                  }
                                },
                                child: const Text('Confirm Ready for Delivery'),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                        orderId: order.id,
                        profileProvider: profileProvider,
                      ),
                    ));
                  },
                );
              },
            ),
    );
  }
}
