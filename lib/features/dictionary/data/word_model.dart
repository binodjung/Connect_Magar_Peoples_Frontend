class Word {
  final int id;
  final String magarWord;
  final String englishMeaning;
  final String category;
  final DateTime createdAt;

  const Word({
    required this.id,
    required this.magarWord,
    required this.englishMeaning,
    required this.category,
    required this.createdAt,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      magarWord: json['magar_word'] as String,
      englishMeaning: json['english_meaning'] as String,
      category: json['category'] as String? ?? 'OTHERS',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
