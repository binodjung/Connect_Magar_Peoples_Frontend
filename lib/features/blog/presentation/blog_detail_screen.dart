import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/blog_model.dart';
import '../data/blog_service.dart';
import 'comment_screen.dart';

class BlogDetailScreen extends StatefulWidget {
  final BlogPost post;

  const BlogDetailScreen({super.key, required this.post});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  late bool _isLiked;
  late int _likesCount;
  late bool _isBookmarked;
  bool _isLiking = false;       // guard against double-tap on like
  bool _isBookmarking = false;  // guard against double-tap on bookmark
  final BlogService _blogService = BlogService();

  List<BlogComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    _isBookmarked = widget.post.isBookmarked;
    _fetchPostDetails();
  }

  Future<void> _fetchPostDetails() async {
    try {
      final fullPost = await _blogService.fetchPostDetails(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = fullPost.comments;
        _likesCount = fullPost.likesCount;
        _isLiked = fullPost.isLiked;
        _isBookmarked = fullPost.isBookmarked;
      });
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  // ── Like toggle ─────────────────────────────────────────────────────────
  Future<void> _toggleLike() async {
    if (_isLiking) return; // Guard: ignore rapid taps
    setState(() => _isLiking = true);

    // Optimistic UI update
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      final result = await _blogService.likePost(widget.post.id);
      final success = result['success'] as bool;
      final serverIsLiked = result['isLiked'] as bool;

      if (!success) {
        if (!mounted) return;
        // Revert on failure
        setState(() {
          _isLiked = !_isLiked;
          _likesCount += _isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like. Try again.')),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _isLiked = serverIsLiked;
          _likesCount = widget.post.likesCount + (serverIsLiked ? 1 : 0);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  // ── Bookmark toggle ──────────────────────────────────────────────────────
  Future<void> _toggleBookmark() async {
    if (_isBookmarking) return; // Guard: ignore rapid taps
    setState(() {
      _isBookmarking = true;
      _isBookmarked = !_isBookmarked;
    });

    try {
      final result = await _blogService.bookmarkPost(widget.post.id);
      final success = result['success'] as bool;
      final serverIsBookmarked = result['isBookmarked'] as bool;

      if (!success) {
        if (!mounted) return;
        setState(() => _isBookmarked = !_isBookmarked);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bookmark. Try again.')),
        );
      } else {
        if (!mounted) return;
        setState(() => _isBookmarked = serverIsBookmarked);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverIsBookmarked ? 'Post bookmarked!' : 'Bookmark removed'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBookmarked = !_isBookmarked);
    } finally {
      if (mounted) setState(() => _isBookmarking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bookmark toggle button (share button removed)
          IconButton(
            onPressed: _toggleBookmark,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey(_isBookmarked),
                color: _isBookmarked ? const Color(0xFFE8A323) : Colors.black,
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ────────────────────────────────────────────────
            if (widget.post.image != null)
              CachedNetworkImage(
              imageUrl: widget.post.image!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.grey[200]!],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Author row + like/comment buttons ─────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF8B0000),
                        radius: 22,
                        child: Text(
                          widget.post.authorName.isNotEmpty
                              ? widget.post.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.post.category} · ${_formatDate(widget.post.createdAt)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Like button
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isLiked
                                ? Colors.red.withValues(alpha: 0.08)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey(_isLiked),
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_likesCount',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Comment button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentScreen(postId: widget.post.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, color: Colors.black54, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '${_comments.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A323).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.post.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFE8A323),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Body
                  Text(
                    widget.post.description,
                    style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[800]),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
