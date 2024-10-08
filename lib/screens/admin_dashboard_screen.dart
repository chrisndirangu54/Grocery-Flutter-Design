import 'package:flutter/material.dart';
import 'admin_add_product_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_offers_screen.dart';
import 'pending_deliveries_screen.dart'; // Import for pending deliveries screen
import '../screens/all_orders_screen.dart'; // Import for all orders screen

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.orange, // Match your app theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Admin Actions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Manage Users Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminUserManagementScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Manage Users'),
            ),
            const SizedBox(height: 20),
            // Add Products Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAddProductScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Add Products'),
            ),
            const SizedBox(height: 20),
            // Create Offers Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminOffersScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Create Offers'),
            ),
            const SizedBox(height: 20),
            // Pending Deliveries Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingDeliveriesScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Pending Deliveries'),
            ),
            const SizedBox(height: 20),
            // View All Orders Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllOrdersScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('View All Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
