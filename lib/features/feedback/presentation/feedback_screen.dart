import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/custom_text_field.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
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
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tell us what\'s on your mind...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
