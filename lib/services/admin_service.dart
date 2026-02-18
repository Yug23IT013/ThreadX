import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isAdmin'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    try {
      return _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting users: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Delete user account (admin only)
  Future<bool> deleteUserAccount(String userId) async {
    try {
      // Delete all threads by this user
      final threadsSnapshot = await _firestore
          .collection('threads')
          .where('authorId', isEqualTo: userId)
          .get();

      for (var doc in threadsSnapshot.docs) {
        await _deleteThreadWithComments(doc.id);
      }

      // Delete all comments by this user
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('authorId', isEqualTo: userId)
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      return true;
    } catch (e) {
      print('Error deleting user account: $e');
      return false;
    }
  }

  // Delete thread (admin can delete any thread)
  Future<bool> deleteThread(String threadId) async {
    try {
      await _deleteThreadWithComments(threadId);
      return true;
    } catch (e) {
      print('Error deleting thread: $e');
      return false;
    }
  }

  // Helper method to delete thread with all its comments
  Future<void> _deleteThreadWithComments(String threadId) async {
    // Delete all comments for this thread
    final commentsSnapshot = await _firestore
        .collection('comments')
        .where('threadId', isEqualTo: threadId)
        .get();

    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the thread
    await _firestore.collection('threads').doc(threadId).delete();
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final threadsCount = await _firestore
          .collection('threads')
          .where('authorId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final commentsCount = await _firestore
          .collection('comments')
          .where('authorId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      return {
        'threads': threadsCount,
        'comments': commentsCount,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'threads': 0, 'comments': 0};
    }
  }

  // Make user admin (super admin only)
  Future<bool> makeUserAdmin(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
      });
      return true;
    } catch (e) {
      print('Error updating admin status: $e');
      return false;
    }
  }

  // Get app statistics
  Future<Map<String, int>> getAppStats() async {
    try {
      final usersCount = await _firestore
          .collection('users')
          .get()
          .then((snapshot) => snapshot.docs.length);

      final threadsCount = await _firestore
          .collection('threads')
          .get()
          .then((snapshot) => snapshot.docs.length);

      final commentsCount = await _firestore
          .collection('comments')
          .get()
          .then((snapshot) => snapshot.docs.length);

      return {
        'users': usersCount,
        'threads': threadsCount,
        'comments': commentsCount,
      };
    } catch (e) {
      print('Error getting app stats: $e');
      return {'users': 0, 'threads': 0, 'comments': 0};
    }
  }
}
