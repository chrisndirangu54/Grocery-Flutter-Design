import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userData = user.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
                trailing: ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.id)
                        .update({
                      'isRider': true,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${userData['name']} is now a rider!'),
                    ));
                  },
                  child: const Text('Promote to Rider'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
