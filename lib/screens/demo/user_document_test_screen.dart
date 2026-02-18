import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';

/// Temporary test screen to verify user document creation
/// Remove this screen after verifying everything works
class UserDocumentTestScreen extends StatefulWidget {
  const UserDocumentTestScreen({super.key});

  @override
  State<UserDocumentTestScreen> createState() => _UserDocumentTestScreenState();
}

class _UserDocumentTestScreenState extends State<UserDocumentTestScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _status = 'Ready to test';
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkUserDocument();
  }

  Future<void> _checkUserDocument() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking user document...';
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _status = '❌ No user logged in';
          _isLoading = false;
        });
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _status = '✅ User document exists!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '⚠️ User document does NOT exist';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createUserDocument() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating user document...';
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _status = '❌ No user logged in';
          _isLoading = false;
        });
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email!,
        'displayName': user.displayName ?? user.email!.split('@')[0],
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'threadCount': 0,
        'commentCount': 0,
      });

      setState(() {
        _status = '✅ User document created successfully!';
        _isLoading = false;
      });

      // Recheck after creation
      await Future.delayed(const Duration(seconds: 1));
      _checkUserDocument();
    } catch (e) {
      setState(() {
        _status = '❌ Error creating document: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makeAdmin() async {
    setState(() {
      _isLoading = true;
      _status = 'Making user admin...';
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _status = '❌ No user logged in';
          _isLoading = false;
        });
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'isAdmin': true,
      });

      setState(() {
        _status = '✅ User is now an admin! Restart the app.';
        _isLoading = false;
      });

      _checkUserDocument();
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Document Test'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Testing Tool - Remove after verification',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current User Info
            Card(
              color: AppTheme.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'Not logged in',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UID: ${user?.uid ?? 'N/A'}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Display
            Card(
              color: AppTheme.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _status.startsWith('✅')
                            ? Colors.green
                            : _status.startsWith('❌')
                                ? Colors.red
                                : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Data Display
            if (_userData != null)
              Card(
                color: AppTheme.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Document Data:',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._userData!.entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: const TextStyle(
                                    color: AppTheme.accentBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _checkUserDocument,
                icon: const Icon(Icons.refresh),
                label: const Text('Check User Document'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _createUserDocument,
                icon: const Icon(Icons.add),
                label: const Text('Create User Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _makeAdmin,
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Make Me Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Click "Check User Document" to verify\n'
                    '2. If missing, click "Create User Document"\n'
                    '3. Click "Make Me Admin" to test admin features\n'
                    '4. Restart app after making admin\n'
                    '5. Remove this screen after testing',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
