import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ignore: unused_field
  late bool _isAdminRegistered;

  User? user() => _user;

  // Login using Firebase Authentication
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Register a new user and store extra fields in Firestore
  Future<void> register(
      String email, String password, String contact, bool isAdmin) async {
    try {
      // Create the user using Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Store additional data in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'contact': contact,
        'isAdmin': isAdmin,
        'createdAt': Timestamp.now(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Logout the user
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
