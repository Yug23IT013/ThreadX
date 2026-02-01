import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';
import '../login/login_screen.dart';
import 'settings_screen.dart';
import 'my_posts_screen.dart';
import 'my_comments_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Perform logout
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      await SessionManager.clearSession();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

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
                Text(
                  user?.displayName ?? "u/username",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPostsScreen()),
              );
            },
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildMenuItem(
            icon: Icons.comment_outlined,
            title: "My Comments",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyCommentsScreen()),
              );
            },
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
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildMenuItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () => _handleLogout(context),
            isDestructive: true,
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
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.red : AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red : AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
