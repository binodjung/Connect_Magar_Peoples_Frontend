import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/blog_model.dart';
import '../data/blog_service.dart';
import 'comment_screen.dart';
import '../infrastructure/esewa_service.dart';
import '../../../../core/constants/api_constants.dart';
import 'esewa_payment_screen.dart';

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
    
    // Save current state for potential rollback
    final bool wasLiked = _isLiked;
    final int originalCount = _likesCount;
    
    setState(() => _isLiking = true);

    // Optimistic UI update
    setState(() {
      _isLiked = !wasLiked;
      _likesCount = _isLiked ? originalCount + 1 : originalCount - 1;
    });

    try {
      final result = await _blogService.likePost(widget.post.id);
      final bool success = result['success'] ?? false;
      final bool serverIsLiked = result['isLiked'] ?? _isLiked;
      final int? serverTotalLikes = result['total_likes'];

      if (!success) {
        throw Exception('Server failed');
      }

      if (mounted) {
        setState(() {
          _isLiked = serverIsLiked;
          if (serverTotalLikes != null) {
            _likesCount = serverTotalLikes;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Revert on failure
        setState(() {
          _isLiked = wasLiked;
          _likesCount = originalCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like. Try again.')),
        );
      }
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

  // ── eSewa Donation ───────────────────────────────────────────────────────
  void _donateViaEsewa() async {
    final TextEditingController amountController = TextEditingController(text: "100");
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Donation Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How much would you like to donate to this author?'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'Rs. ',
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF60BB46)),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final String amount = amountController.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      }
      return;
    }

    final transactionId = EsewaService.generateTransactionUUID();

    // Step 1: Record donation in backend (PENDING status)
    final result = await _blogService.recordDonation(
      postId: widget.post.id,
      amount: amount,
      transactionId: transactionId,
    );

    if (result['success'] != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate donation: ${result['error'] ?? 'Unknown error'}')),
        );
      }
      return;
    }

    // Step 2: Generate signature and open eSewa WebView
    final signature = EsewaService.generateSignature(
      amount: amount,
      transactionId: transactionId,
      merchantCode: ApiConstants.esewaMerchantCode,
    );

    if (!mounted) return;
    final paymentSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EsewaPaymentScreen(
          postId: widget.post.id,
          amount: amount,
          transactionId: transactionId,
          signature: signature,
        ),
      ),
    );

    if (paymentSuccess == true) {
      if (!mounted) return;
      final verifyResult = await _blogService.verifyDonation(
        postId: widget.post.id,
        transactionId: transactionId,
      );

      if (verifyResult['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verified successfully! Please go back and refresh to see it.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment completed, but verification failed: ${verifyResult['error'] ?? 'Unknown'}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      // extendBodyBehindAppBar removed to keep layout clean and standard as requested
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image Container (Bordered like Content box) ──────────
            if (widget.post.image != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Matching description box bg
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF1D4E7B), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: CachedNetworkImage(
                      imageUrl: widget.post.image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D4E7B)),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image, 
                        size: 40, 
                        color: Colors.grey
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Segmented Header (Image Style) ─────────────────────────
                  Row(
                    children: [
                      // Red Segment
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC00000),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4)),
                        ),
                        child: const Text(
                          'POST',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Dark Blue Segment (Title)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: const Color(0xFF1D4E7B),
                          child: Text(
                            widget.post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Orange Segment (Comments Count)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD35400),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${_comments.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Subheading (Category & Date)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 12),
                    child: Text(
                      '${widget.post.category} | Written on ${_formatDate(widget.post.createdAt)}',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Color(0xFF1D4E7B), thickness: 1.5),
                  ),

                  // ── Action Buttons Row (Likes) ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isLiked ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _isLiked ? Colors.red : Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_likesCount likes',
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF1D4E7B)),
                          ),
                          child: const Text(
                            'View Comment',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: Color(0xFF1D4E7B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Description Header ──────────────────────────────────
                  const Text(
                    'Content Description',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC00000),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Content Container (Styled like the Blue Code Box) ────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Light blue-ish grey
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF1D4E7B), width: 1.5),
                    ),
                    child: Text(
                      widget.post.description,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Summary Info box (Green Style) ───────────────────
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4), // Light green
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                    ),
                    child: Text(
                      'This blog post specifically explores ${widget.post.category} trends. Read more for cultural insights and community updates.',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (widget.post.allowDonation)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC00000).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC00000).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.volunteer_activism, color: Color(0xFFC00000), size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Support this Post',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your donation helps the author create more content.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _donateViaEsewa,
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: const Text(
                                'Donate via eSewa',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF60BB46), // eSewa Green
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (widget.post.donations.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Donation History (Total: Rs. ${widget.post.totalDonations})',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.post.donations.length,
                      itemBuilder: (context, index) {
                        final donation = widget.post.donations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFC00000).withOpacity(0.1),
                                    child: Text(
                                      donation.donorName.isNotEmpty
                                          ? donation.donorName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFFC00000),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donation.donorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(donation.createdAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Rs. ${donation.amount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF60BB46),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    donation.status == 'COMPLETE'
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    color: donation.status == 'COMPLETE'
                                        ? const Color(0xFF60BB46)
                                        : Colors.orange,
                                    size: 16,
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 48),
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
