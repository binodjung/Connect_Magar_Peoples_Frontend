class ApiConstants {
  // Use 10.0.2.2 for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; 
  
  // Use 192.168.1.7 for Physical Device (same Wi-Fi)
  static const String baseUrl = 'http://192.168.1.7:8000/api/auth'; 
  
  static const String login = '$baseUrl/login/';
  static const String register = '$baseUrl/register/';
  static const String verifyEmail = '$baseUrl/verify-email/';
}
