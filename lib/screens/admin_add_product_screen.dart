import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  AdminAddProductScreenState createState() => AdminAddProductScreenState();
}

class AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  void _addProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': _imageUrlController.text,
      });

      // Clear fields after adding product
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();

      if (!mounted) {
        return; // Ensure the widget is still in the tree before using the context
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product added!')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
