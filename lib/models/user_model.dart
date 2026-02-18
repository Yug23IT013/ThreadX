import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final bool isAdmin;
  final int threadCount;
  final int commentCount;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.isAdmin = false,
    this.threadCount = 0,
    this.commentCount = 0,
  });

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAdmin: data['isAdmin'] ?? false,
      threadCount: data['threadCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
      'threadCount': threadCount,
      'commentCount': commentCount,
    };
  }
}
