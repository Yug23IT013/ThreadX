import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'comments';

  // CREATE - Add new comment to Firestore
  Future<String?> createComment(CommentModel comment) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collectionName).add(comment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating comment: $e');
      rethrow;
    }
  }

  // READ - Get all comments for a thread (Stream for real-time updates)
  Stream<List<CommentModel>> getCommentsByThread(String threadId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('threadId', isEqualTo: threadId)
          .snapshots()
          .map((snapshot) {
        final comments = snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Sort by oldest first
        return comments;
      });
    } catch (e) {
      print('Error getting comments: $e');
      rethrow;
    }
  }

  // READ - Get comments by author
  Stream<List<CommentModel>> getCommentsByAuthor(String authorId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('authorId', isEqualTo: authorId)
          .snapshots()
          .map((snapshot) {
        final comments = snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
        comments.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
        return comments;
      });
    } catch (e) {
      print('Error getting comments by author: $e');
      rethrow;
    }
  }

  // READ - Get single comment by ID
  Future<CommentModel?> getCommentById(String commentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(commentId).get();
      if (doc.exists) {
        return CommentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting comment: $e');
      rethrow;
    }
  }

  // UPDATE - Update existing comment
  Future<void> updateComment(String commentId, String content) async {
    try {
      await _firestore.collection(_collectionName).doc(commentId).update({
        'content': content,
      });
    } catch (e) {
      print('Error updating comment: $e');
      rethrow;
    }
  }

  // DELETE - Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection(_collectionName).doc(commentId).delete();
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  // DELETE - Delete all comments for a thread
  Future<void> deleteCommentsByThread(String threadId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('threadId', isEqualTo: threadId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting comments by thread: $e');
      rethrow;
    }
  }

  // DELETE - Delete all comments by author
  Future<void> deleteCommentsByAuthor(String authorId) async {
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
      print('Error deleting comments by author: $e');
      rethrow;
    }
  }

  // Get comment count for a thread
  Future<int> getCommentCount(String threadId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('threadId', isEqualTo: threadId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting comment count: $e');
      return 0;
    }
  }
}
