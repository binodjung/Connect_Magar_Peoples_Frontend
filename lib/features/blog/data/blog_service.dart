import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import 'blog_model.dart';

class BlogService {
  // ── Helper: get auth headers ─────────────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Fetch paginated blog posts ────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchPosts({int page = 1}) async {
    final url = '${ApiConstants.blogPosts}/?page=$page';
    print('Fetching Posts URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Fetch Posts Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results;
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          results = data['results'];
        } else if (data is List) {
          results = data;
        } else {
          results = [];
        }
        final posts = results.map((item) => BlogPost.fromJson(item)).toList();
        return {
          'posts': posts,
          'hasMore': data is Map && data['next'] != null,
        };
      } else {
        print('Error Body: ${response.body}');
        throw Exception('Failed to load blogs: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch Posts Exception: $e');
      rethrow;
    }
  }

  // ── Fetch single post detail ──────────────────────────────────────────────
  Future<BlogPost> fetchPostDetails(int id) async {
    final url = '${ApiConstants.blogPosts}/$id/';
    print('Fetch Detail URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Fetch Detail Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return BlogPost.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch Details Exception: $e');
      rethrow;
    }
  }

  // ── Fetch posts liked by the current user ─────────────────────────────────
  Future<List<BlogPost>> fetchLikedPosts() async {
    final url = ApiConstants.likedPosts;
    print('Fetch Liked Posts URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Liked Posts Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results;
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          results = data['results'];
        } else if (data is List) {
          results = data;
        } else {
          results = [];
        }
        return results.map((item) => BlogPost.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load liked posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch Liked Posts Exception: $e');
      rethrow;
    }
  }

  // ── Fetch posts bookmarked by the current user ────────────────────────────
  Future<List<BlogPost>> fetchBookmarkedPosts() async {
    final url = ApiConstants.bookmarkedPosts;
    print('Fetch Bookmarked Posts URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Bookmarked Posts Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results;
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          results = data['results'];
        } else if (data is List) {
          results = data;
        } else {
          results = [];
        }
        return results.map((item) => BlogPost.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load bookmarked posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch Bookmarked Posts Exception: $e');
      rethrow;
    }
  }

  // ── Add a comment ─────────────────────────────────────────────────────────
  Future<BlogComment?> addComment(int postId, String content) async {
    final url = '${ApiConstants.blogPosts}/$postId/comment/';
    print('Add Comment URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _authHeaders(),
        body: jsonEncode({'content': content}),
      );

      print('Add Comment Status: ${response.statusCode}');
      print('Add Comment Body: ${response.body}');

      if (response.statusCode == 201) {
        return BlogComment.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Add Comment Exception: $e');
      return null;
    }
  }

  // ── Like toggle ───────────────────────────────────────────────────────────
  /// Returns { 'success': bool, 'isLiked': bool }
  /// 201 → liked, 200 → unliked
  Future<Map<String, dynamic>> likePost(int postId) async {
    final url = '${ApiConstants.blogPosts}/$postId/like/';
    print('Like URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Like Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return {'success': true, 'isLiked': true};
      } else if (response.statusCode == 200) {
        return {'success': true, 'isLiked': false};
      } else {
        return {'success': false, 'isLiked': false};
      }
    } catch (e) {
      print('Like Exception: $e');
      return {'success': false, 'isLiked': false};
    }
  }

  // ── Bookmark toggle ───────────────────────────────────────────────────────
  /// Returns { 'success': bool, 'isBookmarked': bool }
  /// 201 → bookmarked, 200 → unbookmarked
  Future<Map<String, dynamic>> bookmarkPost(int postId) async {
    final url = '${ApiConstants.blogPosts}/$postId/bookmark/';
    print('Bookmark URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Bookmark Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return {'success': true, 'isBookmarked': true};
      } else if (response.statusCode == 200) {
        return {'success': true, 'isBookmarked': false};
      } else {
        return {'success': false, 'isBookmarked': false};
      }
    } catch (e) {
      print('Bookmark Exception: $e');
      return {'success': false, 'isBookmarked': false};
    }
  }

  // ── Fetch comments for a post ─────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchComments(int postId, {int page = 1}) async {
    final url = '${ApiConstants.blogComments}?post=$postId&page=$page';
    print('Fetch Comments URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      print('Fetch Comments Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results;
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          results = data['results'];
        } else if (data is List) {
          results = data;
        } else {
          results = [];
        }
        final comments = results.map((item) => BlogComment.fromJson(item)).toList();
        return {
          'comments': comments,
          'hasMore': data is Map && data['next'] != null,
        };
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Fetch Comments Exception: $e');
      rethrow;
    }
  }
}
