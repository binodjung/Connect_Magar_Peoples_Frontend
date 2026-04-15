import 'package:flutter/material.dart';
import '../../../../core/utils/colors.dart';
import '../../sign_up/presentation/sign_up_screen.dart';
import 'forgot_password_screen.dart';
import '../infrastructure/repository/auth_service.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../../core/utils/toast_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepSignedIn = false;
  bool _isPasswordVisible = false;
  final _authService = AuthService();
  bool _isLoading = false;

  // Custom theme colors based on image
  final Color maroonPrimary = const Color(0xFF801520);
  final Color maroonSubtle = const Color(0xFFB85E66);
  final Color inputGrey = const Color(0xFFF0EDED);

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastUtil.showTopToast(context, 'Please enter email and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      ToastUtil.showTopToast(context, 'Login Successful!');
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: response['user']['username'] ?? 'User',
            email: response['user']['email'] ?? '',
          ),
        ),
        (route) => false,
      );
      
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showTopToast(context, e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : maroonPrimary;
    final Color subTextColor = isDark ? Colors.grey[400]! : maroonSubtle;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color fieldColor = isDark ? const Color(0xFF2C2C2C) : inputGrey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your email and password to continue',
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 48),
              
              _buildLabel('Email or Username', textColor),
              _buildTextField(_emailController, 'Enter your email', fieldColor, subTextColor, isDark),
              const SizedBox(height: 24),
              
              _buildLabel('Password', textColor),
              _buildTextField(
                _passwordController, 
                'Enter your password', 
                fieldColor,
                subTextColor,
                isDark,
                isPassword: true, 
                isVisible: _isPasswordVisible,
                onToggleVisible: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24, width: 24,
                        child: Checkbox(
                          value: _keepSignedIn,
                          onChanged: (v) => setState(() => _keepSignedIn = v ?? false),
                          side: BorderSide(color: subTextColor),
                          activeColor: maroonPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Keep me signed in', style: TextStyle(color: subTextColor, fontSize: 13)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Create an account',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color bgColor, Color hintColor, bool isDark, {bool isPassword = false, bool isVisible = false, VoidCallback? onToggleVisible}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: hintColor),
            onPressed: onToggleVisible,
          ) : null,
        ),
      ),
    );
  }
}
