import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter for the current user
  User? get user => _user;

  // Check if a user is logged in
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Initialize the user state on startup
    _initializeUser();
  }

  // Initialize user state
  void _initializeUser() {
    _user = _auth.currentUser;
    notifyListeners();
  }

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
      _handleAuthError(e);
    }
  }

  // Register a new user and store extra fields in Firestore
  Future<void> register(
      String email, String password, String contact, bool isAdmin) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      if (_user != null) {
        // Store additional user data in Firestore
        await _firestore.collection('users').doc(_user!.uid).set({
          'email': email,
          'contact': contact,
          'isAdmin': isAdmin,
          'createdAt': Timestamp.now(),
        });

        notifyListeners();
      } else {
        throw Exception('User creation failed.');
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  // Logout the user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  // Private method to handle authentication errors
  void _handleAuthError(Object error) {
    String errorMessage;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
    } else {
      errorMessage = 'An error occurred. Please try again later.';
    }

    // Optionally notify listeners about the error
    notifyListeners();
    throw Exception(errorMessage);
  }
}
