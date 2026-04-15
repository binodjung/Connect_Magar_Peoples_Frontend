import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/toast_util.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  final Color maroonColor = const Color(0xFF801520); // Vibrant Dark Red/Maroon from image

  Future<void> _submitFeedback() async {
    if (_emailController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ToastUtil.showTopToast(context, 'Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.feedbackSubmit),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'subject': _subjectController.text,
          'message': _messageController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 201) {
        ToastUtil.showTopToast(context, 'Feedback submitted successfully!');
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } else {
        ToastUtil.showTopToast(context, 'Failed to submit feedback', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showTopToast(context, 'Connection error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback Form',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: maroonColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 150,
              color: maroonColor,
            ),
            const SizedBox(height: 24),
            Text(
              'We value your thoughts. Please\nlet us know how we can improve.',
              style: TextStyle(
                fontSize: 16,
                color: maroonColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Email Field
            Text(
              'Email Address *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: maroonColor,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              labelText: '',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 24),
            
            // Subject Field
            Text(
              'Subject *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: maroonColor,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _subjectController,
              labelText: '',
              hintText: 'What is this about?',
            ),
            
            const SizedBox(height: 24),
            
            // Message Field
            Text(
              'Message *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: maroonColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tell us what\'s on your mind...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 40), // Extra space at bottom to ensure scrolling doesn't block text
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 24, right: 24),
          child: Center(
            heightFactor: 1.0,
            child: SizedBox(
              width: 180, // Made button small as requested
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // More rounded and attractive
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
