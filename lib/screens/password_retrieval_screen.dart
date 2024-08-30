import 'package:flutter/material.dart';

class PasswordRetrievalScreen extends StatefulWidget {
  @override
  _PasswordRetrievalScreenState createState() => _PasswordRetrievalScreenState();
}

class _PasswordRetrievalScreenState extends State<PasswordRetrievalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Retrieval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your email to retrieve your password', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Simulate sending password retrieval email
                    try {
                      // Implement your backend password retrieval logic here
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password retrieval email sent')));
                      Navigator.of(context).pop(); // Go back to the login screen
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password retrieval failed')));
                    }
                  }
                },
                child: Text('Retrieve Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
