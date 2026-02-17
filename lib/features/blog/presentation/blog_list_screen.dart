import 'package:flutter/material.dart';
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
  
  List<BlogPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _blogService.fetchPosts(page: _page);
      final newPosts = result['posts'] as List<BlogPost>;
      final hasMore = result['hasMore'] as bool;
      
      if (newPosts.isNotEmpty) {
         print('First post liked? ${newPosts[0].isLiked} (ID: ${newPosts[0].id})');
      }

      if (!mounted) return;

      setState(() {
        _posts.addAll(newPosts);
        _hasMore = hasMore;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Blog', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty && !_isLoading
              ? const Center(child: Text('No blog posts found.'))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    final post = _posts[index];
                    return _buildBlogCard(context, post);
                  },
                ),
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogPost post) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailScreen(post: post)),
        );
        // Refresh list on return to update like counts/status
        _page = 1;
        _posts.clear();
        _hasMore = true;
        _fetchPosts();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (post.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  post.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                       CircleAvatar(
                         backgroundColor: Colors.red[800],
                         radius: 12,
                         child: Text(
                            post.authorName.isNotEmpty ? post.authorName[0] : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 12)
                         ),
                       ),
                       const SizedBox(width: 8),
                       Text(post.authorName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                       const Spacer(),
                       Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 16),
                       const SizedBox(width: 4),
                       Text('${post.likesCount}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
