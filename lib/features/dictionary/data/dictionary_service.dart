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
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<DictionaryResult> fetchWords({
    String search = '',
    String letter = '',
    int page = 1,
  }) async {
    final queryParams = {
      if (search.isNotEmpty) 'search': search,
      if (letter.isNotEmpty) 'letter': letter,
      'page': page.toString(),
    };

    final uri = Uri.parse(ApiConstants.dictionaryWords)
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return DictionaryResult(
        words: results.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount: data['count'] as int,
        hasNext: data['next'] != null,
      );
    } else {
      throw Exception('Failed to load words: ${response.statusCode}');
    }
  }
}
