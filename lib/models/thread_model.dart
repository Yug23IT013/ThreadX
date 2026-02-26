import 'package:cloud_firestore/cloud_firestore.dart';

enum ThreadStatus {
  pending,   // Flagged, awaiting admin review
  approved,  // Approved by admin or auto-approved (no flags)
  rejected   // Rejected by admin
}

class ThreadModel {
  final String? id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final int votes;
  final int commentCount;
  final ThreadStatus status;
  final String? flagReason;
  final List<String>? flaggedKeywords;

  ThreadModel({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    this.votes = 0,
    this.commentCount = 0,
    this.status = ThreadStatus.approved,
    this.flagReason,
    this.flaggedKeywords,
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
      'status': status.name,
      'flagReason': flagReason,
      'flaggedKeywords': flaggedKeywords,
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
      status: _stringToStatus(data['status']),
      flagReason: data['flagReason'],
      flaggedKeywords: data['flaggedKeywords'] != null 
          ? List<String>.from(data['flaggedKeywords']) 
          : null,
    );
  }

  // Helper method to convert string to ThreadStatus
  static ThreadStatus _stringToStatus(String? status) {
    switch (status) {
      case 'pending':
        return ThreadStatus.pending;
      case 'rejected':
        return ThreadStatus.rejected;
      case 'approved':
      default:
        return ThreadStatus.approved;
    }
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
      status: _stringToStatus(map['status']),
      flagReason: map['flagReason'],
      flaggedKeywords: map['flaggedKeywords'] != null 
          ? List<String>.from(map['flaggedKeywords']) 
          : null,
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
    ThreadStatus? status,
    String? flagReason,
    List<String>? flaggedKeywords,
  }) {
    return ThreadModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      votes: votes ?? this.votes,
      commentCount: commentCount ?? this.commentCount,
      status: status ?? this.status,
      flagReason: flagReason ?? this.flagReason,
      flaggedKeywords: flaggedKeywords ?? this.flaggedKeywords,
    );
  }
}
