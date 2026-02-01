import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadModel {
  final String? id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final int votes;
  final int commentCount;

  ThreadModel({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    this.votes = 0,
    this.commentCount = 0,
  });

  // Convert ThreadModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'votes': votes,
      'commentCount': commentCount,
    };
  }

  // Create ThreadModel from Firestore Document
  factory ThreadModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ThreadModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      votes: data['votes'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Create ThreadModel from Map
  factory ThreadModel.fromMap(Map<String, dynamic> map, String id) {
    return ThreadModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      votes: map['votes'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
    );
  }

  // Create a copy with updated fields
  ThreadModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    DateTime? createdAt,
    int? votes,
    int? commentCount,
  }) {
    return ThreadModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      votes: votes ?? this.votes,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
