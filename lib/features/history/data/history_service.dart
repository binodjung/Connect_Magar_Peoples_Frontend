import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'history_model.dart';
import '../../../core/constants/api_constants.dart';

class HistoryService {
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

  Future<List<HistoryModel>> fetchHistories() async {
    final url = Uri.parse(ApiConstants.histories);
    final response = await http.get(
      url,
      headers: await _headers(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => HistoryModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      await _clearTokens();
      final guestResponse = await http.get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (guestResponse.statusCode == 200) {
        final data = jsonDecode(guestResponse.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.map((e) => HistoryModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load histories: ${guestResponse.statusCode}');
    } else {
      throw Exception('Failed to load histories: ${response.statusCode}');
    }
  }

  Future<HistoryModel> fetchHistoryDetail(int id) async {
    final url = Uri.parse('${ApiConstants.histories}$id/');
    final response = await http.get(
      url,
      headers: await _headers(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      return HistoryModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _clearTokens();
      final guestResponse = await http.get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (guestResponse.statusCode == 200) {
        return HistoryModel.fromJson(jsonDecode(guestResponse.body));
      }
      throw Exception('Failed to load history details: ${guestResponse.statusCode}');
    } else {
      throw Exception('Failed to load history details: ${response.statusCode}');
    }
  }
}
