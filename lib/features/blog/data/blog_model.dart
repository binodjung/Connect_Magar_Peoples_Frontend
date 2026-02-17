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
  final List<BlogComment> comments;

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
    this.comments = const [],
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
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => BlogComment.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BlogComment {
  final int id;
  final String content;
  final String authorName;
  final DateTime createdAt;

  BlogComment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      id: json['id'],
      content: json['content'],
      authorName: json['user']['full_name'], // Nested user object
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
