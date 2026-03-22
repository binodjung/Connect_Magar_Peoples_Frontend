class ApiConstants {
  // 1. Android Emulator: Use 10.0.2.2
  // 2. Physical device: Use your PC's IP (e.g., 192.168.1.7)
  // 3. IMPORTANT: Run backend with: python manage.py runserver 0.0.0.0:8000
  
  static const String baseUrl = 'http://192.168.1.7:8000/api'; 
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Uncomment for Emulator

  // Auth
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';
  static const String profile = '$baseUrl/auth/profile/';
  static const String verifyEmail = '$baseUrl/auth/verify-email/';

  // Blog
  static const String blogPosts = '$baseUrl/blog/posts/';
  static const String blogComments = '$baseUrl/blog/comments/';
  static const String likedPosts = '$baseUrl/blog/posts/liked/';
  // Dictionary
  static const String bookmarkedPosts = '$baseUrl/blog/posts/bookmarked/';
  static const String dictionaryWords = '$baseUrl/dictionary/words/';
  // History
  static const String histories = '$baseUrl/history/histories/';
  // Feedback
  static const String feedbackSubmit = '$baseUrl/feedback/submit/';
  // Dictionary Translate
  static const String dictionaryTranslate = '$baseUrl/dictionary/translate/';
}
