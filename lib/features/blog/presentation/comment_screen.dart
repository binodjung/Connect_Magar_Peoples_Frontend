import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _currentUserUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchComments();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserUsername = prefs.getString('user_username');
    });
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
      } 
    } catch (e) {
       if (!mounted) return;
       setState(() => _isSending = false);
       print("Error adding comment: $e");
    }
  }

  Future<void> _deleteComment(int commentId, int index) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await _blogService.deleteComment(commentId);
      if (success && mounted) {
        setState(() {
          _comments.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'COMMUNITY COMMENTS',
          style: TextStyle(
            color: Color(0xFF1D4E7B),
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty && !_isLoading
                ? const Center(
                    child: Text(
                      "No comments yet.",
                      style: TextStyle(fontFamily: 'Arial', fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _comments.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _comments.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Color(0xFF1D4E7B)),
                        ));
                      }
                      
                      final comment = _comments[index];
                      final isOwner = _currentUserUsername != null && 
                                      comment.authorUsername == _currentUserUsername;
                                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            // ── Comment Header (Segmented style) ────────────────
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC00000), // Red
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4)),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 14),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    color: const Color(0xFF1D4E7B), // Dark Blue
                                    child: Text(
                                      comment.authorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD35400), // Orange
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
                                  ),
                                  child: Text(
                                    _formatDate(comment.createdAt),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Arial',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // ── Comment Body (Blue Border Box style) ────────────
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9), // Light blue bg
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                                border: Border.all(color: const Color(0xFF1D4E7B), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.content,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 12,
                                      color: Color(0xFF333333),
                                      height: 1.4,
                                    ),
                                  ),
                                  if (isOwner)
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () => _deleteComment(comment.id, index),
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'DELETE',
                                            style: TextStyle(
                                              color: Color(0xFFC00000),
                                              fontFamily: 'Arial',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
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
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: TextStyle(fontFamily: 'Arial', fontSize: 13, color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1D4E7B), width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSending ? null : _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4E7B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isSending 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
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
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
