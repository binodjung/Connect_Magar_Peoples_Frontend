class ApiConstants {
  // Use 10.0.2.2 for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Use your PC's IP for Physical Device (same Wi-Fi)
  static const String baseUrl = 'http://192.168.1.6:8000/api';

  // Auth
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';
  static const String verifyEmail = '$baseUrl/auth/verify-email/';

  // Blog
  static const String blogPosts = '$baseUrl/blog/posts';
  static const String blogComments = '$baseUrl/blog/comments/';
  static const String likedPosts = '$baseUrl/blog/posts/liked/';
  static const String bookmarkedPosts = '$baseUrl/blog/posts/bookmarked/';
}
