import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/thread_model.dart';

class ThreadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'threads';

  // CREATE - Add new thread to Firestore
  Future<String?> createThread(ThreadModel thread) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collectionName).add(thread.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating thread: $e');
      rethrow;
    }
  }

  // READ - Get all threads (Stream for real-time updates)
  Stream<List<ThreadModel>> getAllThreads() {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ThreadModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting threads: $e');
      rethrow;
    }
  }

  // READ - Get single thread by ID
  Future<ThreadModel?> getThreadById(String threadId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(threadId).get();
      if (doc.exists) {
        return ThreadModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting thread: $e');
      rethrow;
    }
  }

  // READ - Get threads by author (sorted client-side to avoid index requirement)
  Stream<List<ThreadModel>> getThreadsByAuthor(String authorId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('authorId', isEqualTo: authorId)
          .snapshots()
          .map((snapshot) {
        // Sort on client side to avoid needing a composite index
        final threads = snapshot.docs.map((doc) => ThreadModel.fromFirestore(doc)).toList();
        threads.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
        return threads;
      });
    } catch (e) {
      print('Error getting threads by author: $e');
      rethrow;
    }
  }

  // UPDATE - Update existing thread
  Future<void> updateThread(String threadId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).update(updates);
    } catch (e) {
      print('Error updating thread: $e');
      rethrow;
    }
  }

  // UPDATE - Update thread title and content
  Future<void> updateThreadContent(String threadId, String title, String content) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).update({
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('Error updating thread content: $e');
      rethrow;
    }
  }

  // UPDATE - Increment vote count
  Future<void> upvoteThread(String threadId) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).update({
        'votes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error upvoting thread: $e');
      rethrow;
    }
  }

  // UPDATE - Decrement vote count
  Future<void> downvoteThread(String threadId) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).update({
        'votes': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error downvoting thread: $e');
      rethrow;
    }
  }

  // UPDATE - Increment comment count
  Future<void> incrementCommentCount(String threadId) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing comment count: $e');
      rethrow;
    }
  }

  // DELETE - Delete thread
  Future<void> deleteThread(String threadId) async {
    try {
      await _firestore.collection(_collectionName).doc(threadId).delete();
    } catch (e) {
      print('Error deleting thread: $e');
      rethrow;
    }
  }

  // DELETE - Delete all threads by author (for user cleanup)
  Future<void> deleteThreadsByAuthor(String authorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('authorId', isEqualTo: authorId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting threads by author: $e');
      rethrow;
    }
  }

  // SEARCH - Search threads by title
  Future<List<ThreadModel>> searchThreads(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => ThreadModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching threads: $e');
      rethrow;
    }
  }
}
