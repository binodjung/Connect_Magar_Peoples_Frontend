import 'package:flutter/material.dart';
import '../data/quiz_service.dart';
import '../data/quiz_model.dart';
import '../../../../core/utils/toast_util.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QuizService _quizService = QuizService();
  
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  String _selectedCategory = 'language';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        String cat = 'language';
        if (_tabController.index == 1) cat = 'culture';
        if (_tabController.index == 2) cat = 'history';
        
        setState(() {
          _selectedCategory = cat;
          _isLoading = true;
        });
        _fetchQuestions();
      }
    });
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await _quizService.fetchQuestions(category: _selectedCategory);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ToastUtil.showTopToast(context, 'Error loading questions: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magar Quiz'),
        backgroundColor: const Color(0xFF800000), // Maroon theme
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[300],
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Language'),
            Tab(text: 'Culture'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
          : _questions.isEmpty
              ? const Center(child: Text('No questions available in this category.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${q.questionText}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(4, (i) {
                              final optionIndex = i + 1;
                              final isCorrect = optionIndex == q.correctOption;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF800000),
                                      child: Text(
                                        String.fromCharCode(65 + i),
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(q.options[i])),
                                    if (isCorrect)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
