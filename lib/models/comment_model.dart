import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;
  final String content;
  final String authorId;
  final String threadId;
  final DateTime createdAt;

  CommentModel({
    this.id,
    required this.content,
    required this.authorId,
    required this.threadId,
    required this.createdAt,
  });

  // Convert CommentModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'authorId': authorId,
      'threadId': threadId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create CommentModel from Firestore Document
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      threadId: data['threadId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create CommentModel from Map
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      threadId: map['threadId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  CommentModel copyWith({
    String? id,
    String? content,
    String? authorId,
    String? threadId,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      threadId: threadId ?? this.threadId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
