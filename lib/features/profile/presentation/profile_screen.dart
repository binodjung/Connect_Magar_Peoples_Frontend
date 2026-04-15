import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/login/presentation/login_screen.dart';
import '../../../core/utils/colors.dart';
import '../../blog/presentation/liked_posts_screen.dart';
import '../../blog/presentation/bookmarked_posts_screen.dart';
import 'update_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _username;
  late String _fullName = "";
  late String _email;
  late String _mobileNumber = "";
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _email = widget.email;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? _username;
      _fullName = prefs.getString('full_name') ?? "";
      _mobileNumber = prefs.getString('mobile_number') ?? "";
      _profilePicture = prefs.getString('profile_picture');
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipe everything (tokens, user info)
    
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _goToUpdateProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(
          currentUsername: _username,
          currentFullName: _fullName,
          email: _email,
          currentMobile: _mobileNumber,
          currentProfilePicture: _profilePicture,
        ),
      ),
    );

    if (result == true) {
      _loadUserInfo(); // Refresh the profile info
    }
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
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _goToUpdateProfile,
          ),
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
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryOrange,
              backgroundImage: _profilePicture != null 
                ? NetworkImage(_profilePicture!) 
                : null,
              child: _profilePicture == null 
                ? const Icon(Icons.person, size: 50, color: Colors.white) 
                : null,
            ),
            const SizedBox(height: 24),

            // Profile info
            _buildProfileItem(Icons.person_outline, 'Username', _username),
            if (_fullName.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildProfileItem(Icons.badge_outlined, 'Full Name', _fullName),
            ],
            const SizedBox(height: 16),
            _buildProfileItem(Icons.email_outlined, 'Email', _email),
            if (_mobileNumber.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildProfileItem(Icons.phone_outlined, 'Mobile Number', _mobileNumber),
            ],

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
              icon: Icons.edit_note_outlined,
              iconColor: Colors.blue,
              label: 'Update Profile',
              subtitle: 'Change your personal details',
              onTap: _goToUpdateProfile,
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              context,
              icon: Icons.lock_outline,
              iconColor: AppColors.primaryMaroon,
              label: 'Change Password',
              subtitle: 'Update your security credentials',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
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
