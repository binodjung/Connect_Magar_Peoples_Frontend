class HistorySectionModel {
  final int id;
  final String? image;
  final String description;
  final int order;

  const HistorySectionModel({
    required this.id,
    this.image,
    required this.description,
    required this.order,
  });

  factory HistorySectionModel.fromJson(Map<String, dynamic> json) {
    return HistorySectionModel(
      id: json['id'] as int,
      image: json['image'] as String?,
      description: json['description'] as String,
      order: json['order'] as int,
    );
  }
}

class HistoryModel {
  final int id;
  final String title;
  final List<HistorySectionModel>? sections;
  final DateTime createdAt;

  const HistoryModel({
    required this.id,
    required this.title,
    this.sections,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((e) => HistorySectionModel.fromJson(e))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
