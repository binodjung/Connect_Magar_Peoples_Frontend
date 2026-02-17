import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import 'blog_model.dart';
import '../../authentication/login/infrastructure/repository/auth_service.dart';

class BlogService {
  Future<Map<String, dynamic>> fetchPosts({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    // Ensure slash separation
    final url = '${ApiConstants.blogPosts}/?page=$page';
    print('Fetching Posts URL: $url');
    print('Token: ${token != null ? "Present" : "Missing"}');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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

        final posts = results.map((dynamic item) => BlogPost.fromJson(item)).toList();
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

  Future<BlogPost> fetchPostDetails(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = '${ApiConstants.blogPosts}/$id/';
    print('Fetch Detail URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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

  Future<BlogComment?> addComment(int postId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null) {
      print('Add Comment Failed: No Token');
      return null;
    }

    final url = '${ApiConstants.blogPosts}/$postId/comment/';
    print('Add Comment URL: $url');
    print('Content: $content');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );

      print('Add Comment Status: ${response.statusCode}');
      print('Add Comment Body: ${response.body}');

      if (response.statusCode == 201) {
        return BlogComment.fromJson(jsonDecode(response.body));
      } else {
        return null; // Handle error in UI if needed
      }
    } catch (e) {
      print('Add Comment Exception: $e');
      return null;
    }
  }

  Future<bool> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('Like Failed: No Token');
      return false;
    }

    final url = '${ApiConstants.blogPosts}/$postId/like/';
    print('Like URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Like Status: ${response.statusCode}');
      print('Like Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Like Exception: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchComments(int postId, {int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    // Uses the separate comments endpoint with filtering
    final url = '${ApiConstants.blogComments}?post=$postId&page=$page';
    print('Fetch Comments URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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

        final comments = results.map((dynamic item) => BlogComment.fromJson(item)).toList();
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
