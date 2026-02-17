import 'package:flutter/material.dart';
import '../data/blog_model.dart';
import '../data/blog_service.dart';

class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final BlogService _blogService = BlogService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  
  List<BlogComment> _comments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchComments();
    }
  }

  Future<void> _fetchComments() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _blogService.fetchComments(widget.postId, page: _currentPage);
      final newComments = result['comments'] as List<BlogComment>;
      final hasMore = result['hasMore'] as bool;

      if (!mounted) return;
      setState(() {
        if (_currentPage == 1) {
          _comments = newComments;
        } else {
          _comments.addAll(newComments);
        }
        _hasMore = hasMore;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print("Error fetching comments: $e");
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (_isSending) return;
    setState(() => _isSending = true);

    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      final newComment = await _blogService.addComment(widget.postId, content);
      
      if (!mounted) return;
      setState(() => _isSending = false);

      if (newComment != null) {
        _commentController.clear();
        setState(() {
          _comments.insert(0, newComment); // Add to top
        });
        // Scroll to top
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        // No Toast Message as requested
      } 
    } catch (e) {
       if (!mounted) return;
       setState(() => _isSending = false);
       print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty && !_isLoading
                ? const Center(child: Text("No comments yet."))
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      if (index == _comments.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comment = _comments[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: null, // Add user image if available
                            child: Text(
                              comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.authorName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _addComment,
                    icon: _isSending 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: Color(0xFF8B0000)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple helper or utilize intl package if available
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
