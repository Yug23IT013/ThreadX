import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../services/thread_service.dart';
import '../../services/admin_service.dart';
import '../../models/thread_model.dart';
import '../../widgets/thread_card.dart';
import '../dashboard/thread_detail_screen.dart';

class AllThreadsScreen extends StatefulWidget {
  const AllThreadsScreen({super.key});

  @override
  State<AllThreadsScreen> createState() => _AllThreadsScreenState();
}

class _AllThreadsScreenState extends State<AllThreadsScreen> {
  final ThreadService _threadService = ThreadService();
  final AdminService _adminService = AdminService();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Threads'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<ThreadModel>>(
        stream: _threadService.getAllThreads(),
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
              child: Text(
                'No threads found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final threads = snapshot.data!;

          return ListView.builder(
            itemCount: threads.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return ThreadCard(
                thread: thread,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreadDetailScreen(
                        threadId: thread.id!,
                        thread: thread,
                      ),
                    ),
                  );
                },
                onLongPress: () => _showAdminThreadOptions(context, thread),
              );
            },
          );
        },
      ),
    );
  }

  void _showAdminThreadOptions(BuildContext context, ThreadModel thread) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: AppTheme.accentBlue),
              title: const Text(
                'View Thread',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThreadDetailScreen(
                      threadId: thread.id!,
                      thread: thread,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Thread (Admin)',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteThread(thread);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteThread(ThreadModel thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Delete Thread',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${thread.title}"?\n\n'
          'This will also delete all comments on this thread.\n\n'
          'This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final success = await _adminService.deleteThread(thread.id!);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Thread deleted successfully'
                  : 'Failed to delete thread',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
