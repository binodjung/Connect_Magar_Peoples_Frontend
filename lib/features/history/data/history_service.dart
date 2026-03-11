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
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<HistoryModel>> fetchHistories() async {
    final response = await http.get(
      Uri.parse(ApiConstants.histories),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load histories');
    }
  }

  Future<HistoryModel> fetchHistoryDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.histories}$id/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return HistoryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load history details');
    }
  }
}
