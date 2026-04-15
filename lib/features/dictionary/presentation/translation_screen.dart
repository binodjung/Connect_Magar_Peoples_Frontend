import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/toast_util.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _inputController = TextEditingController();
  String _translationText = "Translation will appear here...";
  bool _isEnglishToMagar = true;
  bool _isLoading = false;

  final Color maroonColor = const Color(0xFF801520);
  final Color creamColor = const Color(0xFFF5E6D3);

  Future<void> _translate() async {
    if (_inputController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final fromLang = _isEnglishToMagar ? 'en' : 'magar';
      final word = _inputController.text;
      
      final url = Uri.parse('${ApiConstants.dictionaryTranslate}?word=$word&from=$fromLang');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _translationText = data['translation'] ?? 'No translation available';
        });
      } else {
        setState(() {
          _translationText = 'Word not found in database';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showTopToast(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _swapLanguages() {
    setState(() {
      _isEnglishToMagar = !_isEnglishToMagar;
      _inputController.clear();
      _translationText = "Translation will appear here...";
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Translate',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Maroon Background part
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            color: maroonColor,
          ),
          
          // Main Card
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: creamColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This will translate between English and\nMagar Language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: maroonColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Input Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isEnglishToMagar ? 'English' : 'Akka Magar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _inputController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _isEnglishToMagar ? 'Enter English word...' : 'Enter Magar word...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Swap Button
                    GestureDetector(
                      onTap: _swapLanguages,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: maroonColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_vert, color: Colors.white, size: 28),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Result Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isEnglishToMagar ? 'Akka Magar' : 'English',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Result Display
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _translationText,
                          style: TextStyle(
                            fontSize: 16,
                            color: _translationText.contains('Not found') || _translationText.contains('Translation') 
                                ? Colors.grey 
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Convert Button
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _translate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                            'Convert',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
