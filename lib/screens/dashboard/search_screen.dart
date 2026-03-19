import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/thread_model.dart';
import '../../services/thread_service.dart';
import 'thread_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ThreadService _threadService = ThreadService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _query = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search ThreadX",
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: TextStyle(color: AppTheme.textPrimary),
          autofocus: true,
        ),
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
                'Error loading posts: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
            );
          }

          final allThreads = snapshot.data ?? [];
          final filteredThreads = _query.isEmpty
              ? allThreads
              : allThreads.where((thread) {
                  final title = thread.title.toLowerCase();
                  final content = thread.content.toLowerCase();
                  return title.contains(_query) || content.contains(_query);
                }).toList();

          if (_query.isEmpty) {
            return const Center(
              child: Text(
                'Type in the search bar to find posts',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          if (filteredThreads.isEmpty) {
            return const Center(
              child: Text(
                'No matching posts found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredThreads.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.dividerColor),
            itemBuilder: (context, index) {
              final thread = filteredThreads[index];
              return _buildSearchResult(
                context: context,
                thread: thread,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResult({
    required BuildContext context,
    required ThreadModel thread,
  }) {
    return InkWell(
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
                    thread.title,
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
                        thread.authorId,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${thread.votes} upvotes',
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
