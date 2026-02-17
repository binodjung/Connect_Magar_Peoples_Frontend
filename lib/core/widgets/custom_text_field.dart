import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}
