class ApiConstants {
  // To update your IP, run: ipconfig | findstr "IPv4"
  // Current IP: 192.168.1.5
  // Run backend with: python manage.py runserver 0.0.0.0:8000

  static const String baseUrl = 'http://192.168.1.5:8000/api';
  // static const String baseUrl = 'http://172.20.10.2:8000/api';

  // Auth
  static String get login => '$baseUrl/auth/login/';
  static String get register => '$baseUrl/auth/register/';
  static String get profile => '$baseUrl/auth/profile/';
  static String get verifyEmail => '$baseUrl/auth/verify-email/';
  static String get forgotPassword => '$baseUrl/auth/forgot-password/';
  static String get verifyResetOtp => '$baseUrl/auth/verify-reset-otp/';
  static String get resetPassword => '$baseUrl/auth/reset-password/';
  static String get changePassword => '$baseUrl/auth/change-password/';

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

  // eSewa Sandbox
  static const String esewaMerchantCode = 'EPAYTEST';
  static const String esewaSecretKey = '8gBm/:&EnhH.1/q';
  static const String esewaUatUrl =
      'https://rc-epay.esewa.com.np/api/epay/main/v2/form';
}
