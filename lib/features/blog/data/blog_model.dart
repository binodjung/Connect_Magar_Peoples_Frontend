class BlogPost {
  final int id;
  final String title;
  final String category;
  final String description;
  final String? image;
  final String authorName;
  final String authorUsername;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool allowDonation;
  final String totalDonations;
  final List<BlogComment> comments;
  final List<BlogDonation> donations;

  BlogPost({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.image,
    required this.authorName,
    required this.authorUsername,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    this.isBookmarked = false,
    this.allowDonation = false,
    this.totalDonations = '0',
    this.comments = const [],
    this.donations = const [],
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      image: json['image'],
      authorName: json['author']['full_name'],
      authorUsername: json['author']['username'],
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'],
      isLiked: json['is_liked'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      allowDonation: json['allow_donation'] ?? false,
      totalDonations: json['total_donations']?.toString() ?? '0',
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => BlogComment.fromJson(e))
              .toList() ??
          [],
      donations: (json['donations'] as List<dynamic>?)
              ?.map((e) => BlogDonation.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BlogComment {
  final int id;
  final String content;
  final String authorName;
  final String authorUsername;
  final DateTime createdAt;

  BlogComment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorUsername,
    required this.createdAt,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      id: json['id'],
      content: json['content'],
      authorName: json['user']['full_name'],
      authorUsername: json['user']['username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BlogDonation {
  final int id;
  final String donorName;
  final String donorUsername;
  final String amount;
  final String status;
  final DateTime createdAt;

  BlogDonation({
    required this.id,
    required this.donorName,
    required this.donorUsername,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory BlogDonation.fromJson(Map<String, dynamic> json) {
    return BlogDonation(
      id: json['id'],
      donorName: json['donor']['full_name'],
      donorUsername: json['donor']['username'],
      amount: json['amount']?.toString() ?? '0',
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
