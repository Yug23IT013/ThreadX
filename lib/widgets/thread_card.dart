import 'package:flutter/material.dart';
import '../models/thread_model.dart';
import '../config/theme.dart';
import '../services/vote_service.dart';

/// Reusable Thread Card Widget for displaying thread information
/// Demonstrates Card layout implementation for Lab 7
class ThreadCard extends StatelessWidget {
  final ThreadModel thread;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showVoteButtons;

  const ThreadCard({
    super.key,
    required this.thread,
    this.currentUserId,
    required this.onTap,
    this.onLongPress,
    this.showVoteButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final VoteService voteService = VoteService();
    final bool isAuthor = currentUserId == thread.authorId;
    final String timeAgo = _getTimeAgo(thread.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vote section (optional)
              if (showVoteButtons) ...[
                StreamBuilder<String?>(
                  stream: voteService.getVoteStream(
                    thread.id!,
                    currentUserId ?? '',
                  ),
                  builder: (context, voteSnapshot) {
                    final userVote = voteSnapshot.data;
                    return Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward, size: 20),
                          onPressed: currentUserId != null
                              ? () => voteService.voteThread(
                                    thread.id!,
                                    currentUserId!,
                                    'upvote',
                                  )
                              : null,
                          color: userVote == 'upvote'
                              ? Colors.orange
                              : AppTheme.textSecondary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          thread.votes.toString(),
                          style: TextStyle(
                            color: userVote == 'upvote'
                                ? Colors.orange
                                : userVote == 'downvote'
                                    ? Colors.blue
                                    : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward, size: 20),
                          onPressed: currentUserId != null
                              ? () => voteService.voteThread(
                                    thread.id!,
                                    currentUserId!,
                                    'downvote',
                                  )
                              : null,
                          color: userVote == 'downvote'
                              ? Colors.blue
                              : AppTheme.textSecondary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 12),
              ],
              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author and time row
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: AppTheme.accentWhite,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            thread.authorId,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (isAuthor) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                color: AppTheme.accentBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Thread title
                    Text(
                      thread.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Thread content preview
                    if (thread.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        thread.content,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Action buttons row
                    Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${thread.commentCount} comments",
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Share",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
