// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'password_retrieval_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                      return 'Please enter a valid contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .login(_emailController.text, _passwordController.text);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed')));
                }
              }
            },
            label: const Text('Login'),
            icon: const Icon(Icons.login),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/register');
            },
            label: const Text('Register'),
            icon: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PasswordRetrievalScreen()));
            },
            label: const Text('Forgot Password?'),
            icon: const Icon(Icons.lock_reset),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
