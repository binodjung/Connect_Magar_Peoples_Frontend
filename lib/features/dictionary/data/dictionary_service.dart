import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/word_model.dart';
import '../../../core/constants/api_constants.dart';

class DictionaryResult {
  final List<Word> words;
  final int totalCount;
  final bool hasNext;

  const DictionaryResult({
    required this.words,
    required this.totalCount,
    required this.hasNext,
  });
}

class DictionaryService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<DictionaryResult> fetchWords({
    String search = '',
    String letter = '',
    String category = '',
    int page = 1,
  }) async {
    final queryParams = {
      if (search.isNotEmpty) 'search': search,
      if (letter.isNotEmpty) 'letter': letter,
      if (category.isNotEmpty) 'category': category,
      'page': page.toString(),
    };

    final uri = Uri.parse(ApiConstants.dictionaryWords)
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return DictionaryResult(
        words: results.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount: data['count'] as int,
        hasNext: data['next'] != null,
      );
    } else if (response.statusCode == 401) {
      // If unauthorized, clear tokens and retry as guest (dictionary list is public)
      await _clearTokens();
      final guestResponse = await http.get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));
      
      if (guestResponse.statusCode == 200) {
        final data = jsonDecode(guestResponse.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return DictionaryResult(
          words: results.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList(),
          totalCount: data['count'] as int,
          hasNext: data['next'] != null,
        );
      }
      throw Exception('Failed to load words: ${guestResponse.statusCode}');
    } else {
      throw Exception('Failed to load words: ${response.statusCode}');
    }
  }
}
