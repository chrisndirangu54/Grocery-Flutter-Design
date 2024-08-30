import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _initiatePayment(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount;

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('initiatePayment');
      final response = await callable.call({
        'amount': totalAmount,
        'phoneNumber': '2547XXXXXXXX' // Replace with the actual phone number
      });

      // Handle successful payment initiation
      print('Payment initiated: ${response.data}');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Initiated'),
          content: const Text('Please follow the instructions to complete your payment.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                cart.clearCart();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle errors
      print('Error initiating payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(cart.items.values.toList()[i].product.name),
                  subtitle: Text(
                      'Quantity: ${cart.items.values.toList()[i].quantity}'),
                  trailing: Text(
                      '\$${cart.items.values.toList()[i].product.price * cart.items.values.toList()[i].quantity}'),
                  onTap: () {
                    cart.removeItem(cart.items.keys.toList()[i]);
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text('Total: \$${cart.totalAmount}',
                style: const TextStyle(fontSize: 24)),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _initiatePayment(context);
          },
          label: const Text('Checkout'),
          icon: const Icon(Icons.payment),
        ),
      ),
    );
  }
}
