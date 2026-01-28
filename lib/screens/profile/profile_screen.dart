import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: AppTheme.cardBackground,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentWhite,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.darkBackground,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "u/username",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Member since January 2026",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("1.2k", "Karma"),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.dividerColor,
                    ),
                    _buildStatItem("45", "Posts"),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.dividerColor,
                    ),
                    _buildStatItem("128", "Comments"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.article_outlined,
            title: "My Posts",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildMenuItem(
            icon: Icons.comment_outlined,
            title: "My Comments",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildMenuItem(
            icon: Icons.bookmark_outline,
            title: "Saved",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildMenuItem(
            icon: Icons.history,
            title: "History",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
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
