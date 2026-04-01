import 'package:flutter/material.dart';
import '../../login/infrastructure/repository/auth_service.dart';
import '../../verification/presentation/otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _authService = AuthService();
  bool _isLoading = false;

  final Color maroonPrimary = const Color(0xFF801520);
  final Color maroonSubtle = const Color(0xFFB85E66);
  final Color inputGrey = const Color(0xFFF0EDED);

  void _handleSignUp() async {
    if (_nameController.text.isEmpty || 
        _usernameController.text.isEmpty || 
        _mobileController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        username: _usernameController.text,
        fullName: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileController.text,
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful! Please check email.'), backgroundColor: Colors.green),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(email: _emailController.text),
        ),
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create an account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: maroonPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Full Name'),
            _buildTextField(_nameController, 'Enter your full name'),
            const SizedBox(height: 12),
            
            _buildLabel('Username'),
            _buildTextField(_usernameController, 'Enter a username'),
            const SizedBox(height: 12),
            
            _buildLabel('Mobile Number'),
            _buildTextField(_mobileController, 'Enter mobile number', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            
            _buildLabel('Email Address'),
            _buildTextField(_emailController, 'Enter email address', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            
            _buildLabel('Password'),
            _buildTextField(
              _passwordController, 
              'Enter password', 
              isPassword: true, 
              isVisible: _isPasswordVisible,
              onToggleVisible: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 12),
            
            _buildLabel('Confirm Password'),
            _buildTextField(
              _confirmPasswordController, 
              'Confirm password', 
              isPassword: true, 
              isVisible: _isConfirmPasswordVisible,
              onToggleVisible: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'By continuing, you agree to our terms of service.',
                style: TextStyle(color: maroonSubtle, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: maroonPrimary),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, bool isVisible = false, VoidCallback? onToggleVisible, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: inputGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: maroonSubtle.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: maroonSubtle),
            onPressed: onToggleVisible,
          ) : null,
        ),
      ),
    );
  }
}
