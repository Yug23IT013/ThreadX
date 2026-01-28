import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'search_screen.dart';
import 'create_thread_screen.dart';
import 'thread_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ThreadX"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildPostCard(
            context: context,
            title: "How to use Flutter layouts?",
            author: "u/flutter_dev",
            time: "2h ago",
            votes: 234,
            comments: 20,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildPostCard(
            context: context,
            title: "Best way to manage state?",
            author: "u/state_master",
            time: "5h ago",
            votes: 156,
            comments: 15,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildPostCard(
            context: context,
            title: "Flutter 4.0 announced with amazing new features!",
            author: "u/tech_news",
            time: "8h ago",
            votes: 892,
            comments: 67,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildPostCard(
            context: context,
            title: "Tips for building responsive mobile apps",
            author: "u/mobile_guru",
            time: "12h ago",
            votes: 421,
            comments: 34,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateThreadScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required String title,
    required String author,
    required String time,
    required int votes,
    required int comments,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadDetailScreen(
              title: title,
              author: author,
              time: time,
              votes: votes,
              comments: comments,
            ),
          ),
        );
      },
      child: Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.all(12),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote section
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 20),
                onPressed: () {},
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                votes.toString(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 20),
                onPressed: () {},
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 8,
                      backgroundColor: AppTheme.accentWhite,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      author,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
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
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$comments comments",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
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
    );
  }
}
