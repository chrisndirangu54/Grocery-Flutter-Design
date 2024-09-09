import 'package:flutter/material.dart';
import 'package:grocerry/providers/profile_provider.dart';
import 'package:provider/provider.dart';

import 'package:grocerry/screens/order_details_screen.dart';
// ignore: unused_import
import 'package:grocerry/screens/tracking_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

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
              _buildOrdersSection(context, profileProvider),
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

  Widget _buildProfileHeader(
      BuildContext context, ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name: ${profileProvider.name}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Email: ${profileProvider.email}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Address: ${profileProvider.address}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (profileProvider.lastLoginDate != null)
          Text(
            'Last Login: ${profileProvider.lastLoginDate}',
            style: const TextStyle(fontSize: 18),
          ),
        const SizedBox(height: 8),
        if (profileProvider.profilePictureUrl.isNotEmpty)
          Image.network(profileProvider.profilePictureUrl),
      ],
    );
  }

  Widget _buildOrdersSection(
      BuildContext context, ProfileProvider profileProvider) {
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
          itemCount: profileProvider.orders.length,
          itemBuilder: (context, index) {
            final order = profileProvider.orders[index];
            return ListTile(
              title: Text(order.productName),
              subtitle: Text('Price: \$${order.price.toStringAsFixed(2)}'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Status: ${order.status}'),
                  if (order.status == 'On the way')
                    Text('Rider Location: ${order.riderLocation}'),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    orderId: order.orderId,
                    profileProvider: profileProvider,
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
      BuildContext context, ProfileProvider profileProvider) {
    final nameController = TextEditingController(text: profileProvider.name);
    final emailController = TextEditingController(text: profileProvider.email);

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
                profileProvider.updateProfile(
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
