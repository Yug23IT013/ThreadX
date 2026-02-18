import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.reload();
      _user = _auth.currentUser;

      // Save user data to Firestore
      if (_user != null) {
        try {
          await _firestore.collection('users').doc(_user!.uid).set({
            'email': email,
            'displayName': username,
            'createdAt': FieldValue.serverTimestamp(),
            'isAdmin': false, // New users are not admin by default
            'threadCount': 0,
            'commentCount': 0,
          });
          print('✅ User document created successfully for ${_user!.uid}');
        } catch (firestoreError) {
          print('❌ Error creating user document: $firestoreError');
          // Continue even if Firestore fails - user is still authenticated
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _handleAuthException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      print('❌ Registration error: $e');
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = _auth.currentUser;

      // Ensure user document exists in Firestore
      if (_user != null) {
        try {
          final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
          if (!userDoc.exists) {
            // Create user document if it doesn't exist (for existing accounts)
            await _firestore.collection('users').doc(_user!.uid).set({
              'email': _user!.email ?? email,
              'displayName': _user!.displayName ?? email.split('@')[0],
              'createdAt': FieldValue.serverTimestamp(),
              'isAdmin': false,
              'threadCount': 0,
              'commentCount': 0,
            });
            print('✅ User document created for existing user ${_user!.uid}');
          } else {
            print('✅ User document already exists for ${_user!.uid}');
          }
        } catch (firestoreError) {
          print('❌ Error checking/creating user document: $firestoreError');
          // Continue even if Firestore fails - user is still authenticated
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _handleAuthException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
      _user = null;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _handleAuthException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send reset email';
      notifyListeners();
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        _errorMessage = 'The password provided is too weak';
        break;
      case 'email-already-in-use':
        _errorMessage = 'An account already exists with this email';
        break;
      case 'invalid-email':
        _errorMessage = 'The email address is invalid';
        break;
      case 'user-not-found':
        _errorMessage = 'No user found with this email';
        break;
      case 'wrong-password':
        _errorMessage = 'Wrong password provided';
        break;
      case 'invalid-credential':
        _errorMessage = 'Invalid credentials. Please check your email and password';
        break;
      case 'network-request-failed':
        _errorMessage = 'Network error. Please check your connection';
        break;
      default:
        _errorMessage = e.message ?? 'An authentication error occurred';
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
