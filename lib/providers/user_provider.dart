import 'package:flutter/material.dart';
import '../screens/admin_user_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminUserManagementScreen(),
                  ),
                );
              },
              child: const Text('Manage Users'),
            ),
            // Add more admin actions here
          ],
        ),
      ),
    );
  }
}
