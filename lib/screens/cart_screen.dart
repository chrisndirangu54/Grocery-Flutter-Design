import 'package:flutter/material.dart';
import 'package:grocerry/providers/order_provider.dart';
import 'package:grocerry/screens/pending_deliveries_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _selectPaymentMethod() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Visa/MasterCard'),
                onTap: () {
                  Navigator.of(context).pop();
                  _processVisaMasterCardPayment();
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('M-Pesa Paybill'),
                onTap: () {
                  Navigator.of(context).pop();
                  _processMpesaPayment();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processVisaMasterCardPayment() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    try {
      // Integrate your payment gateway SDK here
      // Example: Stripe/PayPal API for processing Visa/MasterCard payments.

      // Mocking the process for demonstration
      final response = await Future.delayed(
          const Duration(seconds: 2), () => {'status': 'success'});

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSuccessDialog('Payment Successful');
        cart.clearCart();
      } else {
        _showErrorSnackBar('Payment Failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Payment Failed');
    }
  }

  Future<void> _processMpesaPayment() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount;

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('initiateMpesaPayment');
      final response = await callable.call({
        'amount': totalAmount,
        'phoneNumber': '2547XXXXXXXX', // Replace with the actual phone number
        'paybillNumber': '123456', // Replace with actual Paybill Number
        'accountNumber':
            'YourAccountNumber', // Replace with your Account Number
      });

      if (!mounted) return;

      if (response.data['status'] == 'success') {
        _showSuccessDialog('M-Pesa Payment Initiated');
        cart.clearCart();
      } else {
        _showErrorSnackBar('M-Pesa Payment Failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('M-Pesa Payment Failed');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // Assuming we add the order to pending deliveries after checkout
              Provider.of<OrderProvider>(context, listen: false).addOrder(
                Order(
                  id: '126', // Generate a real order ID
                  description: 'New Order - Your Cart Description',
                  status: 'Pending',
                ),
              );

              Navigator.of(ctx).pop();
              // Navigate to Pending Deliveries Screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const PendingDeliveriesScreen(),
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
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
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text('Total: \$${cart.totalAmount}',
                style: const TextStyle(fontSize: 24)),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _selectPaymentMethod,
          label: const Text('Checkout'),
          icon: const Icon(Icons.payment),
        ),
      ),
    );
  }
}
