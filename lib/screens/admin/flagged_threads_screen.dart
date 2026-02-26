import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../services/thread_service.dart';
import '../../models/thread_model.dart';

class FlaggedThreadsScreen extends StatefulWidget {
  const FlaggedThreadsScreen({super.key});

  @override
  State<FlaggedThreadsScreen> createState() => _FlaggedThreadsScreenState();
}

class _FlaggedThreadsScreenState extends State<FlaggedThreadsScreen> {
  final ThreadService _threadService = ThreadService();

  Future<void> _approveThread(ThreadModel thread) async {
    try {
      await _threadService.approveThread(thread.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thread approved and published'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving thread: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectThread(ThreadModel thread) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Reject Thread?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will permanently delete the thread. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _threadService.rejectThread(thread.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thread rejected and deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rejecting thread: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String> _getAuthorName(String authorId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['displayName'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error getting author name: $e');
    }
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flagged Posts'),
        backgroundColor: Colors.orange.shade900,
      ),
      body: StreamBuilder<List<ThreadModel>>(
        stream: _threadService.getPendingThreads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No flagged posts!',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All posts are currently approved',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final flaggedThreads = snapshot.data!;

          return ListView.builder(
            itemCount: flaggedThreads.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final thread = flaggedThreads[index];
              return Card(
                color: AppTheme.cardBackground,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                thread.flagReason ?? 'Flagged for review',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Author info
                      FutureBuilder<String>(
                        future: _getAuthorName(thread.authorId),
                        builder: (context, authorSnapshot) {
                          return Text(
                            'u/${authorSnapshot.data ?? 'loading...'}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        thread.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Content
                      if (thread.content.isNotEmpty)
                        Text(
                          thread.content,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 16),

                      // Flagged keywords
                      if (thread.flaggedKeywords != null &&
                          thread.flaggedKeywords!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: thread.flaggedKeywords!.map((keyword) {
                            return Chip(
                              label: Text(
                                keyword,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.red.withOpacity(0.2),
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.all(4),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approveThread(thread),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectThread(thread),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
