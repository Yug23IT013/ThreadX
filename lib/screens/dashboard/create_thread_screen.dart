import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../config/theme.dart';

class CreateThreadScreen extends StatelessWidget {
  const CreateThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post created successfully!'),
                  backgroundColor: AppTheme.accentWhite,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "POST",
              style: TextStyle(
                color: AppTheme.accentWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.accentWhite,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Posting as u/username",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: "An interesting title",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "What are your thoughts?",
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: () {},
                      color: AppTheme.textSecondary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {},
                      color: AppTheme.textSecondary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.poll_outlined),
                      onPressed: () {},
                      color: AppTheme.textSecondary,
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
}
