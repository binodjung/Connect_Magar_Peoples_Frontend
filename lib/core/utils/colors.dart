import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFE8A323); // Consistent with Blog UI
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color primaryMaroon = Color(0xFF801520); // Consistent with Auth UI
  static const Color secondaryMaroon = Color(0xFFB85E66);
  static const Color darkMaroon = Color(0xFF8B0000); // Consistent with Quiz/History Header
  
  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFF5F6FA); // Consistent with Page Backgrounds
  static const Color inputGrey = Color(0xFFF0EDED); // Consistent with TextFields

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryOrange, secondaryOrange],
  );
}
