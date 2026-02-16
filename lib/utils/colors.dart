import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color secondaryOrange = Color(0xFFFF5722);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFF5F5F5);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryOrange, secondaryOrange],
  );
}
