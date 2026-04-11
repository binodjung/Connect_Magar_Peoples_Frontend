import 'dart:async';
import 'package:flutter/material.dart';
import '../data/quiz_service.dart';
import '../data/quiz_model.dart';
import 'quiz_selection_screen.dart';
import '../../../../core/utils/colors.dart';

class QuizGameScreen extends StatefulWidget {
  final String category;
  final String categoryTitle;

  const QuizGameScreen({super.key, required this.category, required this.categoryTitle});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  final QuizService _quizService = QuizService();
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  String? _error;

  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();
  
  Map<int, int> _selectedAnswers = {}; // Question index -> Option (1-4)
  
  int _timeLeft = 60;
  Timer? _timer;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchRandomQuestions();
  }

  Future<void> _fetchRandomQuestions() async {
    try {
      final questions = await _quizService.fetchQuestions(category: widget.category, random: true);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      if (_questions.isNotEmpty) {
        _startTimer();
      } else {
        setState(() {
          _error = 'No questions found for this category.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load questions. Please try again.';
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    if (_isSubmitted) return;
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });

    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctOption) {
        score++;
      }
    }

    _showResultDialog(score);
  }

  void _showResultDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Finished!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score > 5 ? Icons.emoji_events : Icons.sentiment_neutral,
              color: score > 5 ? Colors.amber : Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $score / ${_questions.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              score > 7 ? 'Excellent!' : score > 4 ? 'Good Job!' : 'Keep Practicing!',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Selection screen
            },
            child: const Text('Back to Categories'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizGameScreen(
                    category: widget.category,
                    categoryTitle: widget.categoryTitle,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkMaroon),
            child: const Text('Play Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _timeLeft <= 10 ? Colors.red : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$_timeLeft s',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Quiz'),
        backgroundColor: AppColors.darkMaroon,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _error == null && !_isSubmitted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: _buildTimerBadge()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkMaroon))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadQuiz,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkMaroon,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Progress Bar
                    SafeArea(
                      bottom: false,
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: Colors.grey[300],
                        color: AppColors.darkMaroon,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          if (_currentQuestionIndex < _questions.length - 1)
                            TextButton.icon(
                              onPressed: () {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              },
                              icon: const Icon(Icons.skip_next, color: AppColors.darkMaroon, size: 20),
                              label: const Text('Skip', style: TextStyle(color: AppColors.darkMaroon, fontSize: 16, fontWeight: FontWeight.bold)),
                              iconAlignment: IconAlignment.end,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe to force answering
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      question.questionText,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 30),
                                    ...List.generate(4, (i) {
                                      final optionIndex = i + 1;
                                      final isSelected = _selectedAnswers[index] == optionIndex;
                                      return GestureDetector(
                                        onTap: () {
                                          if (_isSubmitted) return;
                                          setState(() {
                                            _selectedAnswers[index] = optionIndex;
                                          });
                                          // Auto next after slight delay
                                          if (index < _questions.length - 1) {
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              if (mounted) {
                                                _pageController.nextPage(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                                setState(() {
                                                  _currentQuestionIndex = index + 1;
                                                });
                                              }
                                            });
                                          } else {
                                            // On last question, wait a bit and show Submit
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.darkMaroon : Colors.white,
                                            border: Border.all(
                                              color: isSelected ? AppColors.darkMaroon : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: isSelected ? Colors.white : Colors.grey[200],
                                                child: Text(
                                                  String.fromCharCode(65 + i),
                                                  style: TextStyle(
                                                    color: isSelected ? AppColors.darkMaroon : Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  question.options[i],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentQuestionIndex > 0)
                              TextButton.icon(
                                onPressed: () {
                                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  setState(() {
                                    _currentQuestionIndex--;
                                  });
                                },
                                 icon: const Icon(Icons.arrow_back, color: AppColors.darkMaroon),
                                 label: const Text('Previous', style: TextStyle(color: AppColors.darkMaroon, fontWeight: FontWeight.bold)),
                              )
                            else
                              const SizedBox.shrink(),
                            
                            if (_currentQuestionIndex == _questions.length - 1)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: ElevatedButton(
                                    onPressed: _submitQuiz,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    child: const Text('Submit Quiz', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
