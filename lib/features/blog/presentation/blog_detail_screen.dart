import 'package:flutter/material.dart';
import '../../../../core/utils/colors.dart'; 
import '../data/blog_model.dart';
import '../data/blog_service.dart';
import 'comment_screen.dart';

class BlogDetailScreen extends StatefulWidget {
  final BlogPost post;

  const BlogDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  late bool _isLiked;
  late int _likesCount;
  final BlogService _blogService = BlogService();
  
  // For Comments
  List<BlogComment> _comments = [];
  bool _isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    // Initial comments might be empty if coming from list, so fetch details
    _fetchPostDetails();
  }

  Future<void> _fetchPostDetails() async {
    try {
      final fullPost = await _blogService.fetchPostDetails(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = fullPost.comments;
        _likesCount = fullPost.likesCount; // Sync likes too just in case
        _isLiked = fullPost.isLiked;
      });
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      final success = await _blogService.likePost(widget.post.id);
      if (!success) {
        if (!mounted) return;
        setState(() {
          _isLiked = !_isLiked;
          _likesCount += _isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to like post')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.black)),
        ],
      ),
      extendBodyBehindAppBar: true, 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.image != null)
              Image.network(
                widget.post.image!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) =>
                      Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      CircleAvatar(
                         backgroundColor: const Color(0xFF8B0000), // Dark Red
                         radius: 20,
                         child: Text(
                            widget.post.authorName.isNotEmpty ? widget.post.authorName[0] : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 18)
                         ),
                       ),
                       const SizedBox(width: 12),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(widget.post.authorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                           Text('10 min read', style: TextStyle(fontSize: 12, color: Colors.grey[600])), 
                         ],
                       ),
                       const Spacer(),
                       
                       // LIKE BUTTON
                       GestureDetector(
                         onTap: _toggleLike,
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: _isLiked ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Row(
                             children: [
                               Icon(
                                 _isLiked ? Icons.favorite : Icons.favorite_border, 
                                 color: Colors.red, 
                                 size: 20
                               ),
                               const SizedBox(width: 6),
                               Text(
                                 '$_likesCount', 
                                 style: const TextStyle(fontWeight: FontWeight.bold)
                               ),
                             ],
                           ),
                         ),
                       ),
                       
                       const SizedBox(width: 12),

                       // COMMENT BUTTON
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
                               const Icon(
                                 Icons.chat_bubble_outline, 
                                 color: Colors.black54, 
                                 size: 20
                               ),
                               const SizedBox(width: 6),
                               Text(
                                 '${_comments.length}', 
                                 style: const TextStyle(fontWeight: FontWeight.bold)
                               ),
                             ],
                           ),
                         ),
                       ),
                    ],
                   ),
                   const SizedBox(height: 24),
                   Text(
                     widget.post.title,
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     widget.post.description,
                     style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
