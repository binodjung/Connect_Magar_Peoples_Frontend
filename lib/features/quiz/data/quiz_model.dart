class QuizQuestion {
  final int id;
  final String questionText;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int correctOption;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      questionText: json['question_text'] ?? '',
      option1: json['option1'] ?? '',
      option2: json['option2'] ?? '',
      option3: json['option3'] ?? '',
      option4: json['option4'] ?? '',
      correctOption: json['correct_option'] ?? 1,
      category: json['category'] ?? 'language',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correct_option': correctOption,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get options as a list
  List<String> get options => [option1, option2, option3, option4];
}
