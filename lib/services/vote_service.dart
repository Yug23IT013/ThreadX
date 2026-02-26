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

      // Get thread data to find author
      final threadSnapshot = await threadDoc.get();
      if (!threadSnapshot.exists) {
        throw Exception('Thread not found');
      }
      final threadData = threadSnapshot.data() as Map<String, dynamic>;
      final authorId = threadData['authorId'] as String;

      // Get current vote
      final currentVote = await getUserVote(threadId, userId);

      // Don't let users vote on their own posts
      if (authorId == userId) {
        print('⚠️ Users cannot vote on their own posts');
        return;
      }

      int karmaChange = 0;

      if (currentVote == voteType) {
        // Remove vote if clicking same button
        await voteDoc.delete();
        await threadDoc.update({
          'votes': FieldValue.increment(voteType == 'upvote' ? -1 : 1),
        });
        // Reverse karma change
        karmaChange = voteType == 'upvote' ? -1 : 1;
      } else if (currentVote != null) {
        // Change vote
        await voteDoc.update({'voteType': voteType});
        await threadDoc.update({
          'votes': FieldValue.increment(voteType == 'upvote' ? 2 : -2),
        });
        // Karma change from switching vote
        karmaChange = voteType == 'upvote' ? 2 : -2;
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
        // New karma from new vote
        karmaChange = voteType == 'upvote' ? 1 : -1;
      }

      // Update author's karma
      if (karmaChange != 0) {
        await _firestore.collection('users').doc(authorId).update({
          'karma': FieldValue.increment(karmaChange),
        });
        print('✅ Updated karma for $authorId by $karmaChange');
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
