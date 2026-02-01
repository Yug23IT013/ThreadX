import 'package:cloud_firestore/cloud_firestore.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'votes';

  // Check if user has voted on a thread
  Future<String?> getUserVote(String threadId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc('${threadId}_$userId')
          .get();
      
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['voteType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user vote: $e');
      return null;
    }
  }

  // Vote on a thread (upvote or downvote)
  Future<void> voteThread(String threadId, String userId, String voteType) async {
    try {
      final docId = '${threadId}_$userId';
      final voteDoc = _firestore.collection(_collectionName).doc(docId);
      final threadDoc = _firestore.collection('threads').doc(threadId);

      // Get current vote
      final currentVote = await getUserVote(threadId, userId);

      if (currentVote == voteType) {
        // Remove vote if clicking same button
        await voteDoc.delete();
        await threadDoc.update({
          'votes': FieldValue.increment(voteType == 'upvote' ? -1 : 1),
        });
      } else if (currentVote != null) {
        // Change vote
        await voteDoc.update({'voteType': voteType});
        await threadDoc.update({
          'votes': FieldValue.increment(voteType == 'upvote' ? 2 : -2),
        });
      } else {
        // New vote
        await voteDoc.set({
          'threadId': threadId,
          'userId': userId,
          'voteType': voteType,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await threadDoc.update({
          'votes': FieldValue.increment(voteType == 'upvote' ? 1 : -1),
        });
      }
    } catch (e) {
      print('Error voting on thread: $e');
      rethrow;
    }
  }

  // Get vote status stream for real-time updates
  Stream<String?> getVoteStream(String threadId, String userId) {
    return _firestore
        .collection(_collectionName)
        .doc('${threadId}_$userId')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['voteType'] as String?;
      }
      return null;
    });
  }
}
