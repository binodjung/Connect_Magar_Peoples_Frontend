import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/blog_model.dart';
import '../data/blog_service.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final BlogService _blogService = BlogService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<BlogPost> _allPosts = [];
  List<BlogPost> _filteredPosts = [];
  // Tracks which post IDs are currently awaiting a like API call.
  // Prevents double-tapping from sending duplicate requests.
  final Set<int> _likingPostIds = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _fetchPosts();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredPosts = query.isEmpty
          ? List.from(_allPosts)
          : _allPosts
              .where((post) =>
                  post.title.toLowerCase().contains(query) ||
                  post.description.toLowerCase().contains(query) ||
                  post.authorName.toLowerCase().contains(query) ||
                  post.category.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _fetchPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _blogService.fetchPosts(page: _page);
      final newPosts = result['posts'] as List<BlogPost>;
      final hasMore = result['hasMore'] as bool;

      if (!mounted) return;

      setState(() {
        _allPosts.addAll(newPosts);
        _hasMore = hasMore;
        _page++;
        _isLoading = false;
        _applySearch();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    _filteredPosts = query.isEmpty
        ? List.from(_allPosts)
        : _allPosts
            .where((post) =>
                post.title.toLowerCase().contains(query) ||
                post.description.toLowerCase().contains(query) ||
                post.authorName.toLowerCase().contains(query) ||
                post.category.toLowerCase().contains(query))
            .toList();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _page = 1;
      _allPosts.clear();
      _filteredPosts.clear();
      _hasMore = true;
    });
    await _fetchPosts();
  }

  // ── Like toggle directly from the list ───────────────────────────────────
  Future<void> _toggleLike(int postIndex) async {
    final post = _filteredPosts[postIndex];

    // Guard: ignore if a like request for this post is already in-flight
    if (_likingPostIds.contains(post.id)) return;
    
    // Save current state for rollback
    final bool wasLiked = post.isLiked;
    final int originalCount = post.likesCount;
    
    setState(() => _likingPostIds.add(post.id));

    // Optimistic update
    final newIsLiked = !wasLiked;
    final newLikesCount = newIsLiked ? originalCount + 1 : originalCount - 1;
    final updatedPost = _rebuildPost(post, isLiked: newIsLiked, likesCount: newLikesCount);
    _updatePostInLists(post.id, updatedPost);

    try {
      final result = await _blogService.likePost(post.id);
      final bool success = result['success'] ?? false;
      final bool serverIsLiked = result['isLiked'] ?? newIsLiked;
      final int? serverTotalLikes = result['total_likes'];

      if (success && mounted) {
        // Sync with server's actual state
        final syncedPost = _rebuildPost(post, 
          isLiked: serverIsLiked, 
          likesCount: serverTotalLikes ?? newLikesCount
        );
        _updatePostInLists(post.id, syncedPost);
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      if (mounted) {
        // Revert on failure
        final revertedPost = _rebuildPost(post, isLiked: wasLiked, likesCount: originalCount);
        _updatePostInLists(post.id, revertedPost);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update like. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _likingPostIds.remove(post.id));
    }
  }

  BlogPost _rebuildPost(BlogPost p, {required bool isLiked, required int likesCount}) {
    return BlogPost(
      id: p.id,
      title: p.title,
      category: p.category,
      description: p.description,
      image: p.image,
      authorName: p.authorName,
      authorUsername: p.authorUsername,
      createdAt: p.createdAt,
      likesCount: likesCount,
      isLiked: isLiked,
      comments: p.comments,
    );
  }

  void _updatePostInLists(int postId, BlogPost updated) {
    if (!mounted) return;
    setState(() {
      final allIdx = _allPosts.indexWhere((p) => p.id == postId);
      if (allIdx != -1) _allPosts[allIdx] = updated;

      final filtIdx = _filteredPosts.indexWhere((p) => p.id == postId);
      if (filtIdx != -1) _filteredPosts[filtIdx] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Blog',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts, authors, categories...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8A323), width: 1.5),
                ),
              ),
            ),
          ),

          // ── Result count hint ─────────────────────────────────────────────
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${_filteredPosts.length} result${_filteredPosts.length == 1 ? '' : 's'} for "$_searchQuery"',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: _allPosts.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8A323)))
                : _filteredPosts.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: const Color(0xFFE8A323),
                        onRefresh: _refreshPosts,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filteredPosts.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredPosts.length) {
                              return _buildLoadMoreIndicator();
                            }
                            return _buildBlogCard(context, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No posts match "$_searchQuery"'
                : 'No blog posts yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: const Text('Clear search', style: TextStyle(color: Color(0xFFE8A323))),
            ),
          ],
        ],
      ),
    );
  }

  // ── Shimmer skeleton for images loading ───────────────────────────────────
  Widget _buildImageShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 900),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      onEnd: () {},
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE8A323),
                strokeWidth: 2,
              ),
            )
          : Center(
              child: OutlinedButton.icon(
                onPressed: _fetchPosts,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load more'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8A323),
                  side: const BorderSide(color: Color(0xFFE8A323)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
    );
  }

  Widget _buildBlogCard(BuildContext context, int index) {
    final post = _filteredPosts[index];
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailScreen(post: post)),
        );
        // Refresh to get updated like state from server after returning
        _refreshPosts();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            if (post.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: post.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImageShimmer(),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A323),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // No image - show category badge at top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A323).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFE8A323),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Content ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Description snippet
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Divider
                  Divider(height: 1, color: Colors.grey[100]),
                  const SizedBox(height: 12),
                  // Bottom row: author + date + like
                  Row(
                    children: [
                      // Date only (classic style)
                      Expanded(
                        child: Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ),
                      // ── Like Button (tappable) ────────────────────────
                      GestureDetector(
                        onTap: () => _toggleLike(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: post.isLiked
                                ? Colors.red.withOpacity(0.08)
                                : const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: post.isLiked
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey(post.isLiked),
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${post.likesCount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: post.isLiked ? Colors.red : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
