import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // 1. Android Emulator: Use 10.0.2.2
  // 2. Physical device: Use your PC's IP (e.g., 192.168.1.7)
  // 3. IMPORTANT: Run backend with: python manage.py runserver 0.0.0.0:8000

  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.18.116:8000/api';
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Use for Android Emulator

  // Auth
  static String get login => '$baseUrl/auth/login/';
  static String get register => '$baseUrl/auth/register/';
  static String get profile => '$baseUrl/auth/profile/';
  static String get verifyEmail => '$baseUrl/auth/verify-email/';

  // Blog
  static String get blogPosts => '$baseUrl/blog/posts/';
  static String get blogComments => '$baseUrl/blog/comments/';
  static String get likedPosts => '$baseUrl/blog/posts/liked/';
  // Dictionary
  static String get bookmarkedPosts => '$baseUrl/blog/posts/bookmarked/';
  static String get dictionaryWords => '$baseUrl/dictionary/words/';
  // History
  static String get histories => '$baseUrl/history/histories/';
  // Feedback
  static String get feedbackSubmit => '$baseUrl/feedback/submit/';
  // Dictionary Translate
  static String get dictionaryTranslate => '$baseUrl/dictionary/translate/';
  // Quiz
  static String get quizQuestions => '$baseUrl/quiz/questions/';
}
