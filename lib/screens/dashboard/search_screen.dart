import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/thread_model.dart';
import 'thread_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: "Search ThreadX",
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: TextStyle(color: AppTheme.textPrimary),
          autofocus: true,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Popular Searches",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSearchResult(
            context: context,
            title: "Flutter state management comparison",
            subreddit: "r/FlutterDev",
            votes: 342,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSearchResult(
            context: context,
            title: "Best practices for clean architecture",
            subreddit: "r/Programming",
            votes: 578,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSearchResult(
            context: context,
            title: "Async/await vs Futures in Dart",
            subreddit: "r/FlutterDev",
            votes: 215,
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSearchResult(
            context: context,
            title: "Material Design 3 implementation guide",
            subreddit: "r/MaterialDesign",
            votes: 489,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult({
    required BuildContext context,
    required String title,
    required String subreddit,
    required int votes,
  }) {
    return InkWell(
      onTap: () {
        // Create a mock thread for search results
        final mockThread = ThreadModel(
          title: title,
          content: '',
          authorId: 'search_user',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          votes: votes,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadDetailScreen(
              threadId: 'search_result',
              thread: mockThread,
            ),
          ),
        );
      },
      child: Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subreddit,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$votes upvotes",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
