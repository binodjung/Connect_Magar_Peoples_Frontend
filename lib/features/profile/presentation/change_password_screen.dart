import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/toast_util.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ToastUtil.showTopToast(context, 'Please fill all fields', isError: true);
      return;
    }

    if (newPass.length < 6) {
      ToastUtil.showTopToast(context, 'Password must be at least 6 characters', isError: true);
      return;
    }

    if (newPass != confirm) {
      ToastUtil.showTopToast(context, 'New passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse(ApiConstants.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': current,
          'new_password': newPass,
          'confirm_password': confirm,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastUtil.showTopToast(context, 'Password changed successfully!');
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ToastUtil.showTopToast(context, data['message'] ?? 'Failed to change password', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showTopToast(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Update your password to keep your account secure.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildLabel('Current Password'),
            _buildTextField(
              _currentPasswordController, 
              'Enter current password',
              isVisible: _currentVisible,
              onToggle: () => setState(() => _currentVisible = !_currentVisible),
            ),
            const SizedBox(height: 20),

            _buildLabel('New Password'),
            _buildTextField(
              _newPasswordController, 
              'Enter new password',
              isVisible: _newVisible,
              onToggle: () => setState(() => _newVisible = !_newVisible),
            ),
            const SizedBox(height: 20),

            _buildLabel('Confirm New Password'),
            _buildTextField(
              _confirmPasswordController, 
              'Confirm new password',
              isVisible: _confirmVisible,
              onToggle: () => setState(() => _confirmVisible = !_confirmVisible),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {required bool isVisible, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
