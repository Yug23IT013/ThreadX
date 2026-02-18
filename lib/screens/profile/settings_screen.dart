import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../login/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "ACCOUNT",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSettingsItem(
            context: context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "PREFERENCES",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: "Notifications",
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: AppTheme.accentWhite,
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSettingsItem(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: AppTheme.accentWhite,
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSettingsItem(
            context: context,
            icon: Icons.language,
            title: "Language",
            subtitle: "English",
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "ABOUT",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.info_outline,
            title: "About ThreadX",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSettingsItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          _buildSettingsItem(
            context: context,
            icon: Icons.description_outlined,
            title: "Terms of Service",
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBackground,
                    title: const Text(
                      "Log Out",
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    content: const Text(
                      "Are you sure you want to log out?",
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Log Out",
                          style: TextStyle(color: AppTheme.accentWhite),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Log Out",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
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
