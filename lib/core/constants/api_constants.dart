class ApiConstants {
  // Use 10.0.2.2 for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; 
  
  // Use 192.168.1.8 for Physical Device (same Wi-Fi)
  static const String baseUrl = 'http://192.168.1.8:8000/api'; 
  
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';
  static const String verifyEmail = '$baseUrl/auth/verify-email/';
  static const String blogPosts = '$baseUrl/blog/posts'; // Removed trailing slash
  static const String blogComments = '$baseUrl/blog/comments/';
}
