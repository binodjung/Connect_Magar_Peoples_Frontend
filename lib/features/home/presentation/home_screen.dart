import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme_provider.dart';
import '../../authentication/login/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../blog/presentation/blog_list_screen.dart';
import '../../dictionary/presentation/dictionary_screen.dart';
import '../../history/presentation/history_list_screen.dart';
import '../../feedback/presentation/feedback_screen.dart';
import '../../lipi_letterbook/presentation/lipi_letterbook_screen.dart';
import '../../dictionary/presentation/dictionary_screen.dart';
import '../../dictionary/presentation/translation_screen.dart';
import '../../quiz/presentation/quiz_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String email;
  final bool isGuest;

  const HomeScreen({
    Key? key,
    required this.username,
    required this.email,
    this.isGuest = false,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeContent(username: widget.username, isGuest: widget.isGuest),
      TranslationScreen(),
      ProfileScreen(username: widget.username, email: widget.email),
    ];
  }

  void _onItemTapped(int index) {
    if (widget.isGuest && (index == 1 || index == 2)) {
      _showLoginDialog();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Exit confirmation dialog ──────────────────────────────────────────────
  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit App?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android hardware back button.
    // canPop: false means we handle it ourselves (only on HomeScreen).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // If we're not on the home tab, go back to home tab first
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }
        // On home tab — show exit confirmation
        final shouldExit = await _showExitDialog();
        if (shouldExit) {
          SystemNavigator.pop(); // Exits the app
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF8B0000),
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.translate), label: 'Translate'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String username;
  final bool isGuest;

  const _HomeContent({required this.username, required this.isGuest});

  void _handleRestrictedAction(BuildContext context, VoidCallback action) {
    if (isGuest) {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      homeState?._showLoginDialog();
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset('Images/logo.png', height: 40, width: 40),
        ),
        title: Column(
          children: [
            Text(
              'मगर समुदाय',
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF8B0000),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Connect Magar People',
              style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF8B0000),
                  fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: isDark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            activeColor: const Color(0xFF8B0000),
            inactiveThumbColor: Colors.orange,
            inactiveTrackColor: Colors.orange.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learn Magar\nLanguage',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore the unique magar language.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _handleRestrictedAction(context, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DictionaryScreen(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Start Learning', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildGridItem(context, Icons.history, 'Magar History', Colors.brown, onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryListScreen(),
                      ),
                    );
                  });
                }),
                _buildGridItem(context, Icons.quiz, 'Quiz', Colors.brown, onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizSelectionScreen(),
                      ),
                    );
                  });
                }),
                _buildGridItem(context, Icons.book, 'Dictionary', const Color(0xFF8B0000), onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DictionaryScreen(),
                      ),
                    );
                  });
                }),
                _buildGridItem(context, Icons.article, 'Blog', Colors.brown, onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlogListScreen(),
                      ),
                    );
                  });
                }),
                _buildGridItem(context, Icons.text_fields, 'Akkha Magar Lipi', Colors.brown, onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LipiLetterbookScreen(),
                      ),
                    );
                  });
                }),
                _buildGridItem(context, Icons.feedback, 'Feedback', Colors.brown, onTap: () {
                  _handleRestrictedAction(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, Color color, {VoidCallback? onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
