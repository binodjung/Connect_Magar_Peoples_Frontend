import 'package:flutter/material.dart';
import '../../../../core/utils/colors.dart';
import '../../login/infrastructure/repository/auth_service.dart';
import '../../login/presentation/login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email; // Pass email to confirm which user to verify
  const OTPVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // Changed to 6 controllers for 6-digit OTP
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  // Changed to 6 focus nodes
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() async {
    String otp = _otpControllers.map((c) => c.text).join();
    // Updated validation to check for 6 digits
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyEmail(widget.email, otp);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email Verified Successfully! Login now.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(e.toString().replaceAll('Exception: ', '')),
           backgroundColor: Colors.red,
           behavior: SnackBarBehavior.floating,
           margin: const EdgeInsets.all(16),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(8),
           ),
         ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate width to fit 6 boxes comfortably
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = (screenWidth - 48 - (5 * 8)) / 6; // 48 padding, 5 spaces of 8 width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
             Text(
              'Enter the 6-digit verification code sent to ${widget.email}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: boxSize, // Dynamic width
                  height: boxSize * 1.2, // Maintain aspect ratio
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20, // Slightly smaller font for 6 digits
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero, // Center text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), // Slightly tighter radius
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryOrange,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                'Verify',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP resent successfully')),
                  );
                },
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
