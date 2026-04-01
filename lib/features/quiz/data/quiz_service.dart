import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import 'quiz_model.dart';

class QuizService {
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<List<QuizQuestion>> fetchQuestions({String? category, bool random = false}) async {
    var url = ApiConstants.quizQuestions;
    List<String> queryParams = [];
    
    if (category != null) {
      queryParams.add('category=$category');
    }
    if (random) {
      queryParams.add('random=true');
    }
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }
    
    print('Fetching Quiz Questions URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

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
        return results.map((item) => QuizQuestion.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load quiz questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch Quiz Questions Exception: $e');
      rethrow;
    }
  }

  // Admin CRUD operations (if needed from app, though user mentioned Admin Panel)
  Future<bool> createQuestion(QuizQuestion question) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.quizQuestions),
        headers: await _authHeaders(),
        body: jsonEncode(question.toJson()),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      print('Create Question Exception: $e');
      return false;
    }
  }

  Future<bool> updateQuestion(int id, QuizQuestion question) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.quizQuestions}$id/'),
        headers: await _authHeaders(),
        body: jsonEncode(question.toJson()),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Update Question Exception: $e');
      return false;
    }
  }

  Future<bool> deleteQuestion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.quizQuestions}$id/'),
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 204;
    } catch (e) {
      print('Delete Question Exception: $e');
      return false;
    }
  }
}
