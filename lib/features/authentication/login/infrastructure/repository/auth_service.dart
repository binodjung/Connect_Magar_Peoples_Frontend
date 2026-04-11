import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login Response: $data'); // Debug print
      
      final String? accessToken = data['tokens']?['access'];
      final String? refreshToken = data['tokens']?['refresh'];

      if (accessToken == null || refreshToken == null) {
         // Fallback if structure is different
         final String? altAccess = data['access'];
         final String? altRefresh = data['refresh'];
         
         if (altAccess != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', altAccess);
            if (altRefresh != null) await prefs.setString('refresh_token', altRefresh);
            
            // Save user info here as well
            if (data['user'] != null) {
              await prefs.setString('username', data['user']['username'] ?? '');
              await prefs.setString('email', data['user']['email'] ?? '');
              await prefs.setString('full_name', data['user']['full_name'] ?? '');
              await prefs.setString('mobile_number', data['user']['mobile_number'] ?? '');
              if (data['user']['profile_picture'] != null) {
                await prefs.setString('profile_picture', data['user']['profile_picture']);
              }
            }
            return data;
         }
         
         throw Exception('Invalid response structure: Missing tokens');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      
      // Also store user info for persistence
      if (data['user'] != null) {
        await prefs.setString('username', data['user']['username'] ?? '');
        await prefs.setString('email', data['user']['email'] ?? '');
        await prefs.setString('full_name', data['user']['full_name'] ?? '');
        await prefs.setString('mobile_number', data['user']['mobile_number'] ?? '');
        if (data['user']['profile_picture'] != null) {
          await prefs.setString('profile_picture', data['user']['profile_picture']);
        }
      }
      
      return data;
      } else {
        throw Exception(_parseErrorMessage(response.body));
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Connection Timeout: Please check if the server is running and reachable at ${ApiConstants.baseUrl}');
      }
      throw Exception('Connection Error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'full_name': fullName,
          'email': email,
          'mobile_number': mobileNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Slightly longer for registration if email sending is slow

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseErrorMessage(response.body));
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Connection Timeout: The server took too long to respond. Please check the backend logs.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmail),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseErrorMessage(response.body));
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Verification timeout. Please try again.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  
  String _parseErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      
      // Handle List responses (e.g. ["Invalid OTP"])
      if (decoded is List) {
        return decoded.join('\n');
      }

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message')) {
          return decoded['message'];
        }
        if (decoded.containsKey('error')) {
          return decoded['error'];
        }
        if (decoded.containsKey('non_field_errors')) {
          return (decoded['non_field_errors'] as List).join(', ');
        }
        // Fallback for other Django error formats
        final firstKey = decoded.keys.first;
        final firstValue = decoded[firstKey];
        if (firstValue is List) return firstValue.first.toString();
        return firstValue.toString();
      }
      return 'An unknown error occurred';
    } catch (_) {
      return 'Failed to process server response';
    }
  }
}
