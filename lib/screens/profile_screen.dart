import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/order_provider.dart';
import '../screens/order_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, profileProvider),
              const SizedBox(height: 20),
              _buildOrdersSection(context, orderProvider),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showUpdateProfileDialog(context, profileProvider);
                },
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name: ${userProvider.name}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Email: ${userProvider.email}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Address: ${userProvider.address}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (userProvider.lastLoginDate != null)
          Text(
            'Last Login: ${userProvider.lastLoginDate}',
            style: const TextStyle(fontSize: 18),
          ),
        const SizedBox(height: 8),
        if (userProvider.profilePictureUrl.isNotEmpty)
          Image.network(userProvider.profilePictureUrl),
      ],
    );
  }

  Widget _buildOrdersSection(
      BuildContext context, OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderProvider.pendingOrders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.pendingOrders[index];
            return ListTile(
              title: Text(order.description),
              subtitle:
                  Text('Price: \$${order.totalAmount.toStringAsFixed(2)}'),
              trailing: Text('Status: ${order.status}'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    orderId: order.id,
                  ),
                ));
              },
            );
          },
        ),
      ],
    );
  }

  void _showUpdateProfileDialog(
      BuildContext context, UserProvider userProvider) {
    final nameController = TextEditingController(text: userProvider.name);
    final emailController = TextEditingController(text: userProvider.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                userProvider.updateProfile(
                  name: nameController.text,
                  email: emailController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
