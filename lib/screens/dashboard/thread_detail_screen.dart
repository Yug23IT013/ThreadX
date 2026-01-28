import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ThreadDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String time;
  final int votes;
  final int comments;

  const ThreadDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.time,
    required this.votes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thread"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Thread Post
                Container(
                  color: AppTheme.cardBackground,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.accentWhite,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            author,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "This is the thread content where users can share their thoughts, questions, and discussions about various topics. The content can be as detailed as needed.",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward, size: 20),
                            onPressed: () {},
                            color: AppTheme.textSecondary,
                          ),
                          Text(
                            votes.toString(),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward, size: 20),
                            onPressed: () {},
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.comment_outlined,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$comments",
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                // Comments Section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "$comments Comments",
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildComment(
                  author: "u/dev_enthusiast",
                  time: "1h ago",
                  content: "Great question! I'd recommend starting with the official Flutter documentation and building small projects.",
                  votes: 45,
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                _buildComment(
                  author: "u/flutter_pro",
                  time: "3h ago",
                  content: "Don't forget to check out the Flutter widget catalog. It's incredibly helpful for understanding layouts.",
                  votes: 23,
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                _buildComment(
                  author: "u/code_ninja",
                  time: "5h ago",
                  content: "I've been using Flutter for 2 years now. Happy to answer any specific questions!",
                  votes: 18,
                ),
              ],
            ),
          ),
          // Reply Input
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.cardBackground,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.accentWhite,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                  color: AppTheme.accentWhite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment({
    required String author,
    required String time,
    required String content,
    required int votes,
  }) {
    return Container(
      color: AppTheme.cardBackground,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: () {},
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                votes.toString(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: () {},
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.reply,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      label: const Text(
                        "Reply",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
