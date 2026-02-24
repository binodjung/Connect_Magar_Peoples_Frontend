import 'package:flutter/material.dart';
import '../../authentication/login/presentation/login_screen.dart';
import '../../../core/utils/colors.dart';
import '../../blog/presentation/liked_posts_screen.dart';
import '../../blog/presentation/bookmarked_posts_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryOrange,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Profile info
            _buildProfileItem(Icons.person_outline, 'Username', username),
            const SizedBox(height: 16),
            _buildProfileItem(Icons.email_outlined, 'Email', email),

            const SizedBox(height: 32),

            // ── Activity section ───────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MY ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              context,
              icon: Icons.favorite,
              iconColor: Colors.red,
              label: 'Liked Posts',
              subtitle: 'Posts you\'ve liked',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LikedPostsScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              context,
              icon: Icons.bookmark,
              iconColor: const Color(0xFFE8A323),
              label: 'Bookmarked Posts',
              subtitle: 'Posts you\'ve saved',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkedPostsScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // Logout button
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
